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
            Group {
                if !searchText.isEmpty && filteredSpeakers.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(filteredSpeakers) { speaker in
                        NavigationLink(value: SpeakerNavigationID(value: speaker.id)) {
                            SpeakerRowView(speakerID: speaker.id)
                        }
                    }
                    // Tell VoiceOver users how many speakers are in the list
                    // (useful when navigating with a screen reader).
                    .accessibilityLabel("Speakers list, \(filteredSpeakers.count) \(filteredSpeakers.count == 1 ? "speaker" : "speakers")")
                }
            }
            .searchable(text: $searchText, prompt: "Search speakers")
            .navigationTitle("Speakers")
            .conferenceNavigationDestinations()

            .onChange(of: searchText) { _, newValue in
                guard !newValue.isEmpty else { return }
                let count = filteredSpeakers.count
                let message = count == 0
                ? "No speakers match \(newValue)"
                : "\(count) \(count == 1 ? "speaker" : "speakers") found"
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
    }
}

#Preview {
    SpeakersView()
        .environment(ViewModel())
}
