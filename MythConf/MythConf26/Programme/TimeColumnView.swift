//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// A fixed-width column showing a session's start and end times. Hidden from VoiceOver
/// because the parent row's combined label already announces the time range.
struct TimeColumnView: View {
    @ScaledMetric private var width: CGFloat = 44
    let startTime: String
    let endTime: String

    var body: some View {
        VStack(alignment: .trailing) {
            Text(startTime)
                .bold()
                .monospacedDigit()
            Text(endTime)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .font(.caption)
        .frame(width: width, alignment: .trailing)
        .accessibilityHidden(true)
    }
}
