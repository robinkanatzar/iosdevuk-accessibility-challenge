//
//  SettingsToolbarButton.swift
//  IOSDevuk26
//

import SwiftUI

struct SettingsToolbarButton: View {
    @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape")
                .frame(minWidth: 44, minHeight: 44)
                .background(
                    Circle()
                        .fill(showButtonShapes ? Color(.secondarySystemBackground) : .clear)
                )
                .overlay {
                    Circle()
                        .stroke(showButtonShapes ? Color(.separator) : .clear, lineWidth: 1)
                }
        }
        .accessibilityLabel("Settings")
        .accessibilityHint("Opens app display and accessibility settings.")
        .accessibilityIdentifier("settings.open")
    }
}
