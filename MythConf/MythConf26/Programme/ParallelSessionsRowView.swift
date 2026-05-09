//
//  ParallelSessionsRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row displaying two parallel sessions side by side.
struct ParallelSessionsRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let session: Session

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(session.contentIDs, id: \.self) { talkID in
                        ParallelTalkCardView(talkID: talkID, session: session)
                    }
                }
            } else {
                HStack(alignment: .top) {
                    TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

                    HStack(alignment: .top) {
                        ForEach(session.contentIDs, id: \.self) { talkID in
                            ParallelTalkCardView(talkID: talkID, session: session)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
