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
    
    var startTimeAccessible: String {
        startTime.formatted(date: .omitted, time: .shortened)
    }
    
    var endTimeAccessible: String {
        endTime.formatted(date: .omitted, time: .shortened)
    }
    
    var accessibleTimeRange: String {
        "from \(startTimeAccessible) to \(endTimeAccessible)"
    }
}

