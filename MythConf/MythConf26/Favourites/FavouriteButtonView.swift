import SwiftUI

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    let talk: Talk

    private var isFavourite: Bool {
        viewModel.isFavourite(talk: talk)
    }

    private var accessibilityLabel: String {
        isFavourite ? "Remove from favourites" : "Add to favourites"
    }

    private var accessibilityValue: String {
        isFavourite ? "Saved to My Schedule" : "Not saved"
    }

    var body: some View {
        Button {
            toggleFavourite()
        } label: {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .foregroundStyle(isFavourite ? .yellow : .secondary)
                .frame(minWidth: 44, minHeight: 44)
        }
        .conferenceButtonAccessibility(
            label: accessibilityLabel,
            hint: "Updates whether \(talk.talkTitle) appears in My Schedule.",
            value: accessibilityValue,
            inputLabels: [
                accessibilityLabel,
                "Favourite",
                "Save",
                "Star",
                talk.talkTitle
            ]
        )
    }

    private func toggleFavourite() {
        if isFavourite {
            viewModel.removeFavourite(talk: talk)
        } else {
            viewModel.addFavourite(talk: talk)
        }
    }
}
