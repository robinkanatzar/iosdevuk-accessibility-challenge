//
//  BreakRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
struct BreakRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let session: Session
    
    private var locationName: String? {
        session.contentIDs.first.map { viewModel.locationNameFrom(talkID: $0) }
    }
    
    var body: some View {
        rowLayout
            .padding()
            .frame(maxWidth: .infinity)
            .background(session.sessionType.color.opacity(differentiateWithoutColor ? 0.25 : 0.12))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(combinedLabel)
            .accessibilityAddTraits(.isStaticText)
    }
    
    @ViewBuilder
    private var rowLayout: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 6) {
                TimeColumnView(
                    startTime: session.startTimeText,
                    endTime: session.endTimeText,
                    accessibleRange: session.accessibleTimeRange
                )
                content
            }
        } else {
            HStack {
                TimeColumnView(
                    startTime: session.startTimeText,
                    endTime: session.endTimeText,
                    accessibleRange: session.accessibleTimeRange
                )
                content
                Spacer()
            }
        }
    }
    
    private var content: some View {
        HStack {
            // SF Symbol for the session type — visible cue that doesn't rely on colour.
            Image(systemName: session.sessionType.icon)
                .foregroundStyle(session.sessionType.color)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading) {
                Text(session.sessionType.displayName)
                    .italic()
                    .foregroundStyle(.primary)
                if let locationName {
                    Text(locationName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var combinedLabel: String {
        var parts = [
            session.sessionType.displayName,
            session.accessibleTimeRange
        ]
        if let locationName {
            parts.append("at \(locationName)")
        }
        return parts.joined(separator: ", ")
    }
}
