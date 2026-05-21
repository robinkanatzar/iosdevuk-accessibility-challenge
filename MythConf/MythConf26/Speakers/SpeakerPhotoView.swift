//
//  SpeakerPhotoView.swift
//  IOSDevuk26
//

import SwiftUI

/// A circular speaker photo at a given size, falling back to a default if no photo exists.
///
/// Always hidden from VoiceOver — every place this view is used (speaker rows, the speaker
/// profile header) already announces the speaker's name in a parent accessibility label,
/// so reading the photo's alt text would be a duplicate.
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
