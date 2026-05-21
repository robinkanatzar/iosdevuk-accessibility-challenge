//
//  SpeakerRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row showing a speaker's photo, name, and bio excerpt.
struct SpeakerRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var photoSize: CGFloat = 56
    let speakerID: String

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout(alignment: .top))

        layout {
            SpeakerPhotoView(speaker: speaker, size: photoSize)

            VStack(alignment: .leading) {
                Text(speaker.name)
                    .bold()
                if !speaker.speakerInfo.isEmpty {
                    Text(speaker.speakerInfo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        if speaker.speakerInfo.isEmpty {
            return speaker.name
        }
        return "\(speaker.name). \(speaker.speakerInfo)"
    }
}
