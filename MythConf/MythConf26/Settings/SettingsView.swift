//
//  SettingsView.swift
//  IOSDevuk26
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.appSettings) private var appSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        @Bindable var appSettings = appSettings

        NavigationStack {
            Form {
                Section {
                    Toggle("OpenDyslexic Reading Font", isOn: $appSettings.usesOpenDyslexicReadingFont)
                        .accessibilityIdentifier("settings.openDyslexicToggle")
                        .accessibilityLabel("OpenDyslexic reading font")
                        .accessibilityHint("Applies OpenDyslexic font to session titles, descriptions, and biographies.")
                } footer: {
                    Text("Applies OpenDyslexic to session titles, descriptions, speaker biographies, and location descriptions. Navigation, controls, times, and compact metadata stay in the system font.")
                        .accessibilityHidden(true)
                }

                Section("Preview") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome to MythConf 2027")
                            .dyslexiaReadingFont(.title2, size: 22, weight: .bold)

                        Text("A brief welcome from the organisers to set the scene for the conference.")
                            .dyslexiaReadingFont(.body, size: 17)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityIdentifier("settings.openDyslexicPreview")
                .accessibilityHidden(true)

                Section {
                    Toggle("Haptic Feedback", isOn: $appSettings.usesFavouriteHaptics)
                        .accessibilityIdentifier("settings.favouriteHapticsToggle")
                        .accessibilityLabel("Favourite haptic feedback")
                        .accessibilityHint("Turns vibration on or off when adding or removing a favourite.")

                    Toggle("Sound Feedback", isOn: $appSettings.usesFavouriteSounds)
                        .accessibilityIdentifier("settings.favouriteSoundsToggle")
                        .accessibilityLabel("Favourite sound feedback")
                        .accessibilityHint("Turns sound on or off when adding or removing a favourite.")
                } header: {
                    Text("Favourite Feedback")
                } footer: {
                    Text("Both feedback types are on by default. You can turn either off without changing how favourites work.")
                        .accessibilityHidden(true)
                }
                .accessibilityIdentifier("settings.favouriteFeedbackSection")

                Section {
                    Picker("Reminder Timing", selection: $appSettings.favouriteReminderTiming) {
                        ForEach(FavouriteReminderTiming.allCases) { timing in
                            Text(timing.title).tag(timing)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("settings.favouriteReminderTimingPicker")
                    .accessibilityLabel("Favourite reminder timing")
                    .accessibilityHint("Chooses when reminders appear for favourited sessions.")
                } header: {
                    Text("Session Reminders")
                } footer: {
                    Text("Choose when the app reminds you about favourited sessions. Turn reminders off to reduce interruptions.")
                        .accessibilityHidden(true)
                }
                .accessibilityIdentifier("settings.sessionRemindersSection")
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: appSettings.favouriteReminderTiming) { _, newValue in
                viewModel.rescheduleFavouriteNotifications(reminderTiming: newValue)
            }
            .onChange(of: appSettings.usesOpenDyslexicReadingFont) { _, isEnabled in
                announceOpenDyslexicPreviewChange(isEnabled: isEnabled)
            }
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

    private func announceOpenDyslexicPreviewChange(isEnabled: Bool) {
        guard UIAccessibility.isVoiceOverRunning else { return }
        UIAccessibility.post(
            notification: .announcement,
            argument: isEnabled
                ? "OpenDyslexic font enabled. Preview updated."
                : "System font restored. Preview updated."
        )
    }

}

#Preview {
    SettingsView()
        .environment(\.appSettings, AppSettings())
        .environment(ViewModel())
}
