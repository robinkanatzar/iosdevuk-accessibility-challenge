import SwiftUI

/// A fixed-width column showing a session's start and end times.
struct TimeColumnView: View {
    let timeRange: AccessibleTimeRange

    init(startTime: Date, endTime: Date) {
        self.timeRange = AccessibleTimeRange(start: startTime, end: endTime)
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Text(timeRange.visualText.components(separatedBy: " – ").first ?? "")
                .bold()
                .monospacedDigit()

            Text(timeRange.visualText.components(separatedBy: " – ").last ?? "")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .font(.caption)
        .frame(width: 52, alignment: .trailing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(timeRange.accessibilityLabel)
        .accessibilityValue(timeRange.accessibilityValue)
    }
}
