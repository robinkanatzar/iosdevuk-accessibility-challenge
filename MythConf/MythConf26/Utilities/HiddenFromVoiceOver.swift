//
//  HiddenFromVoiceOver.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 19/05/2026.
//

import SwiftUI

struct HiddenFromVoiceOver: ViewModifier {
    @State private var isVoiceOverRunning = UIAccessibility.isVoiceOverRunning

    func body(content: Content) -> some View {
        content
            .accessibilityHidden(isVoiceOverRunning)
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIAccessibility.voiceOverStatusDidChangeNotification
                )
            ) { _ in
                isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
            }
    }
}

extension View {
    func accessibilityHiddenFromVoiceOver() -> some View {
        modifier(HiddenFromVoiceOver())
    }
}
