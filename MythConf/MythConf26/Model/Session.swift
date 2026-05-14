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

    /// Time string optimised for VoiceOver. The visible `startTimeText` is
    /// 24-hour zero-padded ("09:30", "14:00") which speech engines read
    /// digit-by-digit ("zero nine thirty", "fourteen zero zero"). For
    /// accessibility the time is reformatted to 12-hour with AM/PM, the
    /// colon is stripped to a space, and on-the-hour times drop the
    /// minute digits entirely so "16:00" reads as "4 PM" rather than
    /// "four zero zero".
    var startTimeAccessibilityText: String { Self.accessibilityTimeText(from: startTime) }
    var endTimeAccessibilityText: String { Self.accessibilityTimeText(from: endTime) }

    private static func accessibilityTimeText(from date: Date) -> String {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour24 = comps.hour ?? 0
        let minute = comps.minute ?? 0

        let hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)
        let period = hour24 < 12 ? "AM" : "PM"

        if minute == 0 {
            return "\(hour12) \(period)"
        }
        return "\(hour12) \(String(format: "%02d", minute)) \(period)"
    }

    var timeRange: String { "\(startTimeText) – \(endTimeText)" }

    /// VoiceOver-friendly version of `timeRange`. Uses the natural-language
    /// 12-hour AM/PM time strings and joins them with " to " so the spoken
    /// phrase is "9 30 AM to 10 15 AM" rather than "zero nine thirty dash
    /// ten fifteen".
    var timeRangeAccessibilityText: String {
        "\(startTimeAccessibilityText) to \(endTimeAccessibilityText)"
    }
}

