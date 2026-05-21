//
//  NavigationBar+Landscape.swift
//  IOSDevuk26
//

import SwiftUI

/// Hides the navigation bar in landscape (compact height) and forces an
/// opaque background in portrait, so the bar never blends into scrolled
/// content. Apply to root-tab screens whose nav bar carries only a static
/// title.
private struct LandscapeAwareNavigationBarModifier: ViewModifier {
    let verticalSizeClass: UserInterfaceSizeClass?

    private var visibility: Visibility {
        verticalSizeClass == .compact ? .hidden : .visible
    }

    func body(content: Content) -> some View {
        content
            .toolbar(visibility, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    /// Hide the navigation bar in landscape (compact height); always paint an
    /// opaque background in portrait.
    func landscapeHidesNavigationBar(verticalSizeClass: UserInterfaceSizeClass?) -> some View {
        modifier(LandscapeAwareNavigationBarModifier(verticalSizeClass: verticalSizeClass))
    }
}
