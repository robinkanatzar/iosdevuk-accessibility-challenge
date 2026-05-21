//
//  BreakRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
struct BreakRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.colorSchemeContrast) private var contrast
    let session: Session

    var body: some View {
        HStack {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

            VStack(alignment: .leading) {
                Label(session.sessionType.displayName, systemImage: session.sessionType.iconName)
                    .italic()
                    .foregroundStyle(.primary)
                if let talkID = session.contentIDs.first {
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(contrast == .increased ? Color(.tertiarySystemBackground) : session.sessionType.color.opacity(0.12))
        .overlay {
            if contrast == .increased {
                Rectangle()
                    .stroke(Color.primary.opacity(0.3), lineWidth: 0.5)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(session.startTimeAccessibilityText) to \(session.endTimeAccessibilityText), \(session.sessionType.displayName)")
    }
}
