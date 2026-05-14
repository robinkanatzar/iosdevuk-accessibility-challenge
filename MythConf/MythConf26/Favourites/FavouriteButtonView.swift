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
    /// When `true`, render at default toolbar/control size with no material
    /// backing — appropriate for `.toolbar` placements where an 88pt button
    /// would dominate the navigation bar. Defaults to `false` so the talk
    /// card overlay keeps its enlarged Mobility-friendly hit area.
    var compact: Bool = false
    /// When non-nil, overrides the displayed accessibility label so it
    /// stays frozen during the announcement sequence, preventing VoiceOver
    /// from auto-announcing the state change before our custom message
    /// finishes.
    @State private var labelOverride: Bool? = nil
    @AppStorage("hasSeenFavouritesHint") private var hasSeenFavouritesHint = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isFavourite: Bool { viewModel.isFavourite(talk: talk) }
    /// Drives the accessibility label — frozen during the announcement
    /// window so VoiceOver does not auto-read the new state
    /// mid-announcement.
    private var labelIsFavourite: Bool { labelOverride ?? isFavourite }

    var body: some View {
        Button {
            let wasAlreadyFavourite = isFavourite

            // Freeze the accessibility state at the pre-tap value so VoiceOver
            // does not auto-announce the change while our custom message is
            // queued.
            labelOverride = wasAlreadyFavourite

            if wasAlreadyFavourite {
                viewModel.removeFavourite(talk: talk)
                AccessibilityAnnouncer.shared.announce("Removed from favourites.")
            } else {
                viewModel.addFavourite(talk: talk)
                if hasSeenFavouritesHint {
                    AccessibilityAnnouncer.shared.announce("Added to favourites.")
                } else {
                    AccessibilityAnnouncer.shared.announce(
                        "Added to favourites. Switch to My Schedule to see all your saved sessions."
                    )
                    hasSeenFavouritesHint = true
                }
            }

            // Release the freeze after the announcement (plus retry window)
            // has had time to play. If VoiceOver is still focused on this
            // button it will then naturally re-read the element with its
            // updated label and selected state.
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                labelOverride = nil
            }
        } label: {
            iconView
        }
        .modifier(SizeModifier(compact: compact))
        .accessibilityLabel(labelIsFavourite ? "Remove from favourites" : "Add to favourites")
        .accessibilityHint(labelIsFavourite ? "Removes this session from your saved schedule" : "Adds this session to your saved schedule")
        .accessibilityInputLabels(["Favourite", "Star", "Save"])
        .sensoryFeedback(trigger: isFavourite) { _, newValue in
            newValue ? .success : .impact(weight: .light)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        if compact {
            bounceIfMotionAllowed(
                Image(systemName: isFavourite ? "star.fill" : "star")
                    .foregroundStyle(isFavourite ? .orange : .primary)
            )
        } else {
            bounceIfMotionAllowed(
                Image(systemName: isFavourite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(isFavourite ? .orange : .primary)
            )
            .padding(8)
            // Material backing keeps the star legible against tinted
            // session-type card backgrounds (especially the yellow
            // lightning-talks tint where a yellow star would vanish).
            .background(Circle().fill(.regularMaterial))
        }
    }

    /// `.symbolEffectsRemoved` only suppresses *indefinite* symbol effects;
    /// the discrete `.bounce` still plays on value-change. To honour Reduce
    /// Motion we must keep the `.symbolEffect` modifier out of the view
    /// tree entirely when the system setting is on.
    @ViewBuilder
    private func bounceIfMotionAllowed(_ image: some View) -> some View {
        if reduceMotion {
            image
        } else {
            image.symbolEffect(.bounce, value: isFavourite)
        }
    }

    /// Sizes the button for its placement context. The talk-card overlay
    /// gets an enlarged 88pt hit area; toolbar placements use the system
    /// default control size.
    private struct SizeModifier: ViewModifier {
        let compact: Bool
        func body(content: Content) -> some View {
            if compact {
                content
            } else {
                content
                    .frame(minWidth: 88, minHeight: 88, alignment: .bottomTrailing)
                    .contentShape(Rectangle())
            }
        }
    }
}
