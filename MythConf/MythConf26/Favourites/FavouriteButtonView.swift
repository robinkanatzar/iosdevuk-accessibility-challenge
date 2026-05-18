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
            if viewModel.isFavourite(talk: talk) {
                viewModel.removeFavourite(talk: talk)
            } else {
                viewModel.addFavourite(talk: talk)
            }
        } label: {
            Image(systemName: viewModel.isFavourite(talk: talk) ? "star.fill" : "star")
                .font(.title)
                .foregroundStyle(viewModel.isFavourite(talk: talk) ? .yellow : .secondary)
        }
        .accessibilityLabel(viewModel.isFavourite(talk: talk) ? "Remove from favourites" : "Add to favourites")
    }
}
