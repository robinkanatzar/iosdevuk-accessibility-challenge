import Testing
import Foundation
@testable import MythConf26

struct AccessibleTimeRangeTests {
    @Test
    func visualTextIncludesStartEndAndRangeSeparator() throws {
        let range = AccessibleTimeRange(
            start: try Date("2026-09-07T09:30:00Z", strategy: .iso8601),
            end: try Date("2026-09-07T10:15:00Z", strategy: .iso8601)
        )

        #expect(!range.visualStartTime.isEmpty)
        #expect(!range.visualEndTime.isEmpty)
        #expect(range.visualText.contains("–"))
    }

    @Test
    func accessibilityValueIncludesStartAndEnd() throws {
        let range = AccessibleTimeRange(
            start: try Date("2026-09-07T09:30:00Z", strategy: .iso8601),
            end: try Date("2026-09-07T10:15:00Z", strategy: .iso8601)
        )

        #expect(range.accessibilityValue.contains("Starts"))
        #expect(range.accessibilityValue.contains("ends"))
    }
}
