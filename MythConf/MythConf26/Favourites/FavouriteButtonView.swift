//
//  FavouriteButtonView.swift
//  IOSDevuk26
//

import SwiftUI

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.theme) private var theme
    let talk: Talk

    var body: some View {
        Button {
            if viewModel.isFavourite(talk: talk) {
                viewModel.removeFavourite(talk: talk)
            } else {
                viewModel.addFavourite(talk: talk)
            }
        } label: {
            Image(systemName: viewModel.isFavourite(talk: talk) ? "star.fill" : "star")
                .foregroundStyle(viewModel.isFavourite(talk: talk) ? theme.accent : Color.secondary)
        }
        .accessibilityLabel(viewModel.isFavourite(talk: talk) ? "Remove from favourites" : "Add to favourites")
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: viewModel.isFavourite(talk: talk))
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ViewModel()
    FavouriteButtonView(talk: viewModel.confData.talks.first!)
        .environment(viewModel)
}
