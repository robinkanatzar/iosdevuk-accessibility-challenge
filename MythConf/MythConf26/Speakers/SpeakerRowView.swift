//
//  SpeakerRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row showing a speaker's photo, name, and bio excerpt.
struct SpeakerRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let speakerID: String

    var isAccessibilitySize: Bool {
        dynamicTypeSize >= .accessibility1
    }

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }

    var body: some View {
        HStack(alignment: .top) {
            SpeakerPhotoView(speaker: speaker, size: 56)
                .padding(.top, isAccessibilitySize ? 8 : 0)

            VStack(alignment: .leading) {
                Text(speaker.name)
                    .bold()
                if !speaker.speakerInfo.isEmpty {
                    Text(speaker.speakerInfo)
                        .accessibilityLabel("Bio and sessions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(isAccessibilitySize ? 3 : 2)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ViewModel()
    SpeakerRowView(speakerID: viewModel.confData.speakers.first!.id)
        .environment(viewModel)
        .padding()
}
