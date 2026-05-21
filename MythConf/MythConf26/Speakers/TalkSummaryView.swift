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
                Label(session.timeRange, systemImage: "clock")
                Label(viewModel.locationNameFrom(talkID: talkID), systemImage: "mappin")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.talkTitleFrom(talkID: talkID)). \(session.timeRangeAccessible). \(viewModel.locationNameFrom(talkID: talkID)).")
    }
}
