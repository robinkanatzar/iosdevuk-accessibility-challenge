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
    let rotorNamespace: Namespace.ID

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

    private var statusDisplay: Session.StatusDisplay {
        session.statusDisplay(now: viewModel.currentDate)
    }

    private var rowAccessibilityLabel: String {
        "\(schedulePositionPrefix)\(session.sessionType.displayName)"
    }

    private var rowAccessibilityValue: String {
        [
            schedulePosition?.accessibilityText,
            statusDisplay.isVisible ? statusDisplay.accessibilityLabel : nil
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
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
        if dynamicTypeSize > .large  {
            accessibleBreakRow(accessibilityLayout)
        } else {
            accessibleBreakRow(compactParallelLayout)
        }
    }

    private func accessibleBreakRow<Content: View>(_ content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(rowBackground)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowAccessibilityLabel)
            .accessibilityValue(rowAccessibilityValue)
            .accessibilityCustomContent("Time", session.accessibilityTimeRange, importance: .high)
            .accessibilityCustomContent("Location", locationName ?? "No location", importance: .default)
            .accessibilityCustomContent("Status", statusDisplay.isVisible ? statusDisplay.accessibilityLabel : "Not started", importance: .default)
            .accessibilityIdentifier(ScheduleRotorTargetID.breakSession(session.id))
            .accessibilityRotorEntry(id: ScheduleRotorTargetID.breakSession(session.id), in: rotorNamespace)
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
    @Previewable @Namespace var rotorNamespace
    let viewModel = ViewModel()
    let session = viewModel.confData.sessions[1][4]

    BreakRowView(
        session: session,
        daySessions: viewModel.confData.sessions[1],
        rotorNamespace: rotorNamespace
    )
        .environment(viewModel)
}
