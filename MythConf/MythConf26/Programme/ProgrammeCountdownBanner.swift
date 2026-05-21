//
//  ProgrammeCountdownBanner.swift
//  IOSDevuk26
//

import Combine
import SwiftUI

/// Propagates the measured height of the Programme countdown banner so the
/// ScrollView underneath can add matching bottom inset and still let the user
/// scroll the last item into view above the banner.
struct ProgrammeBannerHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// Pinned bottom banner that adapts to where we are relative to the
/// conference timeline (before / during a session / between sessions / after).
/// During a parallel slot it cycles through the running talks every few
/// seconds — unless Reduce Motion is on, in which case it shows a static
/// "N parallel talks" summary. Tap jumps to the current talk; long-press
/// opens the debug date override.
struct ProgrammeCountdownBanner: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale
    let dateOverride: DateOverride
    let onTapCurrent: (TalkReference?) -> Void

    @State private var cycleIndex: Int = 0

    @State private var cycleTimer = Timer.publish(every: 8, on: .main, in: .common).autoconnect()

    private var now: Date { dateOverride.now }

    private var confTimeType: ConfTimeType {
        viewModel.confData.whereInConf(now: now)
    }

    private var currentSession: Session? {
        viewModel.confData.currentSession(now: now)
    }

    private var currentTalks: [Talk] {
        guard let session = currentSession, session.containsTalk else { return [] }
        return session.contentIDs.map { viewModel.talkFrom(talkID: $0) }
    }

    private var displayedTalk: Talk? {
        let talks = currentTalks
        guard !talks.isEmpty else { return nil }
        return talks[cycleIndex % talks.count]
    }

    private var currentTalkReference: TalkReference? {
        guard let session = currentSession, let talk = displayedTalk else { return nil }
        return TalkReference(talkID: talk.id, session: session)
    }

    var body: some View {
        bannerContent
            .onReceive(cycleTimer) { _ in
                advanceCycleIfNeeded()
            }
            .onChange(of: currentSession?.id) { _, _ in
                cycleIndex = 0
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(combinedAccessibilityLabel)
            .accessibilityHint(accessibilityHintText)
            .accessibilityAddTraits(currentTalkReference != nil ? .isButton : [])
            .accessibilityInputLabels(accessibilityInputLabels)
    }

    /// Renders the banner with tap-related modifiers (`.onTapGesture`,
    /// interactive `glassEffect`) only when there's a session to navigate to.
    /// Otherwise SwiftUI still treats the view as interactive and VoiceOver
    /// announces "button" even with no `.isButton` trait added.
    @ViewBuilder
    private var bannerContent: some View {
        if currentTalkReference != nil {
            bannerCore
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
                .contentShape(.rect(cornerRadius: 22))
                .onTapGesture {
                    onTapCurrent(currentTalkReference)
                }
        } else {
            bannerCore
                .glassEffect(.regular, in: .rect(cornerRadius: 22))
        }
    }

    private var bannerCore: some View {
        HStack(spacing: 12) {
            leadingIcon
            VStack(alignment: .leading, spacing: 2) {
                ZStack(alignment: .leading) {
                    titleView
                        .id(primaryTitleText)
                        .transition(parallelFadeTransition)
                }
                ZStack(alignment: .leading) {
                    Text(primarySubtitleText)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .id(primarySubtitleText)
                        .transition(parallelFadeTransition)
                }
            }
            Spacer(minLength: 0)
            if currentTalkReference != nil {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dynamicTypeSize(...DynamicTypeSize.large)
    }

    // MARK: - Primary title / subtitle

    private var isShowingTalk: Bool {
        displayedTalk != nil
    }

    private var primaryTitleText: String {
        if let talk = displayedTalk {
            return talk.talkTitle
        }
        if let day = currentConfDay {
            let dateString = day.startDate.formatted(.dateTime.month().day().weekday(.wide).locale(locale))
            return String(localized: "Day \(day.number) · \(dateString)", comment: "Programme banner title on a conference day when no specific talk is currently happening — shows the day number plus locale-formatted date and weekday.")
        }
        return "MythConf 2026"
    }

    private var primarySubtitleText: String {
        if let talk = displayedTalk {
            return viewModel.speakersFrom(talkID: talk.id)
        }
        return secondaryText
    }

    @ViewBuilder
    private var titleView: some View {
        if isShowingTalk {
            MarqueeText(text: primaryTitleText, font: .headline.weight(.bold))
                .foregroundStyle(.primary)
        } else {
            Text(primaryTitleText)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    // MARK: - Cycle

    private func advanceCycleIfNeeded() {
        let count = currentTalks.count
        guard !reduceMotion, count > 1 else { return }
        withAnimation {
            cycleIndex = (cycleIndex + 1) % count
        }
    }

    /// Sequential crossfade used when cycling between parallel talks: the
    /// outgoing text fades out, then the incoming text fades in. The
    /// transition only fires inside `advanceCycleIfNeeded`, so single-talk
    /// slots and session-boundary changes stay instantaneous.
    private var parallelFadeTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.animation(.easeIn(duration: 0.5).delay(0.5)),
            removal: .opacity.animation(.easeOut(duration: 0.5))
        )
    }

    // MARK: - Leading icon

    @ViewBuilder
    private var leadingIcon: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
            if currentTalks.count > 1, let badgeSymbol = parallelBadgeSymbol {
                Image(systemName: badgeSymbol)
                    .font(.caption2.bold())
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
                    .offset(x: 6, y: -6)
            }
        }
        .accessibilityHidden(true)
    }

    /// SF Symbol name for the current cycle index as a filled circle ("1.circle.fill",
    /// "2.circle.fill", …). Returns nil if the count is out of range.
    private var parallelBadgeSymbol: String? {
        let n = (cycleIndex % max(1, currentTalks.count)) + 1
        guard n >= 0, n <= 50 else { return nil }
        return "\(n).circle.fill"
    }

    // MARK: - State-driven content

    private var iconName: String {
        if let session = currentSession, let typed = session.sessionType.iconName {
            return typed
        }
        switch confTimeType {
        case .beforeConf:                                             return "calendar"
        case .beforeConfDayStart, .duringConfDay, .afterConfDayEnd:   return "sparkles"
        case .afterConf:                                              return "heart.fill"
        case .dummy:                                                  return "calendar"
        }
    }

    private var iconColor: Color {
        if let session = currentSession {
            switch session.sessionType {
            case .dummy: break
            default: return session.sessionType.color
            }
        }
        switch confTimeType {
        case .beforeConf:                                             return .accentColor
        case .beforeConfDayStart, .duringConfDay, .afterConfDayEnd:   return .orange
        case .afterConf:                                              return .pink
        case .dummy:                                                  return .accentColor
        }
    }

    private var secondaryText: String {
        switch confTimeType {
        case .beforeConf:
            let days = daysUntilConfStart
            if days <= 0 {
                return String(localized: "Starting soon", comment: "Programme banner subtitle when the conference begins later today.")
            }
            return String(localized: "\(days) days until MythConf", comment: "Programme banner subtitle showing how many days remain until the conference starts. Plural-aware: '1 day until MythConf' / 'N days until MythConf'.")
        case .afterConf:
            return String(localized: "Thanks for joining — see you in 2027", comment: "Programme banner subtitle after the conference has ended.")
        case .beforeConfDayStart, .duringConfDay, .afterConfDayEnd:
            if let session = currentSession, !session.containsTalk {
                return String(localized: "Now: \(session.sessionType.displayName)", comment: "Programme banner subtitle showing the name of the current non-talk session (e.g. lunch, registration).")
            }
            return String(localized: "Happening now", comment: "Programme banner subtitle on a conference day when no specific session is currently running. Day number/date now lives in the title.")
        case .dummy:
            return String(localized: "iOSDevUK", comment: "Programme banner fallback subtitle when conference dates aren't available.")
        }
    }

    // MARK: - Accessibility

    /// For VoiceOver during a parallel slot we read *all* talk titles + their
    /// speakers, not just the one currently being cycled — so the user gets
    /// the complete picture in a single utterance instead of having to wait
    /// through the cycle / read the marquee.
    private var combinedAccessibilityLabel: String {
        let talks = currentTalks
        if talks.count > 1 {
            let items = talks.map { talk in
                "\(talk.talkTitle), by \(viewModel.speakersFrom(talkID: talk.id))"
            }.joined(separator: "; ")
            return String(localized: "Now: \(talks.count) parallel talks: \(items)", comment: "VoiceOver label for the Programme banner during a parallel slot, listing every running talk and its speakers.")
        }
        if let talk = talks.first {
            let speakers = viewModel.speakersFrom(talkID: talk.id)
            return String(localized: "Now: \(talk.talkTitle), by \(speakers)", comment: "VoiceOver label for the Programme banner during a single-talk slot.")
        }
        return "\(primaryTitleText), \(secondaryText)"
    }

    private var accessibilityHintText: Text {
        if currentTalkReference != nil {
            return Text("Opens the current session.", comment: "VoiceOver hint when the banner is tappable into a session detail.")
        }
        return Text("")
    }

    private var accessibilityInputLabels: [String] {
        var labels = ["MythConf countdown", "Countdown"]
        if currentTalkReference != nil {
            labels.insert(contentsOf: ["Current session", "Open current talk", "Now playing"], at: 0)
        }
        return labels
    }

    // MARK: - Date math

    private var daysUntilConfStart: Int {
        guard let firstSession = viewModel.confData.sessions.first?.first else { return 0 }
        let cal = Calendar.current
        let startDay = cal.startOfDay(for: firstSession.startTime)
        let nowDay = cal.startOfDay(for: now)
        return cal.dateComponents([.day], from: nowDay, to: startDay).day ?? 0
    }

    private var currentConfDay: (number: Int, startDate: Date)? {
        let cal = Calendar.current
        for (idx, daySessions) in viewModel.confData.sessions.enumerated() {
            guard let first = daySessions.first else { continue }
            if cal.isDate(now, inSameDayAs: first.startTime) {
                return (idx + 1, first.startTime)
            }
        }
        return nil
    }
}
