//
//  SpeakersView.swift
//  IOSDevuk26
//

import SwiftUI
import TipKit

struct SpeakersView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var searchText = ""
    @State private var isShowingSettings = false
    @AccessibilityFocusState private var isSettingsButtonFocused: Bool
    private let speakerSearchTip = SpeakerSearchTip()

    private var filteredSpeakers: [Speaker] {
        let sorted = viewModel.confData.speakers.sorted()
        if searchText.isEmpty { return sorted }
        return sorted.filter { $0.name.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            speakerContent
            .navigationTitle("Speakers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsToolbarButton {
                        isShowingSettings = true
                    }
                    .accessibilityFocused($isSettingsButtonFocused)
                }
            }
            .sheet(isPresented: $isShowingSettings, onDismiss: restoreSettingsButtonFocus) {
                SettingsView()
            }
            .conferenceNavigationDestinations()
        }
    }

    @ViewBuilder
    private var speakerContent: some View {
        if filteredSpeakers.isEmpty && !searchText.isEmpty {
            ContentUnavailableView(
                "No Speakers Found",
                systemImage: "person.crop.circle.badge.questionmark",
                description: Text("No speakers match \(searchText).")
            )
            .onAppear {
                SpeakerSearchTip.hasViewedSpeakers = true
            }
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
                }
            }
            .accessibilityIdentifier("speakers.list")
            .onAppear {
                SpeakerSearchTip.hasViewedSpeakers = true
            }
            .searchable(text: $searchText, prompt: "Search speakers")
            .onChange(of: searchText) { _, newValue in
                guard !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                SpeakerSearchTip.hasSearchedSpeakers = true
                speakerSearchTip.invalidate(reason: .actionPerformed)
            }
        }
    }

    private func restoreSettingsButtonFocus() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            isSettingsButtonFocused = true
        }
    }
}

#Preview {
    SpeakersView()
        .environment(ViewModel())
}
