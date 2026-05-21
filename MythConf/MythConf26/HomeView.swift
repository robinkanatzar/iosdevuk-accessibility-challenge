//
//  HomeView.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Programme", systemImage: "calendar", value: 0) {
                ProgrammeView()
                    .accessibilityHint("Browse the conference schedule by day.")
            }
            Tab("Speakers", systemImage: "person.2", value: 1) {
                SpeakersView()
                    .accessibilityHint("Browse and search the list of speakers.")
            }
            Tab("Locations", systemImage: "map", value: 2) {
                LocationsView()
                    .accessibilityHint("View venue rooms and their locations on a map.")
            }
            Tab("My Schedule", systemImage: "star", value: 3) {
                MyScheduleView()
                    .accessibilityHint("Review the talks you have favourited.")
            }
            Tab("Settings", systemImage: "gearshape", value: 4) {
                SettingsView()
                    .accessibilityHint("Change reading and sensory feedback settings.")
            }
        }
        .sensoryFeedback(trigger: selectedTab) { _, _ in
            viewModel.hapticFeedbackEnabled ? .selection : nil
        }
    }

}

#Preview {
    HomeView()
        .environment(ViewModel())
}
