//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session

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

    private var cardBackground: AnyShapeStyle {
        if reduceTransparency {
            return AnyShapeStyle(Color(.secondarySystemBackground))
        } else if colorSchemeContrast == .increased {
            return AnyShapeStyle(session.sessionType.color.opacity(0.18))
        } else {
            return AnyShapeStyle(session.sessionType.color.opacity(0.1))
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
                cardContent
            }
            .accessibilityLabel("\(session.sessionType.displayName): \(talk.talkTitle)")
            .accessibilityValue("\(session.timeRange), \(speakers), \(locationName), \(isFavourite ? "Favourited" : "Not favourited")")
            .accessibilityHint("Shows session details")
            .accessibilityAction(named: isFavourite ? "Remove from favourites" : "Add to favourites") {
                toggleFavourite()
            }
            .accessibilitySortPriority(1)
            .buttonStyle(.plain)

            FavouriteButtonView(talk: talk)
                .padding(.trailing, 14)
                .padding(.bottom, 14)
                .accessibilitySortPriority(0)
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            session.sessionType.color
                .frame(height: 4)
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(session.sessionType.displayName)
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.secondary)
                Text(talk.talkTitle)
                    .bold()
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .accessibilityAddTraits(.isHeader)
                Text(speakers)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                Text(locationName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.top, 16)
            .padding(.trailing, 72)
            .padding(.bottom, 52)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardBackground, in: .rect(cornerRadius: 10))
        .clipShape(.rect(cornerRadius: 10))
    }

    private func toggleFavourite() {
        if isFavourite {
            viewModel.removeFavourite(talk: talk)
        } else {
            viewModel.addFavourite(talk: talk)
        }
    }
}
