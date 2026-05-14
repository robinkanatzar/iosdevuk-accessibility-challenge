//
//  SessionLiveStatus.swift
//  IOSDevuk26
//

import Foundation

/// Live-status classification of a `Session` relative to the wall clock.
///
/// Used by `ParallelTalkCardView` to render a "Now" or "Starts in N min"
/// badge during the conference, and by `MyScheduleView` to surface the
/// user's next-up favourite session at the top of the screen. Every
/// factory and formatter takes an explicit `now` parameter so the
/// behaviour is fully testable without relying on the real wall clock.
enum SessionLiveStatus: Equatable {
    /// More than the look-ahead window away — no badge.
    case upcoming
    /// 1–15 minutes away — "Starts in N min".
    case startingSoon(minutesUntil: Int)
    /// Currently underway — "Now".
    case live
    /// Past the end time — no badge.
    case finished

    /// Look-ahead window (in seconds) inside which an upcoming session
    /// is promoted to `.startingSoon`. 15 minutes balances "soon enough
    /// to act on" against "long enough to find your way".
    static let startingSoonWindow: TimeInterval = 15 * 60

    static func status(for session: Session, now: Date = .now) -> SessionLiveStatus {
        if now < session.startTime {
            let secondsUntil = session.startTime.timeIntervalSince(now)
            if secondsUntil <= startingSoonWindow {
                // Round *up* so 4 min 5 s reads "5 min", not "4 min" —
                // matches a glanceable human reading of the wait.
                let minutes = max(1, Int(ceil(secondsUntil / 60)))
                return .startingSoon(minutesUntil: minutes)
            }
            return .upcoming
        }
        if now <= session.endTime { return .live }
        return .finished
    }

    /// Spoken prefix prepended to the talk card's accessibility label.
    /// Empty for states with no badge so VoiceOver doesn't speak the
    /// same talk twice in different states.
    var accessibilityPrefix: String {
        switch self {
        case .upcoming, .finished: return ""
        case .live: return "Now. "
        case .startingSoon(let minutes):
            return minutes == 1 ? "Starts in 1 minute. " : "Starts in \(minutes) minutes. "
        }
    }

    /// Short text shown as a visible badge on the talk card. `nil` for
    /// states that don't warrant one.
    var badgeText: String? {
        switch self {
        case .upcoming, .finished: return nil
        case .live: return "Now"
        case .startingSoon(let minutes): return "In \(minutes) min"
        }
    }
}
