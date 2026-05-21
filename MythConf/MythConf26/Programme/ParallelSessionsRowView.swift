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
        HStack(alignment: .top) {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading) {
                    ForEach(session.contentIDs, id: \.self) { talkID in
                        ParallelTalkCardView(talkID: talkID, session: session)
                            .id(talkID)
                    }
                }
            } else {
                HStack(alignment: .top) {
                    ForEach(session.contentIDs, id: \.self) { talkID in
                        ParallelTalkCardView(talkID: talkID, session: session)
                            .id(talkID)
                    }
                }
            }
        }
        .padding()
        .accessibilityElement(children: .contain)
    }
}
