//
//  ContrastAdaptiveForegroundStyle.swift
//  IOSDevuk26
//

import SwiftUI

/// Applies the app's three-tier `foregroundStyle` (primary / secondary / tertiary)
/// using opacities that strengthen when the system **Increase Contrast** setting
/// is enabled, so secondary and tertiary text remain legible over materials and
/// tinted backgrounds.
struct ContrastAdaptiveForegroundStyle: ViewModifier {
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        let secondaryOpacity = contrast == .increased ? 0.85 : 0.7
        let tertiaryOpacity  = contrast == .increased ? 0.6  : 0.45
        return content.foregroundStyle(
            .primary,
            .primary.opacity(secondaryOpacity),
            .primary.opacity(tertiaryOpacity)
        )
    }
}

extension View {
    /// Convenience to apply `ContrastAdaptiveForegroundStyle`.
    func contrastAdaptiveForegroundStyle() -> some View {
        modifier(ContrastAdaptiveForegroundStyle())
    }
}
