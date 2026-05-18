import SwiftUI

/// A compact row showing a talk's title, time, and location — used in speaker detail.
struct TalkSummaryView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session
    
    private var timeRange: AccessibleTimeRange {
        AccessibleTimeRange(start: session.startTime, end: session.endTime)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.talkTitleFrom(talkID: talkID))
                .bold()
            HStack {
                Label(timeRange.visualText, systemImage: "clock")
                    .accessibilityLabel("Time")
                    .accessibilityValue(timeRange.accessibilityLabel)
                Label(viewModel.locationNameFrom(talkID: talkID), systemImage: "mappin")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
