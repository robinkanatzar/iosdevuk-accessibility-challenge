//
//  SessionTypeBadge.swift
//  MythConf26
//

import SwiftUI

/// A small capsule label showing the session type's name. Lets sighted users distinguish session types
/// without relying on the colored bar alone. When Increase Contrast is enabled the background opacity
/// is raised and a stroke is drawn so the badge stays legible. Hidden from VoiceOver because the
/// parent row already includes the type name in its combined accessibility label.
struct SessionTypeBadge: View {
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    let type: SessionType

    private var backgroundOpacity: Double {
        colorSchemeContrast == .increased ? 0.6 : 0.25
    }

    private var strokeWidth: CGFloat {
        colorSchemeContrast == .increased ? 1 : 0
    }

    var body: some View {
        Text(type.displayName)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(type.color.opacity(backgroundOpacity), in: .capsule)
            .overlay(
                Capsule().strokeBorder(type.color, lineWidth: strokeWidth)
            )
            .foregroundStyle(.primary)
            .accessibilityHidden(true)
    }
}
