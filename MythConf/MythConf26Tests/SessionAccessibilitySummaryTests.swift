import Testing
import Foundation
@testable import MythConf26

struct SessionAccessibilitySummaryTests {
    @Test
    func labelIncludesCoreSessionDetails() throws {
        let summary = SessionAccessibilitySummary(
            sessionType: "Talk",
            title: "Building Accessible SwiftUI Apps",
            speakers: ["Alex Taylor"],
            location: "Main Theatre",
            timeRange: AccessibleTimeRange(
                start: try Date("2026-09-07T09:30:00Z", strategy: .iso8601),
                end: try Date("2026-09-07T10:15:00Z", strategy: .iso8601)
            ),
            isFavourite: false
        )

        #expect(summary.label.contains("Talk"))
        #expect(summary.label.contains("Building Accessible SwiftUI Apps"))
        #expect(summary.label.contains("Alex Taylor"))
        #expect(summary.label.contains("Main Theatre"))
    }

    @Test
    func valueReflectsFavouriteState() throws {
        let timeRange = AccessibleTimeRange(
            start: try Date("2026-09-07T09:30:00Z", strategy: .iso8601),
            end: try Date("2026-09-07T10:15:00Z", strategy: .iso8601)
        )

        let unsavedSummary = SessionAccessibilitySummary(
            sessionType: "Talk",
            title: "A Talk",
            speakers: ["Speaker"],
            location: "Room 1",
            timeRange: timeRange,
            isFavourite: false
        )

        let savedSummary = SessionAccessibilitySummary(
            sessionType: "Talk",
            title: "A Talk",
            speakers: ["Speaker"],
            location: "Room 1",
            timeRange: timeRange,
            isFavourite: true
        )

        #expect(unsavedSummary.value == "Not saved")
        #expect(savedSummary.value == "Saved to My Schedule")
    }

    @Test
    func favouriteActionNameReflectsFavouriteState() throws {
        let timeRange = AccessibleTimeRange(
            start: try Date("2026-09-07T09:30:00Z", strategy: .iso8601),
            end: try Date("2026-09-07T10:15:00Z", strategy: .iso8601)
        )

        let unsavedSummary = SessionAccessibilitySummary(
            sessionType: "Talk",
            title: "A Talk",
            speakers: ["Speaker"],
            location: "Room 1",
            timeRange: timeRange,
            isFavourite: false
        )

        let savedSummary = SessionAccessibilitySummary(
            sessionType: "Talk",
            title: "A Talk",
            speakers: ["Speaker"],
            location: "Room 1",
            timeRange: timeRange,
            isFavourite: true
        )

        #expect(unsavedSummary.favouriteActionName == "Add to favourites")
        #expect(savedSummary.favouriteActionName == "Remove from favourites")
    }
}
