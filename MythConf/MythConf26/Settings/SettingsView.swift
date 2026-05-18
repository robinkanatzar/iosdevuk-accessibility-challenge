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

                Section {
                    Toggle("Haptic Feedback", isOn: $appSettings.usesFavouriteHaptics)
                        .accessibilityIdentifier("settings.favouriteHapticsToggle")
                        .accessibilityLabel("Favourite haptic feedback")
                        .accessibilityHint("Controls vibration feedback when adding or removing favourites.")

                    Toggle("Sound Feedback", isOn: $appSettings.usesFavouriteSounds)
                        .accessibilityIdentifier("settings.favouriteSoundsToggle")
                        .accessibilityLabel("Favourite sound feedback")
                        .accessibilityHint("Controls sound feedback when adding or removing favourites.")
                } header: {
                    Text("Favourite Feedback")
                } footer: {
                    Text("Both feedback types are on by default. You can turn either off without changing how favourites work.")
                }
                .accessibilityIdentifier("settings.favouriteFeedbackSection")

                Section {
                    Picker("Reminder Timing", selection: $appSettings.favouriteReminderTiming) {
                        ForEach(FavouriteReminderTiming.allCases) { timing in
                            Text(timing.title).tag(timing)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("settings.favouriteReminderTimingPicker")
                    .accessibilityLabel("Favourite reminder timing")
                    .accessibilityHint("Controls whether favourited sessions create local reminders and how long before the session they appear.")
                } header: {
                    Text("Session Reminders")
                } footer: {
                    Text("Choose when the app reminds you about favourited sessions. Turn reminders off to reduce interruptions.")
                }
                .accessibilityIdentifier("settings.sessionRemindersSection")
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: appSettings.favouriteReminderTiming) { _, newValue in
                viewModel.rescheduleFavouriteNotifications(reminderTiming: newValue)
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

}

#Preview {
    SettingsView()
        .environment(\.appSettings, AppSettings())
        .environment(ViewModel())
}
