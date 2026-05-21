//
//  AStack.swift
//  IOSDevuk26
//

import SwiftUI

/// A stack that lays out as `HStack` at standard sizes and falls back to
/// `VStack` once Dynamic Type enters accessibility sizes (AX1+).
struct AStack<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let hAlignment: VerticalAlignment
    let vAlignment: HorizontalAlignment
    let hSpacing: CGFloat?
    let vSpacing: CGFloat?
    let content: () -> Content

    init(
        hAlignment: VerticalAlignment = .center,
        vAlignment: HorizontalAlignment = .leading,
        hSpacing: CGFloat? = nil,
        vSpacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hAlignment = hAlignment
        self.vAlignment = vAlignment
        self.hSpacing = hSpacing
        self.vSpacing = vSpacing
        self.content = content
    }

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: vAlignment, spacing: vSpacing, content: content)
        } else {
            HStack(alignment: hAlignment, spacing: hSpacing, content: content)
        }
    }
}
