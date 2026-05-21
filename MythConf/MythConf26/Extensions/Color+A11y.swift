//
//  Color+A11y.swift
//  IOSDevuk26
//

import SwiftUI

extension View {
    /// Use this instead of `.foregroundStyle(.secondary)` — system `.secondary`
    /// resolves to `(138,138,142)` which fails WCAG AA (3.44:1) on white.
    func secondaryTextStyle() -> some View {
        foregroundStyle(Color.textSecondary)
    }

    /// Like `.lineLimit(_:)` but allows extra lines once Dynamic Type enters
    /// accessibility sizes (AX1+) so larger glyphs do not amplify truncation.
    func a11yLineLimit(_ standard: Int, extra: Int = 2) -> some View {
        modifier(A11yLineLimitModifier(standard: standard, extra: extra))
    }
}

private struct A11yLineLimitModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let standard: Int
    let extra: Int

    func body(content: Content) -> some View {
        content.lineLimit(dynamicTypeSize.isAccessibilitySize ? standard + extra : standard)
    }
}
