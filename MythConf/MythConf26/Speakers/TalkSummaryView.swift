//
//  TalkSummaryView.swift
//  IOSDevuk26
//

import SwiftUI

/// A compact row showing a talk's title, time, and location — used in speaker detail.
struct TalkSummaryView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.talkTitleFrom(talkID: talkID))
                .bold()
            HStack {
                Label {
                    Text(session.timeRange)
                } icon: {
                    Image(systemName: "clock")
                        .accessibilityHidden(true)
                }
                Label {
                    Text(viewModel.locationNameFrom(talkID: talkID))
                } icon: {
                    Image(systemName: "mappin")
                        .accessibilityHidden(true)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        // Combine title + time + location into one VoiceOver element with natural phrasing.
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(viewModel.talkTitleFrom(talkID: talkID)), \(session.accessibleTimeRange), at \(viewModel.locationNameFrom(talkID: talkID))"
        )
    }
}
