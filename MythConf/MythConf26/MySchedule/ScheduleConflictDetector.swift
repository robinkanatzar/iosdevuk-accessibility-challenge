import Foundation

struct ScheduleConflict: Identifiable, Equatable {
    let id: UUID
    let session: Session
    let talkIDs: [UUID]

    init(session: Session) {
        self.id = session.id
        self.session = session
        self.talkIDs = session.contentIDs
    }

    var conflictCount: Int {
        talkIDs.count
    }

    var timeRange: AccessibleTimeRange {
        AccessibleTimeRange(start: session.startTime, end: session.endTime)
    }
}

@MainActor
enum ScheduleConflictDetector {
    static func conflicts(in daySessions: [[Session]]) -> [ScheduleConflict] {
        daySessions
            .flatMap { $0 }
            .filter { session in
                session.containsTalk && session.contentIDs.count > 1
            }
            .map { session in
                ScheduleConflict(session: session)
            }
    }
}
