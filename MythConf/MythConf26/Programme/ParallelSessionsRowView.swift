import SwiftUI

/// A row displaying parallel sessions. The layout adapts for accessibility text sizes.
struct ParallelSessionsRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let session: Session

    private var usesVerticalTalkLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
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

            HStack(alignment: .top) {
                talkCards
            }
        }
        .padding()
    }

    private var verticalLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            TimeColumnView(startTime: session.startTime, endTime: session.endTime)

            VStack(alignment: .leading, spacing: 12) {
                talkCards
            }
        }
        .padding()
    }

    @ViewBuilder
    private var talkCards: some View {
        ForEach(session.contentIDs, id: \.self) { talkID in
            ParallelTalkCardView(talkID: talkID, session: session)
        }
    }
}
