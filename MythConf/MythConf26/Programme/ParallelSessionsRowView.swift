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
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading) {
                TimeColumnView(
                    startTime: session.startTimeText,
                    endTime: session.endTimeText,
                    accessibleRange: session.accessibleTimeRange
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 8) {
                    ForEach(session.contentIDs, id: \.self) { talkID in
                        ParallelTalkCardView(talkID: talkID, session: session)
                    }
                }
            }
            .padding()
        } else {
            HStack(alignment: .top) {
                TimeColumnView(
                    startTime: session.startTimeText,
                    endTime: session.endTimeText,
                    accessibleRange: session.accessibleTimeRange
                )
                
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

