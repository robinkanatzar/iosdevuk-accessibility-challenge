//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session
    var parallelHint: String? = nil
    var rotorNamespace: Namespace.ID? = nil

    private var talk: Talk { viewModel.talkFrom(talkID: talkID) }
    private var isFavourite: Bool { viewModel.isFavourite(talk: talk) }

    var body: some View {
        NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
            VStack(alignment: .leading, spacing: 0) {
                session.sessionType.color
                    .frame(height: 4)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    SessionTypeBadge(type: session.sessionType)
                    Text(viewModel.talkTitleFrom(talkID: talkID))
                        .bold()
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.speakersFrom(talkID: talkID))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack {
                        Spacer()
                        FavouriteButtonView(talk: talk)
                            .accessibilityHidden(true)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(session.sessionType.color.opacity(0.1), in: .rect(cornerRadius: 10))
            .clipShape(.rect(cornerRadius: 10))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(isFavourite ? "Favourited" : "")
        .accessibilityHint("Opens session details")
        .accessibilityAction(named: isFavourite ? "Remove from favourites" : "Add to favourites") {
            if isFavourite {
                viewModel.removeFavourite(talk: talk)
                AccessibilityNotification.Announcement("Removed from favourites").post()
            } else {
                viewModel.addFavourite(talk: talk)
                AccessibilityNotification.Announcement("Added to favourites").post()
            }
        }
        .buttonStyle(.plain)
        .modifier(RotorEntryModifier(id: talkID, namespace: rotorNamespace))
    }

    private var accessibilityLabel: String {
        var parts: [String] = ["\(session.timeRangeAccessible)."]
        if let parallelHint {
            parts.append("\(parallelHint).")
        }
        parts.append("\(session.sessionType.displayName).")
        parts.append("\(viewModel.talkTitleFrom(talkID: talkID)).")
        parts.append("By \(viewModel.speakersFrom(talkID: talkID)).")
        parts.append("\(viewModel.locationNameFrom(talkID: talkID)).")
        return parts.joined(separator: " ")
    }
}

/// Conditionally applies `.accessibilityRotorEntry` so the same card view can be reused
/// in contexts that don't have a rotor (e.g. My Schedule).
private struct RotorEntryModifier: ViewModifier {
    let id: UUID
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let namespace {
            content.accessibilityRotorEntry(id: id, in: namespace)
        } else {
            content
        }
    }
}
