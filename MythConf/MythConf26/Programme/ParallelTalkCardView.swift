//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session

    var body: some View {
        NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
            VStack(alignment: .leading, spacing: 0) {
                session.sessionType.color
                    .frame(height: 4)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text(viewModel.talkTitleFrom(talkID: talkID))
                        .bold()
                        .appFont(.subheadline, useLexend: viewModel.useLexendFont)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.speakersFrom(talkID: talkID))
                        .appFont(.caption, useLexend: viewModel.useLexendFont)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .appFont(.caption, useLexend: viewModel.useLexendFont)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack {
                        Spacer()
                        FavouriteButtonView(talk: viewModel.talkFrom(talkID: talkID))
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(session.sessionType.color.opacity(0.1), in: .rect(cornerRadius: 10))
            .clipShape(.rect(cornerRadius: 10))
        }
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityValue(viewModel.isFavourite(talk: viewModel.talkFrom(talkID: talkID)) ? "Favourited" : "")
        .accessibilityAction(named: viewModel.isFavourite(talk: viewModel.talkFrom(talkID: talkID)) ? "Remove from favourites" : "Add to favourites") {
            toggleFavourite()
        }
        .buttonStyle(.plain)
    }

    private var accessibilityLabelText: String {
        "\(session.sessionType.displayName): \(viewModel.talkTitleFrom(talkID: talkID)), by \(viewModel.speakersFrom(talkID: talkID)), \(viewModel.locationNameFrom(talkID: talkID))"
    }
    private func toggleFavourite() {
        if viewModel.isFavourite(talk: viewModel.talkFrom(talkID: talkID)) {
            let talk = viewModel.talkFrom(talkID: talkID)
            viewModel.removeFavourite(talk: talk)
            AccessibilityNotification.Announcement("Removed from favourites").post()
        } else {
            let talk = viewModel.talkFrom(talkID: talkID)
            viewModel.addFavourite(talk: talk)
            AccessibilityNotification.Announcement("Added to favourites").post()
        }
    }
}
