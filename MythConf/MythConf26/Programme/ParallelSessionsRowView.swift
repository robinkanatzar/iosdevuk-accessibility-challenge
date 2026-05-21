//
//  ParallelSessionsRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row displaying parallel sessions side by side at standard text sizes.
/// At accessibility sizes the row reflows: time appears on top as a single line,
/// and cards stack vertically at full width so titles and descriptions stay readable.
struct ParallelSessionsRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let session: Session
    var rotorNamespace: Namespace.ID? = nil

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(session.startTimeText) – \(session.endTimeText)")
                    .font(.headline)
                    .monospacedDigit()
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 8) {
                    cardForEach
                }
            }
            .padding()
        } else {
            HStack(alignment: .top) {
                TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

                HStack(alignment: .top) {
                    cardForEach
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var cardForEach: some View {
        ForEach(Array(session.contentIDs.enumerated()), id: \.element) { index, talkID in
            ParallelTalkCardView(
                talkID: talkID,
                session: session,
                parallelHint: session.contentIDs.count > 1
                    ? "Parallel session \(index + 1) of \(session.contentIDs.count)"
                    : nil,
                rotorNamespace: rotorNamespace
            )
        }
    }
}
