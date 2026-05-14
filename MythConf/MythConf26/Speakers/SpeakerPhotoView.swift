//
//  SpeakerPhotoView.swift
//  IOSDevuk26
//

import SwiftUI

/// A circular speaker photo at a given size, falling back to a default if no photo exists.
struct SpeakerPhotoView: View {
    let speaker: Speaker
    let size: CGFloat

    private var hasPhoto: Bool { UIImage(named: speaker.photoName) != nil }

    private var imageName: String { hasPhoto ? speaker.photoName : "default" }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(.circle)
            .accessibilityLabel(hasPhoto ? "\(speaker.name)'s profile photo" : "Profile photo not available")
    }
}
