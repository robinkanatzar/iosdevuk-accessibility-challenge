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
        startTime.formatted(date: .omitted, time: .shortened)
    }

    var endTimeText: String {
        endTime.formatted(date: .omitted, time: .shortened)
    }

    var timeRange: String { "\(startTimeText) – \(endTimeText)" }

    var accessibilityTimeRange: String {
        "Starts at \(startTimeText). Ends at \(endTimeText)."
    }
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
                return "Live"
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

    struct StatusDisplay {
        let status: LiveStatus
        let title: String
        let accessibilityLabel: String
        let symbolName: String
        let isVisible: Bool
    }

    private static let statusVisibilityThreshold: TimeInterval = 20 * 60
    private static let countdownThreshold: TimeInterval = 15 * 60

    func liveStatus(now: Date) -> LiveStatus {
        if now >= startTime && now <= endTime {
            return .live
        }
        if now < startTime {
            return .upcoming
        }
        return .ended
    }

    func statusDisplay(now: Date) -> StatusDisplay {
        let status = liveStatus(now: now)

        guard status == .upcoming else {
            return StatusDisplay(
                status: status,
                title: status.title,
                accessibilityLabel: status.title,
                symbolName: status.symbolName,
                isVisible: true
            )
        }

        let secondsUntilStart = startTime.timeIntervalSince(now)
        guard secondsUntilStart <= Self.statusVisibilityThreshold else {
            return StatusDisplay(
                status: status,
                title: status.title,
                accessibilityLabel: status.title,
                symbolName: status.symbolName,
                isVisible: false
            )
        }

        guard secondsUntilStart <= Self.countdownThreshold else {
            return StatusDisplay(
                status: status,
                title: status.title,
                accessibilityLabel: status.title,
                symbolName: status.symbolName,
                isVisible: true
            )
        }

        let minutesUntilStart = max(0, Int(ceil(secondsUntilStart / 60)))
        if minutesUntilStart < 1 {
            return StatusDisplay(
                status: status,
                title: "Starting now",
                accessibilityLabel: "Starting now",
                symbolName: status.symbolName,
                isVisible: true
            )
        }

        let minuteText = minutesUntilStart == 1 ? "minute" : "minutes"
        return StatusDisplay(
            status: status,
            title: "Starting in \(minutesUntilStart)m",
            accessibilityLabel: "Starting in \(minutesUntilStart) \(minuteText)",
            symbolName: status.symbolName,
            isVisible: true
        )
    }

    var isLive: Bool {
        liveStatus(now: Date()) == .live
    }
}
