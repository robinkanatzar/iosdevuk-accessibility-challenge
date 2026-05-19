//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    let talkID: UUID
    let session: Session
    
    var body: some View {
        NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .leading) {
                    session.sessionType.color
                        .frame(height: differentiateWithoutColor ? 12 : 4)
                    
                    if differentiateWithoutColor {
                        Image(systemName: session.sessionType.icon)
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.leading, 6)
                    }
                }
                .accessibilityHidden(true)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Image(systemName: session.sessionType.icon)
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text(session.sessionType.displayName)
                            .font(.caption2)
                            .textCase(.uppercase)
                    }
                    .foregroundStyle(session.sessionType.color)
                    .accessibilityHidden(true) // Already in the combined label below
                    
                    Text(viewModel.talkTitleFrom(talkID: talkID))
                        .bold()
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.speakersFrom(talkID: talkID))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .font(.caption)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(session.sessionType.displayName): \(viewModel.talkTitleFrom(talkID: talkID)), by \(viewModel.speakersFrom(talkID: talkID)), at \(viewModel.locationNameFrom(talkID: talkID)), \(session.accessibleTimeRange)"
        )
        .accessibilityHint("Double tap to view session details")
        .accessibilityValue(viewModel.isFavourite(talk: viewModel.talkFrom(talkID: talkID)) ? "Favourited" : "Not favourited")
        .accessibilityAction(named: viewModel.isFavourite(talk: viewModel.talkFrom(talkID: talkID)) ? "Remove from favourites" : "Add to favourites") {
            let talk = viewModel.talkFrom(talkID: talkID)
            let willAdd = !viewModel.isFavourite(talk: talk)
            if willAdd {
                viewModel.addFavourite(talk: talk)
            } else {
                viewModel.removeFavourite(talk: talk)
            }
            announceFavouriteChange(willAdd: willAdd, talkTitle: talk.talkTitle)
        }
        .buttonStyle(.plain)
    }
    
    private func announceFavouriteChange(willAdd: Bool, talkTitle: String) {
        let message = willAdd
        ? "Added \(talkTitle) to favourites"
        : "Removed \(talkTitle) from favourites"
        var attributed = AttributedString(message)
        attributed.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(attributed).post()
    }
}
