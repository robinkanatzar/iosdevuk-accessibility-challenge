//
//  ParallelSessionsRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row displaying two parallel sessions side by side.
struct ParallelSessionsRowView: View {
    let session: Session

    var body: some View {
        HStack(alignment: .top) {
            ForEach(session.contentIDs, id: \.self) { talkID in
                ParallelTalkCardView(talkID: talkID, session: session)
            }
        }
        .padding()
    }
}
