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

    private var locationName: String? {
        guard let talkID = session.contentIDs.first else { return nil }
        return viewModel.locationNameFrom(talkID: talkID)
    }

//    private var rowAccessibilityLabel: String {
//        if let locationName {
//            return "\(session.sessionType.displayName), \(session.timeRange), \(locationName)"
//        } else {
//            return "\(session.sessionType.displayName), \(session.timeRange)"
//        }
//    }

    private var rowAccessibilityLabel: String {
        if let locationName {
            return "\(session.sessionType.displayName), \(session.liveStatus.title), \(session.timeRange), \(locationName)"
        } else {
            return "\(session.sessionType.displayName), \(session.liveStatus.title), \(session.timeRange)"
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
            if dynamicTypeSize.isAccessibilitySize {
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
                TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)
                Spacer()
            }

            nonTalkStack

            Spacer()
        }
    }

    private var compactParallelLayout: some View {
        HStack {
            TimeColumnView(startTime: session.startTimeText, endTime: session.endTimeText)

            nonTalkStack

            Spacer()
        }
    }

    private var nonTalkStack: some View {
        VStack(alignment: .leading) {
            Text(session.sessionType.displayName)
                .italic()
                .foregroundStyle(.primary)
            SessionStatusBadge(session: session)
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
    BreakRowView(session: session)
        .environment(viewModel)
}
