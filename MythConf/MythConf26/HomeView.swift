//
//  HomeView.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

struct HomeView: View {
    /// Tracks the currently selected tab outside the TabView so the value
    /// survives the `.id(...)` rebuild we trigger on rotation.
    @State private var selectedTab: TabSection = .programme
    /// Each tab's NavigationStack path lives here, outside the `.id(...)`
    /// rebuild scope, so a rotation that recomputes the tab bar layout doesn't
    /// also pop pushed detail screens back to root.
    @State private var programmePath = NavigationPath()
    @State private var speakersPath = NavigationPath()
    @State private var locationsPath = NavigationPath()
    @State private var mySchedulePath = NavigationPath()
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Programme", systemImage: "calendar", value: TabSection.programme) {
                ProgrammeView(navigationPath: $programmePath)
            }
            Tab("Speakers", systemImage: "person.2", value: TabSection.speakers) {
                SpeakersView(navigationPath: $speakersPath)
            }
            Tab("Locations", systemImage: "map", value: TabSection.locations) {
                LocationsView(navigationPath: $locationsPath)
            }
            Tab("My Schedule", systemImage: "star", value: TabSection.mySchedule) {
                MyScheduleView(navigationPath: $mySchedulePath)
            }
        }
        // Rebuild the TabView when the vertical size class changes (i.e. on
        // rotation between portrait and landscape) so the tab bar recomputes
        // its item widths instead of keeping the stale portrait/landscape
        // layout. Selection survives because `selectedTab` lives outside.
        .id(verticalSizeClass)
        // Hidden ⌘1‑4 shortcuts so Full Keyboard Access users can jump
        // between tabs without aiming at the small tab-bar targets.
        .background {
            Group {
                Button("Programme") { selectedTab = .programme }
                    .keyboardShortcut("1", modifiers: .command)
                Button("Speakers") { selectedTab = .speakers }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Locations") { selectedTab = .locations }
                    .keyboardShortcut("3", modifiers: .command)
                Button("My Schedule") { selectedTab = .mySchedule }
                    .keyboardShortcut("4", modifiers: .command)
            }
            .hidden()
            .accessibilityHidden(true)
        }
    }

    private enum TabSection: Hashable {
        case programme
        case speakers
        case locations
        case mySchedule
    }
}

#Preview {
    HomeView()
}
