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
        ViewThatFits {
            VStack(alignment: .leading) {
                Text(viewModel.talkTitleFrom(talkID: talkID))
                    .bold()
                HStack {
                    Label(session.timeRange, systemImage: "clock")
                    Label(viewModel.locationNameFrom(talkID: talkID), systemImage: "mappin")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(session.timeRange), \(viewModel.locationNameFrom(talkID: talkID))")
            }
            .padding(.vertical, 4)

            VStack(alignment: .leading) {
                Text(viewModel.talkTitleFrom(talkID: talkID))
                    .bold()
                    .padding(.bottom, 4)
                VStack(alignment: .leading, spacing: 4) {
                    Label(session.timeRange, systemImage: "clock")
                    Label(viewModel.locationNameFrom(talkID: talkID), systemImage: "mappin")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(session.timeRange), \(viewModel.locationNameFrom(talkID: talkID))")
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ViewModel()
    let session = viewModel.confData.sessions.flatMap { $0 }.first { $0.containsTalk }!
    TalkSummaryView(talkID: session.contentIDs.first!, session: session)
        .environment(viewModel)
        .padding()
}
