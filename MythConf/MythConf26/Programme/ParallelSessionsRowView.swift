//
//  ParallelSessionsRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row displaying two parallel sessions side by side.
struct ParallelSessionsRowView: View {
    let session: Session

    var body: some View {
        AStack(hAlignment: .top, vAlignment: .leading, vSpacing: 8) {
            TimeColumnView(
                startTime: session.startTimeText,
                endTime: session.endTimeText,
                sessionCount: session.contentIDs.count
            )

            AStack(hAlignment: .top, vAlignment: .leading, vSpacing: 8) {
                ForEach(Array(session.contentIDs.enumerated()), id: \.element) { index, talkID in
                    ParallelTalkCardView(
                        talkID: talkID,
                        session: session,
                        positionIndex: index,
                        positionTotal: session.contentIDs.count
                    )
                }
            }
        }
        .padding()
    }
}
