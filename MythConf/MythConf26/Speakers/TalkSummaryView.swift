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
            AStack(vAlignment: .leading) {
                Label(session.timeRange, systemImage: "clock")
                Label(viewModel.locationNameFrom(talkID: talkID), systemImage: "mappin")
            }
            .font(.caption)
            .secondaryTextStyle()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityInputLabels([viewModel.talkTitleFrom(talkID: talkID)])
    }

    private var accessibilityDescription: String {
        let title = viewModel.talkTitleFrom(talkID: talkID)
        let start = session.startTimeText
        let end = session.endTimeText
        let location = viewModel.locationNameFrom(talkID: talkID)
        return String(localized: "\(title), from \(start) to \(end), at \(location)")
    }
}
