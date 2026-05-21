//
//  FavouriteButtonView.swift
//  IOSDevuk26
//

import SwiftUI

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    let talk: Talk

    private var isFavourite: Bool { viewModel.isFavourite(talk: talk) }

    var body: some View {
        Button {
            if isFavourite {
                viewModel.removeFavourite(talk: talk)
                AccessibilityNotification.Announcement("Removed from favourites").post()
            } else {
                viewModel.addFavourite(talk: talk)
                AccessibilityNotification.Announcement("Added to favourites").post()
            }
        } label: {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .foregroundStyle(isFavourite ? .yellow : .secondary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
        }
        .accessibilityLabel("Favourite")
        .accessibilityValue(isFavourite ? "On" : "Off")
        .accessibilityHint(isFavourite ? "Double tap to remove from favourites" : "Double tap to add to favourites")
        .accessibilityAddTraits(.isToggle)
        .sensoryFeedback(.impact(weight: .light), trigger: isFavourite)
    }
}
