//
//  BreakRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
/// At accessibility sizes the row reflows: time appears on top as a single line,
/// with type and location stacked below at full width.
struct BreakRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let session: Session

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(session.startTimeText) – \(session.endTimeText)")
                        .font(.headline)
                        .monospacedDigit()
                        .accessibilityHidden(true)
                    contentStack
                }
            } else {
                HStack {
                    TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)
                    contentStack
                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(session.sessionType.color.opacity(0.12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isStaticText)
    }

    private var contentStack: some View {
        VStack(alignment: .leading) {
            Text(session.sessionType.displayName)
                .italic()
                .foregroundStyle(.primary)
            if let talkID = session.contentIDs.first {
                Text(viewModel.locationNameFrom(talkID: talkID))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var accessibilityLabel: String {
        var parts = ["\(session.timeRangeAccessible).", "\(session.sessionType.displayName)."]
        if let talkID = session.contentIDs.first {
            parts.append("\(viewModel.locationNameFrom(talkID: talkID)).")
        }
        return parts.joined(separator: " ")
    }
}
