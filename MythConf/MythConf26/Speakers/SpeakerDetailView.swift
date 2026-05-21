//
//  SpeakerDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SpeakerDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let speakerID: String

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Header
                HStack(alignment: .top) {
                    SpeakerPhotoView(speaker: speaker, size: 80)

                    VStack(alignment: .leading) {
                        Text(speaker.name)
                            .appFont(.title2, useLexend: viewModel.useLexendFont)
                            .bold()
                        if !speaker.social.isEmpty {
                            SocialLinksView(social: speaker.social)
                        }
                    }

                    Spacer()
                }

                Divider()
                    .padding(.vertical)

                // Bio
                if !speaker.speakerInfo.isEmpty {
                    Text(speaker.speakerInfo)
                    Divider()
                        .padding(.vertical)
                }

                // Sessions
                let speakerTalks = talksWithSessions()
                if !speakerTalks.isEmpty {
                    Text("Sessions")
                        .appFont(.headline, useLexend: viewModel.useLexendFont)
                        .accessibilityAddTraits(.isHeader)

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

#Preview {
    NavigationStack {
        SpeakerDetailView(speakerID: "")
    }
    .environment(ViewModel())
}
