//
//  SpeakerRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row showing a speaker's photo, name, and bio excerpt.
struct SpeakerRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var imageScale: CGFloat = 1.0
    let speakerID: String
    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }
    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }
    
    var body: some View {
        let layout = isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(alignment: .top))
        layout {
            SpeakerPhotoView(speaker: speaker, size: 56 * imageScale)
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
    }
}
