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
            }
            .overlay {
                if !searchText.isEmpty && filteredSpeakers.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText, prompt: "Search speakers")
            .onChange(of: searchText) { _, newValue in
                if !newValue.isEmpty {
                    let count = filteredSpeakers.count
                    UIAccessibility.post(notification: .announcement, argument: "\(count) speaker\(count == 1 ? "" : "s") found")
                }
            }
            .navigationTitle("Speakers")
            .conferenceNavigationDestinations()
        }
    }
}

#Preview {
    SpeakersView()
        .environment(ViewModel())
}
