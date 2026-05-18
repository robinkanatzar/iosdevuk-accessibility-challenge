import SwiftUI

struct SessionDetailSpeakersSectionView: View {
    let speakers: [Speaker]

    private var heading: String {
        speakers.count == 1 ? "Speaker" : "Speakers"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(heading)
                .font(.headline)
                .conferenceHeaderAccessibility(label: heading)

            ForEach(speakers) { speaker in
                NavigationLink(value: SpeakerNavigationID(value: speaker.id)) {
                    SpeakerRowView(speakerID: speaker.id)
                }
                .buttonStyle(.plain)
                .conferenceLinkAccessibility(
                    label: "Speaker, \(speaker.name)",
                    hint: "Opens speaker details.",
                    inputLabels: [
                        speaker.name,
                        "Speaker",
                        "Open \(speaker.name)"
                    ]
                )
            }
        }
    }
}

#Preview {
    SessionDetailSpeakersSectionView(speakers: [])
        .environment(ViewModel())
}
