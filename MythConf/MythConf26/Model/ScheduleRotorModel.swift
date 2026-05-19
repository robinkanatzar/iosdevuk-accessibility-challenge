import Foundation
import SwiftUI

enum ScheduleRotorCategory: String, CaseIterable {
    case liveSessions = "Live Sessions"
    case upcomingSessions = "Upcoming Sessions"
    case favouritedSessions = "Favourited Sessions"
    case breaks = "Breaks"
}

struct ScheduleRotorEntry: Identifiable {
    let id: String
    let label: String
    let targetID: String
}

enum ScheduleRotorTargetID {
    static func talk(_ talkID: UUID) -> String {
        "schedule.rotor.talk.\(talkID.uuidString)"
    }

    static func breakSession(_ sessionID: UUID) -> String {
        "schedule.rotor.break.\(sessionID.uuidString)"
    }
}

extension ViewModel.SchedulePosition {
    var accessibilityText: String {
        switch self {
        case .now:
            return "Now"
        case .next:
            return "Next"
        }
    }
}

enum ScheduleRotorEntries {
    static func talkSessions(in sessions: [Session]) -> [(session: Session, talkID: UUID)] {
        sessions.filter(\.containsTalk).flatMap { session in
            session.contentIDs.map { (session, $0) }
        }
    }

    static func liveEntries(
        in sessions: [Session],
        viewModel: ViewModel
    ) -> [ScheduleRotorEntry] {
        let now = viewModel.currentDate
        let talkEntries = talkSessions(in: sessions).compactMap { session, talkID -> ScheduleRotorEntry? in
            guard session.liveStatus(now: now) == .live else { return nil }
            return ScheduleRotorEntry(
                id: "live-\(talkID.uuidString)",
                label: viewModel.talkTitleFrom(talkID: talkID),
                targetID: ScheduleRotorTargetID.talk(talkID)
            )
        }

        let breakEntries = sessions.compactMap { session -> ScheduleRotorEntry? in
            guard !session.containsTalk,
                  session.sessionType != .dummy,
                  session.liveStatus(now: now) == .live else { return nil }
            return ScheduleRotorEntry(
                id: "live-break-\(session.id.uuidString)",
                label: session.sessionType.displayName,
                targetID: ScheduleRotorTargetID.breakSession(session.id)
            )
        }

        return talkEntries + breakEntries
    }

    static func upcomingEntries(
        in sessions: [Session],
        viewModel: ViewModel
    ) -> [ScheduleRotorEntry] {
        let now = viewModel.currentDate
        let talkEntries = talkSessions(in: sessions).compactMap { session, talkID -> ScheduleRotorEntry? in
            guard session.liveStatus(now: now) == .upcoming else { return nil }
            return ScheduleRotorEntry(
                id: "upcoming-\(talkID.uuidString)",
                label: "\(viewModel.talkTitleFrom(talkID: talkID)). Starts at \(session.startTimeText)",
                targetID: ScheduleRotorTargetID.talk(talkID)
            )
        }

        let breakEntries = sessions.compactMap { session -> ScheduleRotorEntry? in
            guard !session.containsTalk,
                  session.sessionType != .dummy,
                  session.liveStatus(now: now) == .upcoming else { return nil }
            return ScheduleRotorEntry(
                id: "upcoming-break-\(session.id.uuidString)",
                label: "\(session.sessionType.displayName). Starts at \(session.startTimeText)",
                targetID: ScheduleRotorTargetID.breakSession(session.id)
            )
        }

        return talkEntries + breakEntries
    }

    static func favouritedEntries(
        in sessions: [Session],
        viewModel: ViewModel
    ) -> [ScheduleRotorEntry] {
        talkSessions(in: sessions).compactMap { _, talkID in
            guard viewModel.favouriteIds.contains(talkID) else { return nil }
            return ScheduleRotorEntry(
                id: "favourite-\(talkID.uuidString)",
                label: viewModel.talkTitleFrom(talkID: talkID),
                targetID: ScheduleRotorTargetID.talk(talkID)
            )
        }
    }

    static func breakEntries(in sessions: [Session], now: Date) -> [ScheduleRotorEntry] {
        sessions
            .filter { !$0.containsTalk && $0.sessionType != .dummy }
            .map { session in
                ScheduleRotorEntry(
                    id: "break-\(session.id.uuidString)",
                    label: "\(session.sessionType.displayName). \(session.accessibilityTimeRange(now: now))",
                    targetID: ScheduleRotorTargetID.breakSession(session.id)
                )
            }
    }

}

extension View {
    func scheduleAccessibilityRotors(
        entries: [ScheduleRotorCategory: [ScheduleRotorEntry]],
        namespace: Namespace.ID
    ) -> some View {
        self
            .accessibilityRotorIfNotEmpty(.liveSessions, entries: entries, namespace: namespace)
            .accessibilityRotorIfNotEmpty(.upcomingSessions, entries: entries, namespace: namespace)
            .accessibilityRotorIfNotEmpty(.favouritedSessions, entries: entries, namespace: namespace)
            .accessibilityRotorIfNotEmpty(.breaks, entries: entries, namespace: namespace)
    }

    @ViewBuilder
    private func accessibilityRotorIfNotEmpty(
        _ category: ScheduleRotorCategory,
        entries: [ScheduleRotorCategory: [ScheduleRotorEntry]],
        namespace: Namespace.ID
    ) -> some View {
        let categoryEntries = entries[category] ?? []
        if categoryEntries.isEmpty {
            self
        } else {
            self.accessibilityRotor(category.rawValue) {
                ForEach(categoryEntries) { entry in
                    AccessibilityRotorEntry(LocalizedStringKey(entry.label), id: entry.targetID, in: namespace)
                }
            }
        }
    }
}
