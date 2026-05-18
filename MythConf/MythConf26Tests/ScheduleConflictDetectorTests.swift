import Testing
import Foundation
@testable import MythConf26

@MainActor
struct ScheduleConflictDetectorTests {
    @Test
    func returnsConflictWhenSessionContainsMultipleSavedTalks() throws {
        let session = Session(
            startTime: try Date("2026-09-07T09:30:00Z", strategy: .iso8601),
            endTime: try Date("2026-09-07T10:15:00Z", strategy: .iso8601),
            sessionType: .talk,
            sessionCount: 2,
            contentIDs: [
                UUID(),
                UUID()
            ]
        )

        let conflicts = ScheduleConflictDetector.conflicts(in: [[session]])

        #expect(conflicts.count == 1)
        #expect(conflicts.first?.conflictCount == 2)
    }

    @Test
    func ignoresSingleSavedTalkSession() throws {
        let session = Session(
            startTime: try Date("2026-09-07T09:30:00Z", strategy: .iso8601),
            endTime: try Date("2026-09-07T10:15:00Z", strategy: .iso8601),
            sessionType: .talk,
            sessionCount: 1,
            contentIDs: [
                UUID()
            ]
        )

        let conflicts = ScheduleConflictDetector.conflicts(in: [[session]])

        #expect(conflicts.isEmpty)
    }

    @Test
    func ignoresNonTalkActivities() throws {
        let session = Session(
            startTime: try Date("2026-09-07T12:00:00Z", strategy: .iso8601),
            endTime: try Date("2026-09-07T13:00:00Z", strategy: .iso8601),
            sessionType: .lunch,
            sessionCount: 2,
            contentIDs: [
                UUID(),
                UUID()
            ]
        )

        let conflicts = ScheduleConflictDetector.conflicts(in: [[session]])

        #expect(conflicts.isEmpty)
    }
}
