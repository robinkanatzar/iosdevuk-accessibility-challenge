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
}

// MARK: - Live Status

extension Session {

    enum LiveStatus {
        case upcoming
        case live
        case ended

        var title: String {
            switch self {
            case .upcoming:
                return "Starting Soon"
            case .live:
                return "Live Now"
            case .ended:
                return "Ended"
            }
        }

        var symbolName: String {
            switch self {
            case .upcoming:
                return "clock.badge"
            case .live:
                return "dot.radiowaves.left.and.right"
            case .ended:
                return "checkmark.circle"
            }
        }
    }

//    var liveStatus: LiveStatus {
//        let now = Date()
//
//        if now >= startTime && now <= endTime {
//            return .live
//        }
//
//        if now < startTime {
//            return .upcoming
//        }
//
//        return .ended
//    }

    func liveStatus(now: Date) -> LiveStatus {
        if now >= startTime && now <= endTime {
            return .live
        }
        if now < startTime {
            return .upcoming
        }
        return .ended
    }

//    var isLive: Bool {
//        liveStatus == .live
//    }

    var isLive: Bool {
        liveStatus(now: Date()) == .live
    }
}
