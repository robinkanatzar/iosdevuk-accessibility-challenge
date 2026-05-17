//
//  BreakRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
struct BreakRowView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(ViewModel.self) private var viewModel
    let session: Session
    let daySessions: [Session]

    private var locationName: String? {
        guard let talkID = session.contentIDs.first else { return nil }
        return viewModel.locationNameFrom(talkID: talkID)
    }

    private var schedulePosition: ViewModel.SchedulePosition? {
        viewModel.schedulePosition(for: session, in: daySessions)
    }

    private var schedulePositionPrefix: String {
        switch schedulePosition {
        case .now:
            return "Now, "
        case .next:
            return "Next, "
        case nil:
            return ""
        }
    }

    private var rowAccessibilityLabel: String {
        let statusDisplay = session.statusDisplay(now: viewModel.currentDate)
        let statusPrefix = statusDisplay.isVisible ? "\(statusDisplay.accessibilityLabel), " : ""
        if let locationName {
            return "\(schedulePositionPrefix)\(session.sessionType.displayName), \(statusPrefix)\(session.timeRange), \(locationName)"
        } else {
            return "\(schedulePositionPrefix)\(session.sessionType.displayName), \(statusPrefix)\(session.timeRange)"
        }
    }

    private var rowBackground: AnyShapeStyle {
        if reduceTransparency {
            return AnyShapeStyle(Color(.secondarySystemBackground))
        } else if colorSchemeContrast == .increased {
            return AnyShapeStyle(session.sessionType.color.opacity(0.2))
        } else {
            return AnyShapeStyle(session.sessionType.color.opacity(0.12))
        }
    }

    var body: some View {

        Group {
            if dynamicTypeSize > .large  {
                accessibilityLayout
            } else {
                compactParallelLayout
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(rowBackground)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
    }

    private var accessibilityLayout: some View {
        VStack {

            HStack {
                VStack(alignment: .leading) {
                    timeAndPositionColumn
                    SessionStatusBadge(session: session)
                }
                Spacer()
            }

            nonTalkStack

            Spacer()
        }
    }

    private var compactParallelLayout: some View {
        HStack {
            timeAndPositionColumn

            nonTalkStack

            Spacer()

            SessionStatusBadge(session: session).padding(.trailing, 18)
        }
    }

    private var timeAndPositionColumn: some View {
        VStack(alignment: .trailing, spacing: 8) {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

            if let schedulePosition {
                NowNextBadge(position: schedulePosition)
            }

            Spacer(minLength: 0)
        }
    }

    private var nonTalkStack: some View {
        VStack(alignment: .leading) {
            Text(session.sessionType.displayName)
                .italic()
                .foregroundStyle(.primary)
            if let locationName {
                Text(locationName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    let viewModel = ViewModel()
    let session = viewModel.confData.sessions[1][4]
    BreakRowView(session: session, daySessions: viewModel.confData.sessions[1])
        .environment(viewModel)
}
