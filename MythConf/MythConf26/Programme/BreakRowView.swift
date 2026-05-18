//
//  BreakRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
struct BreakRowView: View {
    @Environment(ViewModel.self) private var viewModel
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading) {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)
            Text(session.sessionType.displayName)
                .italic()
            if let talkID = session.contentIDs.first {
                Text(viewModel.locationNameFrom(talkID: talkID))
                    .font(.caption)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundStyle(.primary)
        .background(session.sessionType.color.opacity(0.12))
    }
}
