//
//  SessionDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import NaturalLanguage

struct SessionDetailView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.appSettings) private var appSettings
    @Environment(ViewModel.self) private var viewModel
    let talkReference: TalkReference

    private var talk: Talk { viewModel.talkFrom(talkID: talkReference.talkID) }
    private var session: Session { talkReference.session }
    private var isFavourite: Bool { viewModel.isFavourite(talk: talk) }
    private var locationName: String { viewModel.locationNameFrom(locationID: talk.locationID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text(talk.talkTitle)
                    .dyslexiaReadingFont(.title, size: 24, weight: .heavy)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("sessionDetail.title")
                    .accessibilityLabel("")
                    .accessibilityLabel { _ in
                        Text("Session Title: \(talk.talkTitle)")
                    }

                VStack(alignment: .leading, spacing: 14) {

                    if dynamicTypeSize.isAccessibilitySize {

                        VStack {
                            sectionHeading("About This Session")
                                .accessibilityHidden(true)

                            Spacer()
                            sectionHeading(session.timeRange)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel { _ in
                                    Text("Time: \(session.accessibilityTimeRange(now: viewModel.currentDate))")
                                }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("sessionDetail.aboutHeading")

                    } else {

                        HStack {
                            sectionHeading("About This Session")
                                .accessibilityHidden(true)

                            Spacer()
                            sectionHeading(session.timeRange)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel { _ in
                                    Text("Time: \(session.accessibilityTimeRange(now: viewModel.currentDate))")
                                }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("sessionDetail.aboutHeading")

                    }


                    Text(talk.talkDescription)
                        .dyslexiaReadingFont(.body, size: 17)
                        .lineSpacing(5)
                        .foregroundStyle(Color(.label))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("sessionDetail.about")
                        .accessibilityLabel { _ in
                            Text("Session Description: \(talk.talkDescription)")
                        }
                }

                Divider()

                VStack(alignment: .leading, spacing: 20) {
                    NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                        sessionInfoRowContent(
                            title: "Location",
                            value: locationName,
                            systemImage: "mappin.circle"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel { _ in
                        Text("Location: \(locationName)")
                    }
                    .accessibilityInputLabels([
                        "Location",
                        locationName,
                        "Open \(locationName)"
                    ])
                    .accessibilityHint("Opens location details")
                    .accessibilityIdentifier("sessionDetail.location")
                    .accessibilityAddTraits(.isButton)

                    ForEach(talk.speakerIDs, id: \.self) { speakerID in
                        NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                            sessionInfoRowContent(
                                title: "Speaker",
                                value: viewModel.speakerNameFrom(speakerID: speakerID),
                                systemImage: "person.circle"
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel { _ in
                            Text("Speaker: \(viewModel.speakerNameFrom(speakerID: speakerID))")
                        }
                        .accessibilityInputLabels([
                            viewModel.speakerNameFrom(speakerID: speakerID),
                            "Open \(viewModel.speakerNameFrom(speakerID: speakerID))"
                        ])
                        .accessibilityHint("Opens speaker profile")
                        .accessibilityIdentifier("sessionDetail.speaker.\(speakerID)")
                        .accessibilityAddTraits(.isButton)
                    }
                }

                Divider()


                Button {
                    toggleFavourite()
                } label: {
                    favouriteButtonLabel
                }
                .contentShape(.rect)
                .accessibilityLabel(favouriteActionAccessibilityLabel)
                .accessibilityHint(isFavourite ? "Removes this session from your favourites" : "Adds this session to your favourites")
                .accessibilityInputLabels(isFavourite
                    ? ["Unfavourite", "Remove from favourites", "Remove from schedule", "Star", talk.talkTitle, "Unfavourite \(talk.talkTitle)"]
                    : ["Favourite", "Add to favourites", "Add to schedule", "Star", talk.talkTitle, "Favourite \(talk.talkTitle)"]
                )
                .accessibilityIdentifier("sessionDetail.favouriteAction")
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .accessibilityAction(.magicTap) {
            toggleFavourite()
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            SaveSessionTip.hasViewedSaveContext = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavouriteButtonView(talk: talk)
                // Hidden from VoiceOver — the Add/Remove button below
                // already covers this action with full context.
                // Kept visible for Switch Control and Full Keyboard Access.
                .accessibilityHiddenFromVoiceOver()
            }
        }
    }

    private var favouriteActionTitle: String {
        isFavourite ? "Remove from Favourites" : "Add to Favourites"
    }

    private var favouriteActionAccessibilityLabel: String {
        isFavourite ? "Remove \(talk.talkTitle) from favourites" : "Add \(talk.talkTitle) to favourites"
    }

    // MARK: - Favourite button state colours

    /// Neutral card for the "not yet saved" (add) state.
    private var addBackground: Color { Color(.secondarySystemBackground) }

    /// Accent-tinted card for the "already saved" (remove) state.
    private var savedBackground: Color { Color.accentColor.opacity(0.12) }

    private var buttonBackground: Color { isFavourite ? savedBackground : addBackground }

    private var borderColor: Color {
        isFavourite
            ? Color.accentColor.opacity(colorSchemeContrast == .increased ? 0.8 : 0.35)
            : Color(.separator)
    }

    private var borderWidth: CGFloat { colorSchemeContrast == .increased ? 1.5 : 0.5 }

    /// Filled circle when saved, subtle tint when not.
    private var iconCircleFill: Color {
        isFavourite ? Color.accentColor : Color.accentColor.opacity(0.15)
    }

    /// White on a filled circle; accent on a tinted circle.
    private var iconForeground: Color {
        isFavourite ? Color.myWhite : Color.accentColor
    }

    private var favouriteButtonLabel: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Image(systemName: isFavourite ? "star.fill" : "star")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(iconForeground)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(iconCircleFill))
                            .dynamicTypeSize(.large)
                            .accessibilityHidden(true)

                        Spacer()

                        Image(systemName: isFavourite ? "checkmark" : "plus")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.accentColor)
                            .accessibilityHidden(true)
                    }

                    Text(favouriteActionTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text(isFavourite ? "Remove from your schedule" : "Save to your schedule")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                HStack(alignment: .center) {
                    Image(systemName: isFavourite ? "star.fill" : "star")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(iconForeground)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(iconCircleFill))
                        .dynamicTypeSize(.large)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(favouriteActionTitle)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)

                        Text(isFavourite ? "Remove from your schedule" : "Save to your schedule")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: isFavourite ? "checkmark" : "plus")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(buttonBackground, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: borderWidth)
        }
        .contentShape(.rect)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isFavourite)
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .tracking(1.2)
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isHeader)
    }

    private func sessionInfoRow(
        title: String,
        value: String,
        accessibilityValue: String? = nil,
        systemImage: String,
        accessibilityIdentifier: String
    ) -> some View {
        sessionInfoRowContent(title: title, value: value, systemImage: systemImage)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(accessibilityValue ?? value)
            .accessibilityIdentifier(accessibilityIdentifier)
    }

    private func sessionInfoRowContent(title: String, value: String, systemImage: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: 52, height: 52)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .accessibilityAddTraits(.isHeader)

                Text(value)
                    .font(.body)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func speakerSummary(for speakerID: String) -> String {
        let speaker = viewModel.speakerFrom(speakerID: speakerID)
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = speaker.speakerInfo

        if let firstSentenceRange = tokenizer.tokens(for: speaker.speakerInfo.startIndex..<speaker.speakerInfo.endIndex).first {
            return String(speaker.speakerInfo[firstSentenceRange])
        }
        return speaker.speakerInfo
    }

    private func toggleFavourite() {
        if isFavourite {
            viewModel.removeFavourite(talk: talk, reminderTiming: appSettings.favouriteReminderTiming)
            FavouriteToggleFeedback.removed(
                hapticsEnabled: appSettings.usesFavouriteHaptics,
                soundsEnabled: appSettings.usesFavouriteSounds
            )
        } else {
            viewModel.addFavourite(talk: talk, reminderTiming: appSettings.favouriteReminderTiming)
            SaveSessionTip.hasSavedFavourite = true
            FavouriteToggleFeedback.added(
                hapticsEnabled: appSettings.usesFavouriteHaptics,
                soundsEnabled: appSettings.usesFavouriteSounds
            )
        }
    }
}

#Preview {
    let viewModel = ViewModel()
    let talkID = UUID(uuidString: "C1001006-C100-4100-8100-100000000006")!
    let session = viewModel.confData.sessions[1][2]

    NavigationStack {
        SessionDetailView(talkReference: TalkReference(talkID: talkID, session: session))
            .environment(viewModel)
    }
}
