//
//  TalkSummaryView.swift
//  IOSDevuk26
//

import SwiftUI

/// A compact row showing a talk's title, time, and location — used in speaker detail.
struct TalkSummaryView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            accessibilityLayout
        } else {
            standardLayout
        }
    }

    private var standardLayout: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                titleText
                    .lineLimit(2)

                HStack(spacing: 10) {
                    timeLabel
                    locationLabel
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
        .padding(.top, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session Title. \(viewModel.talkTitleFrom(talkID: talkID))")
        .accessibilityValue("\(session.timeRange), \(viewModel.locationNameFrom(talkID: talkID))")
        .accessibilityHint("Shows session details")
    }

    private var accessibilityLayout: some View {
        VStack(alignment: .leading, spacing: 16) {
            titleText
                .lineLimit(nil)

            VStack(alignment: .leading, spacing: 10) {
                timeLabel
                locationLabel
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
        .padding(.top, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.talkTitleFrom(talkID: talkID))
        .accessibilityValue("\(session.timeRange), \(viewModel.locationNameFrom(talkID: talkID))")
        .accessibilityHint("Shows session details")
    }

    private var titleText: some View {
        Text(viewModel.talkTitleFrom(talkID: talkID))
            .font(.body)
            .fontWeight(.semibold)
    }

    private var timeLabel: some View {
        Label(session.timeRange, systemImage: "clock")
    }

    private var locationLabel: some View {
        Label(viewModel.locationNameFrom(talkID: talkID), systemImage: "mappin")
    }
}

#Preview {
    let viewModel = ViewModel()
    let talkID = UUID(uuidString: "C1001006-C100-4100-8100-100000000006")!
    let session = viewModel.confData.sessions[1][2]
    
    TalkSummaryView(talkID: talkID, session: session)
        .environment(viewModel)
        .padding()
}
