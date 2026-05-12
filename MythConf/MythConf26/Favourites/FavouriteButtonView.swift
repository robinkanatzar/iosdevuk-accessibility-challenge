//
//  FavouriteButtonView.swift
//  IOSDevuk26
//

import SwiftUI
import TipKit

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    let talk: Talk
    private let saveSessionTip = SaveSessionTip()

    private var isFavourite: Bool {
        viewModel.isFavourite(talk: talk)
    }

    var body: some View {
        Button {
            toggleFavourite()
        } label: {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .symbolVariant(isFavourite ? .fill : .none)
                .foregroundStyle(isFavourite ? .yellow : .secondary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
        }
        .accessibilityLabel(isFavourite ? "Remove \(talk.talkTitle) from favourites" : "Add \(talk.talkTitle) to favourites")
        .accessibilityValue(isFavourite ? "Favourited" : "Not favourited")
        .accessibilityHint(isFavourite ? "Removes this session from My Schedule" : "Adds this session to My Schedule")
        .accessibilityInputLabels([
            isFavourite ? "Remove from schedule" : "Add to schedule",
            "Favourite",
            talk.talkTitle
        ])
        .accessibilityAddTraits(isFavourite ? .isSelected : [])
        .buttonStyle(.plain)
        .symbolEffect(.bounce.down, value: isFavourite)
        .popoverTip(saveSessionTip, arrowEdge: .bottom)
    }

    private func toggleFavourite() {
        if isFavourite {
            viewModel.removeFavourite(talk: talk)
            FavouriteToggleFeedback.removed()
        } else {
            viewModel.addFavourite(talk: talk)
            SaveSessionTip.hasSavedFavourite = true
            saveSessionTip.invalidate(reason: .actionPerformed)
            FavouriteToggleFeedback.added()
        }
    }
}

#Preview {
    let viewModel = ViewModel()
    let talkID = UUID(uuidString: "C1001006-C100-4100-8100-100000000006")!
    let talk = viewModel.talkFrom(talkID: talkID)
    
    FavouriteButtonView(talk: talk)
        .environment(viewModel)
}
