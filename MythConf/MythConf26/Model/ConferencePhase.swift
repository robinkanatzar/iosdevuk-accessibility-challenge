//
//  ConferencePhase.swift
//  IOSDevuk26
//

import Foundation

/// High-level temporal position relative to the whole conference, with
/// the during-conference cases enriched by which day we're on. Drives
/// the banner at the top of `ProgrammeView`. Pure function of the bundled
/// session data plus an injectable `now`, so it's exhaustively testable.
enum ConferencePhase: Equatable {
    /// Conference hasn't started yet.
    case upcoming(daysUntil: Int)
    /// We're on one of the conference days.
    case inProgress(dayNumber: Int, totalDays: Int)
    /// Conference has finished.
    case finished

    var bannerText: String {
        switch self {
        case .upcoming(let days):
            switch days {
            case 0: return "Conference starts today"
            case 1: return "Conference starts tomorrow"
            default: return "Conference starts in \(days) days"
            }
        case .inProgress(let day, let total): return "Day \(day) of \(total)"
        case .finished: return "Conference has ended"
        }
    }

    var bannerSymbolName: String {
        switch self {
        case .upcoming: return "calendar"
        case .inProgress: return "circle.dotted"
        case .finished: return "checkmark.circle"
        }
    }
}

extension ConfData {
    /// Computes the conference phase relative to a given `now`. Each
    /// inner array of `sessions` is one day; the first session's
    /// `startTime` is treated as the start of that day. Days are
    /// counted by `Calendar.current.isDate(_:inSameDayAs:)` so a missing
    /// or out-of-order day doesn't throw the count off.
    func phase(now: Date = .now) -> ConferencePhase {
        let nonEmptyDays = sessions.compactMap { $0.first?.startTime }
        guard let firstDay = nonEmptyDays.first,
              let lastDayEnd = sessions.last?.last?.endTime else {
            return .upcoming(daysUntil: 0)
        }

        let calendar = Calendar.current
        let totalDays = nonEmptyDays.count

        // If today matches one of the day starts, we're in-progress.
        if let dayIndex = nonEmptyDays.firstIndex(where: { calendar.isDate($0, inSameDayAs: now) }) {
            return .inProgress(dayNumber: dayIndex + 1, totalDays: totalDays)
        }

        if now > lastDayEnd { return .finished }

        // Otherwise we're before the conference — compute calendar-day gap.
        let startDay = calendar.startOfDay(for: firstDay)
        let today = calendar.startOfDay(for: now)
        let days = max(0, calendar.dateComponents([.day], from: today, to: startDay).day ?? 0)
        return .upcoming(daysUntil: days)
    }
}
