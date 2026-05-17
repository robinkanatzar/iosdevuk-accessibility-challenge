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
    @Environment(ViewModel.self) private var viewModel
    let session: Session
    let daySessions: [Session]

    private var schedulePosition: ViewModel.SchedulePosition? {
        viewModel.schedulePosition(for: session, in: daySessions)
    }

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
            timeAndPositionColumn
                .frame(maxWidth: .infinity, alignment: .leading)

            talkStack
        }
    }

    private var compactParallelLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            timeAndPositionColumn

            talkStack
        }
    }

    private var horizontalLayout: some View {
        HStack(alignment: .top) {
            timeAndPositionColumn

            HStack(alignment: .top) {
                ForEach(session.contentIDs, id: \.self) { talkID in
                    ParallelTalkCardView(talkID: talkID, session: session, schedulePosition: schedulePosition)
                }
            }
        }
    }

    private var timeAndPositionColumn: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

            if let schedulePosition {
                NowNextBadge(position: schedulePosition)
            }

            Spacer(minLength: 0)
        }
    }

    private var talkStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(session.contentIDs, id: \.self) { talkID in
                ParallelTalkCardView(talkID: talkID, session: session, schedulePosition: schedulePosition)
            }
        }
    }
}

#Preview {
    let viewModel = ViewModel()
    let session = viewModel.confData.sessions[1][2]
    ParallelSessionsRowView(session: session, daySessions: viewModel.confData.sessions[1])
        .environment(viewModel)
}
