import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session

    private var talk: Talk {
        viewModel.talkFrom(talkID: talkID)
    }

    private var summary: SessionAccessibilitySummary {
        viewModel.sessionAccessibilitySummary(for: talkID, in: session)
    }

    var body: some View {
        NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
            VStack(alignment: .leading, spacing: 0) {
                session.sessionType.color
                    .frame(height: 4)
                    .conferenceDecorativeAccessibility()

                VStack(alignment: .leading) {
                    Text(talk.talkTitle)
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
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(session.sessionType.color.opacity(0.1), in: .rect(cornerRadius: 10))
            .clipShape(.rect(cornerRadius: 10))
        }
        .conferenceLinkAccessibility(
            label: summary.label,
            hint: summary.hint,
            value: summary.value,
            inputLabels: summary.inputLabels
        )
        .accessibilityAction(named: summary.favouriteActionName) {
            toggleFavourite()
        }
        .buttonStyle(.plain)
    }

    private func toggleFavourite() {
        if viewModel.isFavourite(talk: talk) {
            viewModel.removeFavourite(talk: talk)
        } else {
            viewModel.addFavourite(talk: talk)
        }
    }
}
