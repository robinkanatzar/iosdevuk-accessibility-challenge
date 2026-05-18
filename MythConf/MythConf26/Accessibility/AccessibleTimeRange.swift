import Foundation

/// Provides visual and VoiceOver-friendly time range strings for conference sessions.
struct AccessibleTimeRange: Equatable {
    let start: Date
    let end: Date

    var visualStartTime: String {
        visualTime(for: start)
    }

    var visualEndTime: String {
        visualTime(for: end)
    }

    var visualText: String {
        "\(visualStartTime) – \(visualEndTime)"
    }

    var accessibilityLabel: String {
        "\(spokenTime(for: start)) to \(spokenTime(for: end))"
    }

    var accessibilityValue: String {
        "Starts \(spokenTime(for: start)), ends \(spokenTime(for: end))"
    }

    private func visualTime(for date: Date) -> String {
        date.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
    }

    private func spokenTime(for date: Date) -> String {
        date.formatted(
            .dateTime
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.twoDigits)
        )
    }
}
