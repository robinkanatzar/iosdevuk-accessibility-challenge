//
//  SettingsView.swift
//  IOSDevuk26
//

import SwiftUI

/// Presented as a modal sheet from the Programme view's gear toolbar item.
/// Lets the user switch between the four built-in `Theme`s; the selection is
/// persisted via `@AppStorage("selectedTheme")` and read back by `MythConfApp`
/// to update the environment + accent tint app-wide.
struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: Theme = .default
    @Environment(\.dismiss) private var dismiss

    /// Five representative session types used for the palette swatch preview.
    private let swatchTypes: [SessionType] = [.talk, .workshop, .panel, .lightningtalks, .lunch]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(Theme.allCases) { theme in
                        themeRow(for: theme)
                    }
                    .sensoryFeedback(.selection, trigger: selectedTheme)
                } header: {
                    Text("Colour Theme")
                        .accessibilityAddTraits(.isHeader)
                } footer: {
                    Text("Themes change the app's accent tint, page background, and the colours used to mark session types in the Programme.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismiss.callAsFunction)
                }
            }
        }
    }

    @ViewBuilder
    private func themeRow(for theme: Theme) -> some View {
        let isSelected = selectedTheme == theme

        Button(action: { selectedTheme = theme }) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(theme.displayName)
                        .font(.body)
                        .bold()
                        .foregroundStyle(.primary)
                    Text(theme.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    swatches(for: theme)
                        .padding(.top, 2)
                        .accessibilityHidden(true)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(theme.displayName). \(theme.description)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func swatches(for theme: Theme) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(theme.accent)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle().stroke(.quaternary, lineWidth: 0.5)
                )
            ForEach(swatchTypes, id: \.self) { type in
                Circle()
                    .fill(theme.color(for: type))
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle().stroke(.quaternary, lineWidth: 0.5)
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
