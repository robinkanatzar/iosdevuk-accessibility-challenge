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
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .foregroundStyle(Color(.label))
        .font(.caption)
        .frame(minWidth: 44, alignment: .trailing)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityHidden(true)
    }
}

#Preview {
    TimeColumnView(startTime: "09:00", endTime: "10:30")
        .padding()
}
