//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

struct TimeVerticalColumnView: View {
    let startTime: String
    let endTime: String

    var body: some View {
        VStack(alignment: .center) {
            Text(startTime)
                .bold()
                .monospacedDigit()
            Text(endTime)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .font(.caption)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session start time \(startTime), session end time \(endTime)")
    }
}

struct TimeHorizontalColumnView: View {
    let startTime: String
    let endTime: String

    var body: some View {
        HStack(alignment: .center) {
            Text(startTime)
                .bold()
            Text("⏤")
            Text(endTime)
            Spacer()
        }
        .monospacedDigit()
        .font(.caption)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session start time \(startTime), session end time \(endTime)")
    }
}

// MARK: - Preview

#Preview {
    TimeVerticalColumnView(startTime: "10:00", endTime: "11:00")
    TimeHorizontalColumnView(startTime: "10:00", endTime: "11:00")
}
