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
    private var lastAnnouncementTime: Date = .distantPast
    
    func setup(with speakers: [Speaker]) {
        self.allSpeakers = speakers.sorted()
        if filteredSpeakers.isEmpty && searchText.isEmpty {
            filteredSpeakers = allSpeakers
        }
    }
    
    private func performClear() {
        filteredSpeakers = allSpeakers
        postHighPriorityAnnouncement("Showing all \(allSpeakers.count) speakers")
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
        
        if filteredSpeakers.isEmpty {
            postHighPriorityAnnouncement("No speakers found. Try another query")
        } else {
            let speakerText = filteredSpeakers.count == 1 ? "speaker" : "speakers"
            postHighPriorityAnnouncement("Showing \(filteredSpeakers.count) \(speakerText)")
        }
    }
    
    private func postHighPriorityAnnouncement(_ message: String) {
        guard Date().timeIntervalSince(lastAnnouncementTime) > 0.2 else { return }
        lastAnnouncementTime = Date()
        
        var announcement = AttributedString(message)
        announcement.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(announcement).post()
    }
}
