//
//  SpeakerDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SpeakerDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let speakerID: String

    @State private var isInlinePhotoVisible = true

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Header
                AStack(hAlignment: .top, vAlignment: .leading) {
                    SpeakerPhotoView(speaker: speaker, size: 80)
                        .onScrollVisibilityChange(threshold: 0.1) { visible in
                            isInlinePhotoVisible = visible
                        }

                    VStack(alignment: .leading) {
                        Text(speaker.name)
                            .font(.title2)
                            .bold()
                        if !speaker.social.isEmpty {
                            SocialLinksView(social: speaker.social)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                        .font(.headline)
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
        .toolbar {
            if !isInlinePhotoVisible {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(UIImage(named: speaker.photoName) != nil ? speaker.photoName : "default")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                            .clipShape(.circle)
                        Text(speaker.name)
                            .font(.headline)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(speaker.name)
                }
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
