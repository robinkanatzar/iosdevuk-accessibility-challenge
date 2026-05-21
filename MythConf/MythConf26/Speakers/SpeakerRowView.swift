//
//  SpeakerRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row showing a speaker's photo, name, and bio excerpt.
struct SpeakerRowView: View {
    @Environment(ViewModel.self) private var viewModel
    let speakerID: String

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }

    var body: some View {
        HStack(alignment: .top) {
            SpeakerPhotoView(speaker: speaker, size: 56)

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
    }
}
