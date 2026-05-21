//
//  AccessibilityHelpers.swift
//  MythConf26
//

import SwiftUI

extension View {
    /// Posts `AccessibilityNotification.ScreenChanged()` shortly after the view appears,
    /// so VoiceOver focus resets to the first element of the new screen instead of
    /// inheriting position from the previous one. Apply on detail views that are pushed
    /// onto a `NavigationStack`. The brief delay lets the screen finish rendering first.
    func resetVoiceOverFocusOnAppear() -> some View {
        task {
            try? await Task.sleep(for: .milliseconds(400))
            AccessibilityNotification.ScreenChanged().post()
        }
    }
}
