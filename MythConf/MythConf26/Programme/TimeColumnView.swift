//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// A fixed-width column showing a session's start and end times.
struct TimeColumnView: View {
//    let startTime: Date
//    let endTime: Date
    let startTimeText: String
    let endTimeText: String
    let spokenTimeRange: String
    
    var body: some View {
        HStack {
            Text("\(startTimeText) - \(endTimeText)")
                .bold()
                .monospacedDigit()
            Spacer()
        }
        .font(.caption)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenTimeRange)
        .accessibilityAddTraits(.isHeader)
    }
}
