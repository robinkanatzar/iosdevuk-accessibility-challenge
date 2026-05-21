//
//  SpeakerPhotoView.swift
//  IOSDevuk26
//

import SwiftUI

/// A circular speaker photo at a given size, falling back to a default if no photo exists.
/// The size scales with Dynamic Type so the photo grows alongside neighbouring text.
struct SpeakerPhotoView: View {
    let speaker: Speaker
    @ScaledMetric private var scaledSize: CGFloat

    init(speaker: Speaker, size: CGFloat) {
        self.speaker = speaker
        self._scaledSize = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    private var imageName: String {
        UIImage(named: speaker.photoName) != nil ? speaker.photoName : "default"
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: scaledSize, height: scaledSize)
            .clipShape(.circle)
            .accessibilityHidden(true)
    }
}
