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
                    SpeakerPhotoView(speaker: speaker, size: 80, accessibilityMode: .decorative)

                    VStack(alignment: .leading) {
                        Text(speaker.name)
                            .dyslexiaReadingFont(.title2, size: 22, weight: .bold)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityLabel { label in
                                Text("Speaker:")
                                label
                            }
                        if !speaker.social.isEmpty {
                            SocialLinksView(social: speaker.social, speakerName: speaker.name)
                        }
                    }

                    Spacer()
                }

                Divider()
                    .padding(.vertical)

                // Bio
                if !speaker.speakerInfo.isEmpty {
                    Text(speaker.speakerInfo)
                        .dyslexiaReadingFont(.body, size: 17)
                        .accessibilityLabel { label in
                            Text("Biography:")
                            label
                        }
                    Divider()
                        .padding(.vertical)
                }

                // Sessions
                let speakerTalks = talksWithSessions()
                if !speakerTalks.isEmpty {
                    Text("Sessions")
                        .font(.headline)
                        .accessibilityLabel { _ in
                            Text("Sessions by \(speaker.name)")
                        }
                        .accessibilityIdentifier("speakerDetail.sessionsHeading")
                        .accessibilityAddTraits(.isHeader)


                    ForEach(speakerTalks, id: \.talkID) { item in
                        NavigationLink(value: TalkReference(talkID: item.talkID, session: item.session)) {
                            TalkSummaryView(talkID: item.talkID, session: item.session)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Session: \(viewModel.talkTitleFrom(talkID: item.talkID))")
                        .accessibilityValue("\(item.session.accessibilityTimeRange) \(viewModel.locationNameFrom(talkID: item.talkID))")
                        .accessibilityHint("Opens session details")
                    }
                }
            }
            .padding()
        }
        .accessibilityIdentifier("speakerDetail.root.\(speaker.id)")
        .navigationTitle("Speaker Details")
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
        SpeakerDetailView(speakerID: "SarahThornton")
    }
    .environment(ViewModel())
}
