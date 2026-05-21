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
                .accessibilityHint("Opens speaker profile")
            }
            .searchable(text: $searchText, prompt: "Search speakers")
            .navigationTitle("Speakers")
            .conferenceNavigationDestinations()
            .toolbarBackground(.background, for: .navigationBar)
        }
    }
}

// MARK: - Preview

#Preview {
    SpeakersView()
        .environment(ViewModel())
}
