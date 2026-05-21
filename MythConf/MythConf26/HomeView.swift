//
//  HomeView.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppNavigation.self) private var appNavigation
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        @Bindable var nav = appNavigation
        TabView(selection: $nav.selectedTab) {
            Tab("Programme", systemImage: "calendar", value: AppTab.programme) {
                ProgrammeView()
            }
            Tab("Speakers", systemImage: "person.2", value: AppTab.speakers) {
                SpeakersView()
            }
            Tab("Locations", systemImage: "map", value: AppTab.locations) {
                LocationsView()
            }
            Tab("My Schedule", systemImage: "star", value: AppTab.mySchedule) {
                MyScheduleView()
            }
        }
        .transaction { transaction in
            if reduceMotion {
                transaction.animation = nil
            }
        }
        .background {
            Group {
                Button("") { appNavigation.selectedTab = .programme }
                    .keyboardShortcut("1", modifiers: .command)
                    .hidden()
                Button("") { appNavigation.selectedTab = .speakers }
                    .keyboardShortcut("2", modifiers: .command)
                    .hidden()
                Button("") { appNavigation.selectedTab = .locations }
                    .keyboardShortcut("3", modifiers: .command)
                    .hidden()
                Button("") { appNavigation.selectedTab = .mySchedule }
                    .keyboardShortcut("4", modifiers: .command)
                    .hidden()
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppNavigation.shared)
}
