//
//  UpNextCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// Promotes a single favourited session — either currently underway or
/// starting within the next two hours — to the top of the My Schedule
/// tab. Surfaces the answer to "what's next on *my* list" without
/// requiring the user to scan day-grouped sections during a busy
/// conference morning.
///
/// Visible whenever `ViewModel.nextUpcomingFavouriteSession(now:)`
/// returns a non-nil value; hidden otherwise so the screen stays quiet
/// when nothing imminent is on the list.
struct UpNextCardView: View {
    @Environment(ViewModel.self) private var viewModel
    let session: Session
    let now: Date

    private var talkID: UUID? { session.contentIDs.first(where: viewModel.favouriteIds.contains) }
    private var liveStatus: SessionLiveStatus { SessionLiveStatus.status(for: session, now: now) }
    private var headerLabel: String { liveStatus == .live ? "On now" : "Up next" }

    var body: some View {
        if let talkID {
            NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
                cardBody(talkID: talkID)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel(talkID: talkID))
            .accessibilityHint("Opens session details")
            .accessibilityInputLabels([headerLabel, headerLabel == "On now" ? "On now session" : "Next session"])
        }
    }

    @ViewBuilder
    private func cardBody(talkID: UUID) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                // Colour identity stays on the icon so the status is
                // still glanceable; the text uses .primary so it meets
                // the WCAG 4.5:1 contrast threshold against the tinted
                // card background. Orange-on-orange (and accent-on-accent)
                // failed Accessibility Inspector's contrast audit.
                Image(systemName: liveStatus == .live ? "circle.fill" : "clock")
                    .foregroundStyle(liveStatus == .live ? Color.orange : Color.accentColor)
                    .accessibilityHidden(true)
                Text(headerLabel.uppercased())
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)
            }

            Text(viewModel.talkTitleFrom(talkID: talkID))
                .font(.title3)
                .bold()
                .multilineTextAlignment(.leading)

            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .accessibilityHidden(true)
                Text(timeText)
                    .font(.subheadline)
                Spacer(minLength: 6)
                Image(systemName: "mappin")
                    .accessibilityHidden(true)
                Text(viewModel.locationNameFrom(talkID: talkID))
                    .font(.subheadline)
            }
            .contrastAdaptiveSecondary()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            (liveStatus == .live ? Color.orange : Color.accentColor)
                .opacity(0.12),
            in: .rect(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(liveStatus == .live ? Color.orange : Color.accentColor, lineWidth: 1.5)
                .allowsHitTesting(false)
        )
    }

    private var timeText: String {
        switch liveStatus {
        case .live: return "Now — ends at \(session.endTimeAccessibilityText)"
        case .startingSoon(let minutes):
            return minutes == 1 ? "Starts in 1 minute" : "Starts in \(minutes) min"
        case .upcoming, .finished:
            return session.timeRange
        }
    }

    private func accessibilityLabel(talkID: UUID) -> String {
        let title = viewModel.talkTitleFrom(talkID: talkID)
        let location = viewModel.locationNameFrom(talkID: talkID)
        switch liveStatus {
        case .live:
            return "On now. \(title), at \(location). Ends at \(session.endTimeAccessibilityText)."
        case .startingSoon(let minutes):
            let mins = minutes == 1 ? "1 minute" : "\(minutes) minutes"
            return "Up next. \(title), at \(location). Starts in \(mins)."
        case .upcoming, .finished:
            return "Up next. \(title), at \(location). \(session.timeRangeAccessibilityText)."
        }
    }
}
