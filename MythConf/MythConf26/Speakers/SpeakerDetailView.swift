//
//  SpeakerDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SpeakerDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var isAccessibilitySize: Bool {
        dynamicTypeSize >= .accessibility1
    }

    let speakerID: String

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Header
                HStack(alignment: .top) {
                    SpeakerPhotoView(speaker: speaker, size: 80)
                        .padding(.top, isAccessibilitySize ? 6 : 0)

                    VStack(alignment: .leading) {
                        Text(speaker.name)
                            .accessibilityHidden(true)
                            .font(.title2)
                            .bold()
                            .padding(isAccessibilitySize ? [.leading] : [.leading, .top])
                        if !speaker.social.isEmpty {
                            SocialLinksView(social: speaker.social)
                        }
                    }

                    Spacer()
                }

                Divider()
                    .padding(.vertical)
                    .accessibilityHidden(true)

                // Bio
                if !speaker.speakerInfo.isEmpty {
                    Text(speaker.speakerInfo)
                    Divider()
                        .padding(.vertical)
                        .accessibilityHidden(true)
                }

                // Sessions
                let speakerTalks = talksWithSessions()
                if !speakerTalks.isEmpty {
                    Text("Sessions")
                        .accessibilityAddTraits(.isHeader)
                        .font(.headline)

                    ForEach(speakerTalks, id: \.talkID) { item in
                        NavigationLink(value: TalkReference(talkID: item.talkID, session: item.session)) {
                            TalkSummaryView(talkID: item.talkID, session: item.session)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(speaker.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func talksWithSessions() -> [(talkID: UUID, session: Session)] {
        speaker.talkIDs.compactMap { talkID in
            for day in viewModel.confData.sessions {
                for session in day {
                    if session.contentIDs.contains(talkID) {
                        return (talkID: talkID, session: session)
                    }
                }
            }
            return nil
        }
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ViewModel()
    NavigationStack {
        SpeakerDetailView(speakerID: viewModel.confData.speakers.first!.id)
    }
    .environment(viewModel)
}
