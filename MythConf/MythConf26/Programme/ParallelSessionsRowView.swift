import SwiftUI

/// A row displaying parallel sessions. The layout adapts for accessibility text sizes.
struct ParallelSessionsRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let session: Session

    private var usesVerticalTalkLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var timeRange: AccessibleTimeRange {
        AccessibleTimeRange(start: session.startTime, end: session.endTime)
    }

    private var accessibilityLabel: String {
        let sessionText = session.contentIDs.count == 1
            ? "1 session"
            : "\(session.contentIDs.count) parallel sessions"

        return "\(timeRange.accessibilityLabel), \(sessionText)"
    }

    var body: some View {
        if usesVerticalTalkLayout {
            verticalLayout
        } else {
            horizontalLayout
        }
    }

    private var horizontalLayout: some View {
        HStack(alignment: .top) {
            TimeColumnView(startTime: session.startTime, endTime: session.endTime)
                .accessibilitySortPriority(2)

            HStack(alignment: .top) {
                talkCards
            }
            .accessibilitySortPriority(1)
        }
        .padding()
        .accessibilityHint(accessibilityLabel)
    }

    private var verticalLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            TimeColumnView(startTime: session.startTime, endTime: session.endTime)
                .accessibilitySortPriority(2)

            VStack(alignment: .leading, spacing: 12) {
                talkCards
            }
            .accessibilitySortPriority(1)
        }
        .padding()
        .accessibilityHint(accessibilityLabel)
    }

    @ViewBuilder
    private var talkCards: some View {
        ForEach(session.contentIDs, id: \.self) { talkID in
            ParallelTalkCardView(talkID: talkID, session: session)
        }
    }
}
