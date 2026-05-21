//
//  SpeakerDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SpeakerDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var photoSize: CGFloat = 80
    let speakerID: String

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                headerSection

                Divider()
                    .padding(.vertical)

                if !speaker.speakerInfo.isEmpty {
                    Text("About")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text(speaker.speakerInfo)
                    Divider()
                        .padding(.vertical)
                }

                let speakerTalks = talksWithSessions()
                if !speakerTalks.isEmpty {
                    Text("Sessions")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(speakerTalks, id: \.talkID) { item in
                        NavigationLink(value: TalkReference(talkID: item.talkID, session: item.session)) {
                            TalkSummaryView(talkID: item.talkID, session: item.session)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens session details")
                    }
                }
            }
            .padding()
        }
        .navigationTitle(speaker.name)
        .navigationBarTitleDisplayMode(.inline)
        .resetVoiceOverFocusOnAppear()
    }

    @ViewBuilder
    private var headerSection: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .top))

        layout {
            SpeakerPhotoView(speaker: speaker, size: photoSize)

            VStack(alignment: .leading) {
                Text(speaker.name)
                    .font(.title2)
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                if !speaker.social.isEmpty {
                    SocialLinksView(social: speaker.social)
                }
            }

            if !dynamicTypeSize.isAccessibilitySize {
                Spacer()
            }
        }
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
