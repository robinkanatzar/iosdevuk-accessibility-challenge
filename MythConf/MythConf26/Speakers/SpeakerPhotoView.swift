//
//  SpeakerPhotoView.swift
//  IOSDevuk26
//

import SwiftUI

/// A circular speaker photo at a given size, falling back to a default if no photo exists.
struct SpeakerPhotoView: View {
    let speaker: Speaker
    let size: CGFloat

    private var imageName: String {
        UIImage(named: speaker.photoName) != nil ? speaker.photoName : "default"
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(.circle)
            .accessibilityHidden(true)
    }
}
