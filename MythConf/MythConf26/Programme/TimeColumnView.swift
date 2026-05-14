//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// A fixed-width column showing a session's start and end times.
struct TimeColumnView: View {
    /// Visible time strings — typically the two-digit zero-padded form
    /// ("09:30") for tabular alignment.
    let startTime: String
    let endTime: String
    /// Times spoken by VoiceOver. The visible form often reads with a
    /// pause between the hour and minutes; the shortened locale form
    /// ("9:30 am") reads naturally.
    let startTimeAccessibility: String
    let endTimeAccessibility: String
    /// Scales with Dynamic Type so the time column doesn't truncate at
    /// larger accessibility text sizes.
    @ScaledMetric(relativeTo: .caption) private var columnWidth: CGFloat = 44

    var body: some View {
        VStack(alignment: .trailing) {
            Text(startTime)
                .bold()
                .monospacedDigit()
            Text(endTime)
                .contrastAdaptiveSecondary()
                .monospacedDigit()
        }
        .font(.caption)
        .frame(minWidth: columnWidth, alignment: .trailing)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session start time \(startTimeAccessibility), session end time \(endTimeAccessibility)")
    }
}
