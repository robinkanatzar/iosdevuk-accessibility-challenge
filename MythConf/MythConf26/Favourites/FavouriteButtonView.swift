import SwiftUI

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel

    @State private var addedFeedbackTrigger = false
    @State private var removedFeedbackTrigger = false

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

    private var symbolName: String {
        isFavourite ? "star.fill" : "star"
    }

    private var symbolColor: Color {
        isFavourite ? .yellow : .secondary
    }

    var body: some View {
        Button {
            toggleFavourite()
        } label: {
            Image(systemName: symbolName)
                .foregroundStyle(symbolColor)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityHidden(true)
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
        .sensoryFeedback(.success, trigger: addedFeedbackTrigger)
        .sensoryFeedback(.impact(weight: .light), trigger: removedFeedbackTrigger)
    }

    private func toggleFavourite() {
        if isFavourite {
            viewModel.removeFavourite(talk: talk)
            removedFeedbackTrigger.toggle()
        } else {
            viewModel.addFavourite(talk: talk)
            addedFeedbackTrigger.toggle()
        }
    }
}
