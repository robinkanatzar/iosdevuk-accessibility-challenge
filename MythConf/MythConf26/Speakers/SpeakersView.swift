//
//  SpeakersView.swift
//  IOSDevuk26
//

import SwiftUI

struct SpeakersView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var searchText = ""

    private var filteredSpeakers: [Speaker] {
        let sorted = viewModel.confData.speakers.sorted()
        if searchText.isEmpty { return sorted }
        return sorted.filter { $0.name.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredSpeakers) { speaker in
                NavigationLink(value: SpeakerNavigationID(value: speaker.id)) {
                    SpeakerRowView(speakerID: speaker.id)
                }
                .accessibilityLabel("""
                \(viewModel.speakerFrom(speakerID: speaker.id).name).
                \(accessibilityPreview(text: viewModel.speakerFrom(speakerID: speaker.id).speakerInfo))
                Double tap for full biography.
                """)
            }
            .searchable(text: $searchText, prompt: "Search speakers")
            .navigationTitle("Speakers")
            .conferenceNavigationDestinations()
        }
    }
    
    private func accessibilityPreview(
        text: String,
        maxLength: Int = 120
    ) -> String {
        if text.count <= maxLength {
            return text
        }

        return String(text.prefix(maxLength)) + "…"
    }
}

#Preview {
    SpeakersView()
        .environment(ViewModel())
}
