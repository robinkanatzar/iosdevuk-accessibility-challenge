//
//  SpeakerPhotoView.swift
//  IOSDevuk26
//

import SwiftUI

/// A circular speaker photo at a given size, falling back to a default if no photo exists.
struct SpeakerPhotoView: View {
    let speaker: Speaker
    let size: CGFloat
    @ScaledMetric private var scaledSize: CGFloat

    init(speaker: Speaker, size: CGFloat) {
        self.speaker = speaker
        self.size = size
        self._scaledSize = ScaledMetric(wrappedValue: size)
    }

    private var imageName: String {
        UIImage(named: speaker.photoName) != nil ? speaker.photoName : "default"
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .accessibilityIgnoresInvertColors(true)
            .scaledToFill()
            .frame(width: scaledSize, height: scaledSize)
            .clipShape(.circle)
            .accessibilityLabel("Photo of \(speaker.name)")
            .accessibilityAddTraits(.isImage)
    }
}
