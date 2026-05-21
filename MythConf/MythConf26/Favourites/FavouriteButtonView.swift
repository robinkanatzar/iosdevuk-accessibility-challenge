//
//  FavouriteButtonView.swift
//  IOSDevuk26
//

import SwiftUI

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    let talk: Talk

    var body: some View {
        Button {
            toggleFavourite()
        } label: {
            Image(systemName: viewModel.isFavourite(talk: talk) ? "star.fill" : "star")
                .foregroundStyle(viewModel.isFavourite(talk: talk) ? .yellow : .secondary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
        }
        .accessibilityLabel(viewModel.isFavourite(talk: talk) ? "Remove from favourites" : "Add to favourites")
        .sensoryFeedback(trigger: viewModel.isFavourite(talk: talk)) { _, isNowFavourite in
            guard viewModel.hapticFeedbackEnabled else { return nil }
            return isNowFavourite ? SensoryFeedback.success : SensoryFeedback.impact(weight: .light)
        }
    }

    private func toggleFavourite() {
        if viewModel.isFavourite(talk: talk) {
            viewModel.removeFavourite(talk: talk)
            AccessibilityNotification.Announcement("Removed from favourites").post()
        } else {
            viewModel.addFavourite(talk: talk)
            AccessibilityNotification.Announcement("Added to favourites").post()
        }
    }
}
