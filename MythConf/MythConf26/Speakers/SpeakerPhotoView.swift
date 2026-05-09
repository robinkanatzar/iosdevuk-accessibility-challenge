//
//  SpeakerPhotoView.swift
//  IOSDevuk26
//

import SwiftUI

/// A circular speaker photo at a given size, falling back to a default if no photo exists.
struct SpeakerPhotoView: View {
    enum AccessibilityMode {
        case decorative
        case labelled
    }

    let speaker: Speaker
    let size: CGFloat
    let accessibilityMode: AccessibilityMode

    init(
        speaker: Speaker,
        size: CGFloat,
        accessibilityMode: AccessibilityMode = .decorative
    ) {
        self.speaker = speaker
        self.size = size
        self.accessibilityMode = accessibilityMode
    }

    private var imageName: String {
        UIImage(named: speaker.photoName) != nil ? speaker.photoName : "default"
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(.circle)
            .accessibilityHidden(accessibilityMode == .decorative)
            .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: Text {
        Text("Photo of \(speaker.name)")
    }
}
