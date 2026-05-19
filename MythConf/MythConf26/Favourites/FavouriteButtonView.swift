//
//  FavouriteButtonView.swift
//  IOSDevuk26
//

import SwiftUI
import UIKit

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    let talk: Talk
    
    private var isFavourite: Bool { viewModel.isFavourite(talk: talk) }
    
    private var isFavouriteBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isFavourite(talk: talk) },
            set: { newValue in
                if newValue {
                    viewModel.addFavourite(talk: talk)
                } else {
                    viewModel.removeFavourite(talk: talk)
                }
            }
        )
    }
    
    var body: some View {
        Button {
            let willAdd = !isFavourite
            if willAdd {
                viewModel.addFavourite(talk: talk)
            } else {
                viewModel.removeFavourite(talk: talk)
            }
            announceChange(willAdd: willAdd)
        } label: {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .foregroundStyle(isFavourite ? .yellow : .secondary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
        }
        .accessibilityLabel("Favourite")
        .accessibilityValue(isFavourite ? "Favourited" : "")
        .accessibilityHint(isFavourite
                           ? "Double tap to remove from My Schedule"
                           : "Double tap to add to My Schedule")
        
        .accessibilityInputLabels([
            "favourite", "favorite", "star", "save", "bookmark"
        ])
        // Haptic feedback on toggle.
        .sensoryFeedback(.success, trigger: isFavourite)
    }
    
    private func announceChange(willAdd: Bool) {
        let message = willAdd
        ? "Added \(talk.talkTitle) to favourites"
        : "Removed \(talk.talkTitle) from favourites"
        var attributed = AttributedString(message)
        attributed.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(attributed).post()
    }
}

