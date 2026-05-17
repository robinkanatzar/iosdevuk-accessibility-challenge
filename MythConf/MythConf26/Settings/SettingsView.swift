//
//  SettingsView.swift
//  IOSDevuk26
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.appSettings) private var appSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var appSettings = appSettings

        NavigationStack {
            Form {
                Section {
                    Toggle("OpenDyslexic Reading Font", isOn: $appSettings.usesOpenDyslexicReadingFont)
                        .accessibilityIdentifier("settings.openDyslexicToggle")
                        .accessibilityLabel("OpenDyslexic reading font")
                        .accessibilityHint("Uses OpenDyslexic for reading-heavy conference text.")
                } footer: {
                    Text("Applies OpenDyslexic to session titles, descriptions, speaker biographies, and location descriptions. Navigation, controls, times, and compact metadata stay in the system font.")
                }

                Section("Preview") {
                    Text("Welcome to MythConf 2027")
                        .dyslexiaReadingFont(.title2, size: 22, weight: .bold)

                    Text("A brief welcome from the organisers to set the scene for the conference.")
                        .dyslexiaReadingFont(.body, size: 17)
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("settings.openDyslexicPreview")
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("settings.done")
                }
            }
        }
    }

}

#Preview {
    SettingsView()
        .environment(\.appSettings, AppSettings())
}
