//
//  SpeakersView.swift
//  IOSDevuk26
//

import SwiftUI
import TipKit

struct SpeakersView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var searchText = ""
    private let speakerSearchTip = SpeakerSearchTip()

    private var filteredSpeakers: [Speaker] {
        let sorted = viewModel.confData.speakers.sorted()
        if searchText.isEmpty { return sorted }
        return sorted.filter { $0.name.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredSpeakers.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView(
                        "No Speakers Found",
                        systemImage: "person.crop.circle.badge.questionmark",
                        description: Text("No speakers match \(searchText).")
                    )
                } else {
                    List {
                        if searchText.isEmpty {
                            TipView(speakerSearchTip)
                                .listRowBackground(Color(.systemBackground))
                        }

                        ForEach(filteredSpeakers) { speaker in
                            NavigationLink(value: SpeakerNavigationID(value: speaker.id)) {
                                SpeakerRowView(speakerID: speaker.id)
                            }
                            .listRowBackground(Color(.systemBackground))
                            .accessibilityIdentifier("speakers.row.\(speaker.id)")
                            .accessibilityHint("Shows speaker details")
                        }
                    }
                    .accessibilityIdentifier("speakers.list")
                }
            }
            .onAppear {
                SpeakerSearchTip.hasViewedSpeakers = true
            }
            .searchable(text: $searchText, prompt: "Search speakers")
            .onChange(of: searchText) { _, newValue in
                guard !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                SpeakerSearchTip.hasSearchedSpeakers = true
                speakerSearchTip.invalidate(reason: .actionPerformed)
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
