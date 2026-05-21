//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    let talkID: UUID
    let session: Session

    /// Tint opacity comes from the active theme so each palette can control
    /// how strongly session colours bleed into the card background.
    private var tintOpacity: Double {
        colorScheme == .dark ? theme.cardTintOpacity.dark : theme.cardTintOpacity.light
    }

    var body: some View {
        let talk = viewModel.talkFrom(talkID: talkID)
        let isFav = viewModel.isFavourite(talk: talk)

        NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
            VStack(alignment: .leading, spacing: 0) {
                SessionTypeBar(sessionType: session.sessionType)

                VStack(alignment: .leading) {
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
                        FavouriteButtonView(talk: talk)
                            .accessibilityHidden(true)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(theme.color(for: session.sessionType).opacity(tintOpacity), in: .rect(cornerRadius: 10))
            .clipShape(.rect(cornerRadius: 10))
        }
        .accessibilityLabel("\(session.sessionType.displayName): \(viewModel.talkTitleFrom(talkID: talkID)), by \(viewModel.speakersFrom(talkID: talkID)), \(viewModel.locationNameFrom(talkID: talkID))")
        .accessibilityInputLabels([viewModel.talkTitleFrom(talkID: talkID)])
        .accessibilityAction(named: isFav ? "Remove from favourites" : "Add to favourites") {
            if viewModel.isFavourite(talk: talk) {
                viewModel.removeFavourite(talk: talk)
            } else {
                viewModel.addFavourite(talk: talk)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ViewModel()
    let session = viewModel.confData.sessions.flatMap { $0 }.first { $0.containsTalk }!
    NavigationStack {
        ScrollView {
            LazyVStack {
                ParallelTalkCardView(talkID: session.contentIDs.first!, session: session)
                    .padding()
            }
        }
    }
    .environment(viewModel)
}
