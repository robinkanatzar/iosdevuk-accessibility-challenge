//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// A fixed-width column showing a session's start and end times.
struct TimeColumnView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    let startTime: String
    let endTime: String
    var accessibleRange: String? = nil
    
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
        .frame(width: 44, alignment: .trailing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibleRange ?? "from \(startTime), session end time \(endTime)")
        .accessibilityAddTraits(.isStaticText)
    }
}
