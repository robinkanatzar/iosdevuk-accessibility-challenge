//
//  SettingsToolbarButton.swift
//  IOSDevuk26
//

import SwiftUI

struct SettingsToolbarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape")
                .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel("Settings")
        .accessibilityHint("Opens app display and accessibility settings.")
        .accessibilityIdentifier("settings.open")
    }
}
