//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// A column showing a session's start and end times.
struct TimeColumnView: View {
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
        .frame(minWidth: 44, alignment: .trailing)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(startTime) to \(endTime)")
    }
}
