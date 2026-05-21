//
//  FavouriteButtonView.swift
//  IOSDevuk26
//

import SwiftUI

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    @ScaledMetric private var starSize: CGFloat = 18
    @ScaledMetric private var sparklesSize: CGFloat = 10
    @ScaledMetric private var sparklesOffsetX: CGFloat = 6
    @ScaledMetric private var sparklesOffsetY: CGFloat = 3
    @ScaledMetric private var tapSize: CGFloat = 44
    let talk: Talk

    private var isFavourite: Bool { viewModel.isFavourite(talk: talk) }

    var body: some View {
        Button {
            if isFavourite {
                viewModel.removeFavourite(talk: talk)
            } else {
                viewModel.addFavourite(talk: talk)
            }
        } label: {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .font(.system(size: starSize, weight: .semibold))
                .foregroundStyle(isFavourite ? Color.yellow : Color.textSecondary)
                .overlay(alignment: .topTrailing) {
                    if isFavourite {
                        Image(systemName: "sparkles")
                            .font(.system(size: sparklesSize, weight: .bold))
                            .foregroundStyle(Color.yellow)
                            .offset(x: sparklesOffsetX, y: -sparklesOffsetY)
                    }
                }
                .frame(width: max(44, tapSize), height: max(44, tapSize))
                .contentShape(.rect)
        }
        .accessibilityLabel(isFavourite ? Text("Remove session from favourites") : Text("Favourite"))
        .accessibilityInputLabels([
            "Favourite", "Favorite", "Star", "Bookmark",
            "Save", "Add to schedule", "Remove from schedule"
        ])
        .sensoryFeedback(.success, trigger: isFavourite)
    }
}
