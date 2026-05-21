//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.colorSchemeContrast) private var contrast
    let talkID: UUID
    let session: Session

    var body: some View {
        NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
            VStack(alignment: .leading, spacing: 0) {
                session.sessionType.color
                    .frame(height: 4)
                    .accessibilityHidden(true)

                if differentiateWithoutColor {
                    Label(session.sessionType.displayName, systemImage: session.sessionType.iconName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }

                VStack(alignment: .leading) {
                    if let status = session.liveStatusText {
                        Text(status)
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.green, in: Capsule())
                            .accessibilityHidden(true)
                    }
                    Text(viewModel.talkTitleFrom(talkID: talkID))
                        .bold()
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    Text(viewModel.speakersFrom(talkID: talkID))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack {
                        Spacer()
                        FavouriteButtonView(talk: viewModel.talkFrom(talkID: talkID))
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(contrast == .increased ? Color(.tertiarySystemBackground) : session.sessionType.color.opacity(0.05), in: .rect(cornerRadius: 10))
            .clipShape(.rect(cornerRadius: 10))
            .overlay {
                if contrast == .increased {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                }
            }
        }
        .accessibilityLabel({
            let statusPrefix = session.liveStatusText.map { "\($0). " } ?? ""
            return "\(statusPrefix)\(session.sessionType.displayName): \(viewModel.talkTitleFrom(talkID: talkID)), by \(viewModel.speakersFrom(talkID: talkID)), \(viewModel.locationNameFrom(talkID: talkID))"
        }())
        .accessibilityHint("Double tap to view session details")
        .accessibilityInputLabels([viewModel.talkTitleFrom(talkID: talkID)])
        .accessibilityCustomContent("Session Type", session.sessionType.displayName)
        .accessibilityCustomContent("Room", viewModel.locationNameFrom(talkID: talkID))
        .accessibilityAction(named: viewModel.isFavourite(talk: viewModel.talkFrom(talkID: talkID)) ? "Remove from favourites" : "Add to favourites") {
            let talk = viewModel.talkFrom(talkID: talkID)
            if viewModel.isFavourite(talk: talk) {
                viewModel.removeFavourite(talk: talk)
            } else {
                viewModel.addFavourite(talk: talk)
            }
        }
        .buttonStyle(.plain)
    }
}
