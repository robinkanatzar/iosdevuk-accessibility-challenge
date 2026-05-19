//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.legibilityWeight) private var legibilityWeight
    @Environment(\.appSettings) private var appSettings
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session
    let schedulePosition: ViewModel.SchedulePosition?
    let rotorNamespace: Namespace.ID

    private var talk: Talk {
        viewModel.talkFrom(talkID: talkID)
    }

    private var isFavourite: Bool {
        viewModel.isFavourite(talk: talk)
    }

    private var speakers: String {
        viewModel.speakersFrom(talkID: talkID)
    }

    private var locationName: String {
        viewModel.locationNameFrom(talkID: talkID)
    }

    private var statusDisplay: Session.StatusDisplay {
        session.statusDisplay(now: viewModel.currentDate)
    }

    private var accessibilityStateValue: String {
        [
            schedulePosition?.accessibilityText,
            statusDisplay.isVisible ? statusDisplay.accessibilityLabel : nil
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }

    private var cardBackground: AnyShapeStyle {
        if reduceTransparency {
            return AnyShapeStyle(Color(.secondarySystemBackground))
        } else if colorScheme == .dark {
            return AnyShapeStyle(Color(.secondarySystemBackground))
        } else if colorSchemeContrast == .increased {
            return AnyShapeStyle(Color(.systemBackground))
        } else {
            return AnyShapeStyle(session.sessionType.color.opacity(0.08))
        }
    }

//    private var cardBorderColor: Color {
//        if colorSchemeContrast == .increased {
//            return session.sessionType.color
//        }
//        return colorScheme == .dark ? Color(.separator) : session.sessionType.color.opacity(0.18)
//    }

    private var cardBorderColor: Color {
        if statusDisplay.status == .live {
            return .red.opacity(colorSchemeContrast == .increased ? 1 : 0.7)
        }

        if colorSchemeContrast == .increased {
            return session.sessionType.color
        }

        return colorScheme == .dark
            ? Color(.separator)
            : session.sessionType.color.opacity(0.18)
    }

    private var metadataLayoutSpacing: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 10 : 8
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
                cardContent
            }
            .accessibilityIdentifier("programme.card.\(talk.id.uuidString)")
            .accessibilityLabel("\(session.sessionType.displayName): \(talk.talkTitle)")
            .accessibilityInputLabels([
                talk.talkTitle,
                "Open \(talk.talkTitle)"
            ])
            .accessibilityValue(accessibilityStateValue)
            .accessibilityCustomContent("Speaker", speakers, importance: .high)
            .accessibilityCustomContent("Location", locationName, importance: .default)
            .accessibilityCustomContent("Time", session.accessibilityTimeRange, importance: .default)
            .accessibilityCustomContent("Status", statusDisplay.isVisible ? statusDisplay.accessibilityLabel : "Not started", importance: .default)
            .accessibilityCustomContent("Favourite", isFavourite ? "Favourited" : "Not favourited", importance: .default)
            .accessibilityRotorEntry(id: ScheduleRotorTargetID.talk(talk.id), in: rotorNamespace)
            .accessibilityAction(named: isFavourite ? "Remove from favourites" : "Add to favourites") {

                toggleFavourite()
            }
            .buttonStyle(.plain)

            VStack {
                Spacer()
                // Hidden from VoiceOver because the card above already exposes a
                // "Add/Remove from favourites" custom action (swipe up to access).
                // Kept visible for Switch Control and Full Keyboard Access users
                // who benefit from a discrete tap target.
                FavouriteButtonView(talk: talk)
                    .accessibilityHiddenFromVoiceOver()
                    .accessibilityIdentifier("programme.favourite.\(talk.id.uuidString)")
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.12), radius: 8, y: 3)
                    )
                    .padding(.bottom, 16)
                    .padding(.trailing, 16)
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            session.sessionType.color
                .frame(height: 5)
                .accessibilityHidden(true)


            if dynamicTypeSize > .large  {
                VStack(alignment: .leading, spacing: 10) {
                    sessionTypeChip

                    SessionStatusBadge(session: session)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

            } else {
                HStack {
                    sessionTypeChip
                    Spacer()
                    SessionStatusBadge(session: session)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

            }

            VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? 18 : 16) {


                Text(talk.talkTitle)
                    .dyslexiaReadingFont(
                        dynamicTypeSize.isAccessibilitySize ? .body : .headline,
                        size: 17,
                        weight: legibilityWeight == .bold ? .black : .bold
                    )
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 4)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                metadataContent
            }
            .padding(.leading, 18)
            .padding(.top, 18)
            .padding(.trailing, 18)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardBackground, in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(cardBorderColor, lineWidth: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .clipShape(.rect(cornerRadius: 18))
        .shadow(
            color: Color.black.opacity(colorScheme == .dark || reduceTransparency ? 0 : 0.12),
            radius: 10,
            y: 4
        )
    }

    private var sessionTypeChip: some View {
        Text(session.sessionType.displayName.uppercased())
            .font(.caption)
            .fontWeight(.black)
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
            .tracking(1.8)
            .foregroundStyle(session.sessionType.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(session.sessionType.color.opacity(colorSchemeContrast == .increased ? 1 : 0.28), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.45))
                    )
            )
            .accessibilityHidden(true)
    }

    private var metadataContent: some View {
        VStack(alignment: .leading, spacing: metadataLayoutSpacing) {
            metadataRow(systemImage: "person", text: speakers, isPrimary: true)
            metadataRow(systemImage: "mappin.circle", text: locationName, isPrimary: false)
                .padding(.trailing, dynamicTypeSize > .xxLarge ? 60 : 0)
        }
    }

    private func metadataRow(systemImage: String, text: String, isPrimary: Bool) -> some View {
        Label {
            Text(text)
                .font(isPrimary ? .callout : .caption)
                .fontWeight(isPrimary ? .semibold : .regular)
                .foregroundStyle(isPrimary ? .primary : .secondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundStyle(isPrimary ? session.sessionType.color : .secondary)
                .accessibilityHidden(true)
        }
        .labelStyle(.titleAndIcon)
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
            FavouriteToggleFeedback.added(
                hapticsEnabled: appSettings.usesFavouriteHaptics,
                soundsEnabled: appSettings.usesFavouriteSounds
            )
        }
    }
}

#Preview {
    @Previewable @Namespace var rotorNamespace
    let viewModel = ViewModel()
    let talkID = UUID(uuidString: "C1001006-C100-4100-8100-100000000006")!
    let session = viewModel.confData.sessions[1][2]

    ParallelTalkCardView(
        talkID: talkID,
        session: session,
        schedulePosition: .next,
        rotorNamespace: rotorNamespace
    )
    .environment(viewModel)
    .padding()
}
