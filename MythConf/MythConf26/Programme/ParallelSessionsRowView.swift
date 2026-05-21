//
//  ParallelSessionsRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row displaying two parallel sessions side by side.
struct ParallelSessionsRowView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let session: Session
    
    var body: some View {
        HStack {
            VStack {
                TimeColumnView(startTimeText: session.startTimeText, endTimeText: session.endTimeText, spokenTimeRange: session.voiceOverTimeRange)
                let layout = horizontalSizeClass == .compact && dynamicTypeSize >= .xxxLarge ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
                layout {
                    ForEach(session.contentIDs, id: \.self) { talkID in
                        ParallelTalkCardView(talkID: talkID, session: session)
                    }
                }
            }
        }
        .padding()
    }
}
