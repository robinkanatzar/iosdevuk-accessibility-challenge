//
//  TalkSummaryView.swift
//  IOSDevuk26
//

import SwiftUI

/// A compact row showing a talk's title, time, and location — used in speaker detail.
struct TalkSummaryView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let talkID: UUID
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.talkTitleFrom(talkID: talkID))
                .bold()
            let layout = horizontalSizeClass == .compact && dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(alignment: .top))
            layout {
                Label(session.timeRange, systemImage: "clock")
                    .accessibilityLabel(session.voiceOverTimeRange)
                Label(viewModel.locationNameFrom(talkID: talkID), systemImage: "mappin")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
