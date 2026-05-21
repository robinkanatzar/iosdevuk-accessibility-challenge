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
        let talk = viewModel.talkFrom(talkID: talkID)
        let isFavourite = viewModel.isFavourite(talk: talk)
        
        NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
            VStack(alignment: .leading, spacing: 0) {
                session.sessionType.color
                    .frame(height: 4)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading) {
                    Text(viewModel.talkTitleFrom(talkID: talkID))
                        .bold()
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.speakersFrom(talkID: talkID))
                        .font(.caption).opacity(0.6)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .font(.caption).opacity(0.6)
                        .foregroundStyle(.primary)
                    Spacer()
                    HStack {
                        Spacer()
                        FavouriteButtonView(talk: viewModel.talkFrom(talkID: talkID))
                            .accessibilityHidden(true)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(session.sessionType.color.opacity(0.1), in: .rect(cornerRadius: 10))
            .clipShape(.rect(cornerRadius: 10))
        }
        .accessibilityLabel("\(session.sessionType.displayName): \(viewModel.talkTitleFrom(talkID: talkID)), by \(viewModel.speakersFrom(talkID: talkID)), \(viewModel.locationNameFrom(talkID: talkID)), \(isFavourite ? "Remove from favourites" : "Add to favourites")")
        .accessibilityAction(named: isFavourite ? "Remove from favourites" : "Add to favourites") {
            if viewModel.isFavourite(talk: talk) {
                viewModel.removeFavourite(talk: talk)
            } else {
                viewModel.addFavourite(talk: talk)
            }
        }
        .accessibilityHint("Double-tap for session details. Swipe up or down to toggle favourite status.")
        .buttonStyle(.plain)
    }
}
