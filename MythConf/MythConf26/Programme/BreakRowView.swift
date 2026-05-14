//
//  BreakRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
struct BreakRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    let session: Session

    private var backgroundOpacity: Double { (contrast == .increased || reduceTransparency) ? 0.25 : 0.12 }

    var body: some View {
        HStack {
            TimeColumnView(
                startTime: session.startTimeText,
                endTime: session.endTimeText,
                startTimeAccessibility: session.startTimeAccessibilityText,
                endTimeAccessibility: session.endTimeAccessibilityText
            )

            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    // Shape-based redundant cue alongside the tinted background
                    // so users with Differentiate Without Color enabled can
                    // tell break types apart by icon. Always shown so the
                    // visual treatment is consistent for every user.
                    Image(systemName: session.sessionType.symbolName)
                        .foregroundStyle(.primary)
                        .accessibilityHidden(true)
                    Text(session.sessionType.displayName)
                        .italic()
                        .foregroundStyle(.primary)
                }
                if let talkID = session.contentIDs.first {
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .font(.caption)
                        .contrastAdaptiveSecondary()
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(session.sessionType.color.opacity(backgroundOpacity))
        .overlay(
            differentiateWithoutColor ?
                Rectangle()
                    .strokeBorder(session.sessionType.color, lineWidth: 1.5)
                    .allowsHitTesting(false) : nil
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(session.sessionType.displayName), \(session.startTimeAccessibilityText) to \(session.endTimeAccessibilityText)")
    }
}
