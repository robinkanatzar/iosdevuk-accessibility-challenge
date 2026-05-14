//
//  AccessibilityModifiers.swift
//  IOSDevuk26
//

import SwiftUI

/// Applies `.foregroundStyle(.primary)` unconditionally. Was originally
/// `.secondary` switching to `.primary` under Increase Contrast, but
/// Accessibility Inspector flagged `.secondary` text sitting on the
/// 10 % session-type tints as below the WCAG 4.5:1 contrast threshold
/// even at default contrast. The hierarchy on the affected views (talk
/// cards, time column, location captions) is already carried by font
/// size + weight — the bold subheadline title remains the clear focal
/// point regardless of caption colour — so promoting the captions to
/// primary passes contrast without flattening the design.
private struct ContrastAdaptiveSecondary: ViewModifier {
    func body(content: Content) -> some View {
        content.foregroundStyle(.primary)
    }
}

extension View {
    /// Use in place of `.foregroundStyle(.secondary)` on captions and
    /// subtitles that sit on tinted backgrounds. Renders as `.primary`
    /// so the WCAG 4.5:1 threshold is met without the user needing to
    /// opt into Increase Contrast; relies on font size and weight to
    /// preserve visual hierarchy.
    func contrastAdaptiveSecondary() -> some View {
        modifier(ContrastAdaptiveSecondary())
    }
}
