//
//  SettingsView.swift
//  IOSDevuk26
//

import SwiftUI

struct SettingsView: View {
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Form {
                Section("Reading") {
                    Toggle("Dyslexia-friendly font", isOn: $viewModel.useLexendFont)
                    Text("Change the app font to Lexend, a dyslexia-friendly typeface designed to improve reading proficiency and reduce visual stress.")
                        .appFont(.subheadline, useLexend: viewModel.useLexendFont)
                        .foregroundStyle(.secondary)
                }

                Section("Feedback") {
                    Toggle("Haptic feedback", isOn: $viewModel.hapticFeedbackEnabled)
                    Text("Turn this off to stop sensory feedback from tab changes, day changes, and favourite actions.")
                        .appFont(.subheadline, useLexend: viewModel.useLexendFont)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environment(ViewModel())
}
