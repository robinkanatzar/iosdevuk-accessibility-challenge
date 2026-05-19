//
//  SpeakerDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SpeakerDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let speakerID: String
    
    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Header
                Group {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 12) {
                            SpeakerPhotoView(speaker: speaker, size: 120, isDecorative: false)
                            headerText
                        }
                    } else {
                        HStack(alignment: .top) {
                            SpeakerPhotoView(speaker: speaker, size: 80, isDecorative: true)
                            headerText
                            Spacer()
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Bio
                if !speaker.speakerInfo.isEmpty {
                    Text(speaker.speakerInfo)
                        .accessibilityLabel("Bio: \(speaker.speakerInfo)")
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
                        .accessibilityHint("Double tap to view session details")
                    }
                }
            }
            .padding()
        }
        .navigationTitle(speaker.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerText: some View {
        VStack(alignment: .leading) {
            Text(speaker.name)
                .font(.title2)
                .bold()
                .accessibilityAddTraits(.isHeader)
            if !speaker.social.isEmpty {
                SocialLinksView(social: speaker.social, speakerName: speaker.name)
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

