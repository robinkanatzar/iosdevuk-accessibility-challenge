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
        HStack {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

            VStack(alignment: .leading) {
                Text(session.sessionType.displayName)
                    .italic()
                    .foregroundStyle(.primary)
                if let talkID = session.contentIDs.first {
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .appFont(.caption, useLexend: viewModel.useLexendFont)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(session.sessionType.color.opacity(0.12))
    }
}
