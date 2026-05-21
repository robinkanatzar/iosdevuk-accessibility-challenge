//
//  ParallelSessionsRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row displaying two parallel sessions side by side.
struct ParallelSessionsRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var isAccessibilitySize: Bool {
        dynamicTypeSize >= .accessibility1
    }

    let session: Session

    var body: some View {
        if isAccessibilitySize {
            VStack(alignment: .leading) {
                TimeHorizontalColumnView(startTime: session.startTimeText, endTime: session.endTimeText)
                ForEach(session.contentIDs, id: \.self) { talkID in
                    ParallelTalkCardView(talkID: talkID, session: session)
                }
            }
            .padding()
        } else {
            HStack(alignment: .top) {
                TimeVerticalColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

                HStack(alignment: .top) {
                    ForEach(session.contentIDs, id: \.self) { talkID in
                        ParallelTalkCardView(talkID: talkID, session: session)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ViewModel()
    let session = viewModel.confData.sessions.flatMap { $0 }.first { $0.containsTalk }!
    NavigationStack {
        ScrollView {
            LazyVStack(spacing: 0) {
                ParallelSessionsRowView(session: session)
            }
        }
    }
    .environment(viewModel)
}
