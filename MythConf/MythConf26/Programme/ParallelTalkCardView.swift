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
    var positionIndex: Int = 0
    var positionTotal: Int = 1

    private var combinedAccessibilityLabel: String {
        let title = viewModel.talkTitleFrom(talkID: talkID)
        let speakers = viewModel.speakersFrom(talkID: talkID)
        let location = viewModel.locationNameFrom(talkID: talkID)
        let kind: String
        switch session.sessionType {
        case .workshop:
            kind = String(localized: "Workshop", comment: "VoiceOver announces this before a workshop's title so users know it's a workshop slot, not a talk.")
        default:
            kind = String(localized: "Session", comment: "VoiceOver announces this before a talk's title to clarify the kind of slot.")
        }
        let base: String
        if positionTotal > 1 {
            base = String(localized: "\(title), by \(speakers), at \(location), \(positionIndex + 1) of \(positionTotal)")
        } else {
            base = String(localized: "\(title), by \(speakers), at \(location)")
        }
        return "\(kind), \(base)"
    }

    var body: some View {
        VStack(spacing: 0) {
            session.sessionType.color
                .frame(height: 4)
                .accessibilityHidden(true)
            HStack() {
                if let iconName = session.sessionType.iconName {
                    Image(systemName: iconName)
                        .font(.subheadline)
                        .foregroundStyle(session.sessionType.color)
                        .accessibilityHidden(true)
                }
                Spacer()
                FavouriteButtonView(talk: viewModel.talkFrom(talkID: talkID))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, -13)
                    .accessibilitySortPriority(0)
            }
            .padding(.horizontal)
            NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(viewModel.talkTitleFrom(talkID: talkID))
                                .bold()
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                        }
                        Text(viewModel.speakersFrom(talkID: talkID))
                            .font(.caption)
                            .secondaryTextStyle()
                            .multilineTextAlignment(.leading)
                        Text(viewModel.locationNameFrom(talkID: talkID))
                            .font(.caption)
                            .secondaryTextStyle()
                    }
                    .padding([.horizontal, .bottom])
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            }
            .accessibilityLabel(combinedAccessibilityLabel)
            .accessibilitySortPriority(1)
            .buttonStyle(.plain)
        }
        .accessibilityElement(children: .contain)
        .background(session.sessionType.color.opacity(0.1), in: .rect(cornerRadius: 10))
        .clipShape(.rect(cornerRadius: 10))
    }
}
