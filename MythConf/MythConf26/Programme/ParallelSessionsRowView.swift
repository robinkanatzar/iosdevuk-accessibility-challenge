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
        HStack {
            VStack {
                TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)
                let layout = UIDevice.current.userInterfaceIdiom == .phone && dynamicTypeSize >= .xxxLarge ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
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
