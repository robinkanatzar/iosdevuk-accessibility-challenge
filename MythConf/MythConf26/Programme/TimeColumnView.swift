//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// Shows a session's start and end times.
/// At standard sizes the times stack vertically in a fixed-width column;
/// at accessibility Dynamic Type sizes they flip to a horizontal "start – end"
/// row so the parent VStack (via AStack) doesn't waste vertical space.
struct TimeColumnView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let startTime: String
    let endTime: String
    var sessionCount: Int = 1
    var actsAsHeader: Bool = true

    var body: some View {
        timeContent
            .font(.caption)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(actsAsHeader ? .isHeader : [])
    }

    private var accessibilityLabel: String {
        String(localized: "\(sessionCount) session from \(startTime) to \(endTime)")
    }

    @ViewBuilder
    private var timeContent: some View {
        if dynamicTypeSize.isAccessibilitySize {
            HStack(spacing: 4) {
                Text(startTime)
                    .bold()
                    .monospacedDigit()
                Text("– \(endTime)")
                    .secondaryTextStyle()
                    .monospacedDigit()
            }
        } else {
            VStack(alignment: .trailing) {
                Text(startTime)
                    .bold()
                    .monospacedDigit()
                Text(endTime)
                    .secondaryTextStyle()
                    .monospacedDigit()
            }
            .frame(minWidth: 44, alignment: .trailing)
        }
    }
}
