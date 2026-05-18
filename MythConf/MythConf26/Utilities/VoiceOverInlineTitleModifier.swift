//
//  VoiceOverInlineTitleModifier.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 18/05/2026.
//

import SwiftUI

struct VoiceOverInlineTitleModifier: ViewModifier {
    let isVoiceOverRunning: () -> Bool
    @State private var voiceOverActive: Bool

    init(isVoiceOverRunning: @escaping () -> Bool) {
        self.isVoiceOverRunning = isVoiceOverRunning
        _voiceOverActive = State(initialValue: isVoiceOverRunning())
    }

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(voiceOverActive ? .inline : .large)
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIAccessibility.voiceOverStatusDidChangeNotification
                )
            ) { _ in
                voiceOverActive = isVoiceOverRunning()
            }
    }
}

extension View {
    func voiceOverInlineTitle(isVoiceOverRunning: @escaping () -> Bool) -> some View {
        modifier(VoiceOverInlineTitleModifier(isVoiceOverRunning: isVoiceOverRunning))
    }
}
