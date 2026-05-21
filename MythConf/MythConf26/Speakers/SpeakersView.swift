//
//  SpeakersView.swift
//  IOSDevuk26
//

import SwiftUI
import Accessibility

// MARK: - Main view
struct SpeakersView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var speakersSearchModel = SpeakersSearchModel()
    
    var body: some View {
        NavigationStack {
            SpeakersListContent(speakersSearchModel: speakersSearchModel)
                .searchable(text: $speakersSearchModel.searchText, prompt: "Search speakers")
                .navigationTitle("Speakers")
                .conferenceNavigationDestinations()
                .onAppear {
                    speakersSearchModel.setup(with: viewModel.confData.speakers)
                }
        }
    }
}

// MARK: - Subview
private struct SpeakersListContent: View {
    @Environment(\.isSearching) private var isSearching
    var speakersSearchModel: SpeakersSearchModel
    
    var body: some View {
        Group {
            if speakersSearchModel.filteredSpeakers.isEmpty {
                ContentUnavailableView {
                    Label("No speakers found", systemImage: "magnifyingglass")
                } description: {
                    Text("Try another query.")
                }
            } else {
                List(speakersSearchModel.filteredSpeakers) { speaker in
                    NavigationLink(value: SpeakerNavigationID(value: speaker.id)) {
                        SpeakerRowView(speakerID: speaker.id)
                    }
                }
            }
        }
    }
}

#Preview {
    SpeakersView()
        .environment(ViewModel())
}
