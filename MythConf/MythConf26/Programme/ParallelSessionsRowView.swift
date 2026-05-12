//
//  ParallelSessionsRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row displaying two parallel sessions side by side.
struct ParallelSessionsRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let session: Session

    //Todo: check if this is right and make sence ?????

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                accessibilityLayout
            } else if horizontalSizeClass == .compact
                && verticalSizeClass == .regular
                && session.contentIDs.count > 1 {
                compactParallelLayout
            } else {
                horizontalLayout
            }
        }
        .padding()
    }

    private var shouldStackParallelCards: Bool {
        horizontalSizeClass == .compact && session.contentIDs.count > 1
    }

    private var accessibilityLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)
                .frame(maxWidth: .infinity, alignment: .leading)

            talkStack
        }
    }

    private var compactParallelLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

            talkStack
        }
    }

    private var horizontalLayout: some View {
        HStack(alignment: .top) {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

            HStack(alignment: .top) {
                ForEach(session.contentIDs, id: \.self) { talkID in
                    ParallelTalkCardView(talkID: talkID, session: session)
                }
            }
        }
    }

    private var talkStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(session.contentIDs, id: \.self) { talkID in
                ParallelTalkCardView(talkID: talkID, session: session)
            }
        }
    }
}

#Preview {
    let viewModel = ViewModel()
    let session = viewModel.confData.sessions[1][2]
    ParallelSessionsRowView(session: session)
        .environment(viewModel)
}
