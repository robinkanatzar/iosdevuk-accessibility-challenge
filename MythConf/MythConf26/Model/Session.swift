//
//  Session.swift
//  TalkGenerator
//
//  Created by Chris Price on 29/06/2022.
//

import Foundation

struct Session: Codable, Identifiable, Hashable {
    var id = UUID()
    let startTime: Date
    let endTime: Date
    let sessionType: SessionType
    let sessionCount: Int
    var contentIDs: [UUID] = []

    var dayAndDate: String {
        startTime.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    var containsTalk: Bool {
        return sessionType == .talk || sessionType == .workshop
    }

    var startTimeText: String {
        startTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }

    var endTimeText: String {
        endTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }

    var timeRange: String { "\(startTimeText) – \(endTimeText)" }

    var startTimeAccessibilityText: String {
        startTime.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits))
            .replacingOccurrences(of: ":00", with: "")
    }

    var endTimeAccessibilityText: String {
        endTime.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits))
            .replacingOccurrences(of: ":00", with: "")
    }

    var timeRangeAccessibilityText: String {
        "\(startTimeAccessibilityText) to \(endTimeAccessibilityText)"
    }

    enum SessionLiveStatus {
        case upcoming, startingSoon, live, ended
    }

    var liveStatus: SessionLiveStatus {
        let now = Date.now
        if now > endTime { return .ended }
        if now >= startTime { return .live }
        if now >= startTime.addingTimeInterval(-900) { return .startingSoon }
        return .upcoming
    }

    var liveStatusText: String? {
        switch liveStatus {
        case .live: return "Now"
        case .startingSoon:
            let mins = Int(startTime.timeIntervalSince(Date.now) / 60) + 1
            return "In \(mins) min"
        default: return nil
        }
    }
}

