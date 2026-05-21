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
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)

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
        .accessibilityLabel(Text(viewModel.talkTitleFrom(talkID: talkID)))
        .accessibilityValue("\(session.accessibilityTimeRange(now: viewModel.currentDate)) \(viewModel.locationNameFrom(talkID: talkID))")
    }


    private var accessibilityLayout: some View {
        VStack(alignment: .leading, spacing: 16) {
            titleText

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
        .accessibilityLabel(Text(viewModel.talkTitleFrom(talkID: talkID)))
        .accessibilityValue("\(session.accessibilityTimeRange(now: viewModel.currentDate)) \(viewModel.locationNameFrom(talkID: talkID))")
    }


    private var titleText: some View {
        Text(viewModel.talkTitleFrom(talkID: talkID))
            .dyslexiaReadingFont(.body, size: 17, weight: .semibold)
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
