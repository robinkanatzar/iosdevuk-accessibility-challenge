//
//  SpeakersSearchModel.swift
//  MythConf26
//
//  Created by Steven Hill on 14/05/2026.
//

import Accessibility

@Observable
final class SpeakersSearchModel {
    var searchText = "" {
        didSet {
            if searchText.isEmpty {
                searchTask?.cancel()
                performClear()
            } else {
                scheduleDebouncedSearch()
            }
        }
    }
    private(set) var filteredSpeakers: [Speaker] = []
    private var allSpeakers: [Speaker] = []
    private var searchTask: Task<Void, Never>?
    
    func setup(with speakers: [Speaker]) {
        self.allSpeakers = speakers.sorted()
        if filteredSpeakers.isEmpty && searchText.isEmpty {
            filteredSpeakers = allSpeakers
        }
    }
    
    private func performClear() {
        filteredSpeakers = allSpeakers
        let message = "Search text cleared. Showing all \(allSpeakers.count) speakers"
        AccessibilityNotification.Announcement(message).post()
    }
    
    private func scheduleDebouncedSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            performSearch()
        }
    }
    
    private func performSearch() {
        filteredSpeakers = allSpeakers.filter { $0.name.localizedStandardContains(searchText) }
        postAccessibilityAnnouncement()
    }
    
    private func postAccessibilityAnnouncement() {
        if filteredSpeakers.isEmpty {
            AccessibilityNotification.Announcement("No speakers found").post()
        } else {
            AccessibilityNotification.Announcement("\(filteredSpeakers.count) \(filteredSpeakers.count == 1 ? "speaker" : "speakers") found").post()
        }
    }
}
