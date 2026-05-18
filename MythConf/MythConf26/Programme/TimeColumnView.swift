//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// A fixed-width column showing a session's start and end times.
struct TimeColumnView: View {
    let startTime: String
    let endTime: String
    
    var body: some View {
        HStack {
            Text("\(startTime) - \(endTime)")
                .bold()
                .monospacedDigit()
            Spacer()
        }
        .font(.caption)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session start time \(startTime), session end time \(endTime)")
        .accessibilityAddTraits(.isHeader)
    }
}
