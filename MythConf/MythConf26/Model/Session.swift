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

    /// Spoken-friendly time range, e.g. "9 AM to 10:30 AM". Used in accessibility labels
    /// so VoiceOver doesn't read "15:00" as "fifteen zero" — and so en-GB locales (which
    /// suppress AM/PM in `Date.FormatStyle`) still pronounce a recognisable time.
    var timeRangeAccessible: String {
        "\(spokenTime(for: startTime)) to \(spokenTime(for: endTime))"
    }

    private func spokenTime(for date: Date) -> String {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour24 = comps.hour ?? 0
        let minute = comps.minute ?? 0
        let hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)
        let suffix = hour24 < 12 ? "AM" : "PM"
        if minute == 0 {
            return "\(hour12) \(suffix)"
        }
        return "\(hour12):\(String(format: "%02d", minute)) \(suffix)"
    }
}

