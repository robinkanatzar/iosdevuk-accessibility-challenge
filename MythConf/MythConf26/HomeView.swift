//
//  HomeView.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            ProgrammeView()
                .accessibilityIdentifier("tab.programme")
                .tabItem {
                    Label("Programme", systemImage: "calendar")
                }

            SpeakersView()
                .accessibilityIdentifier("tab.speakers")
                .tabItem {
                    Label("Speakers", systemImage: "person.2")
                }

            LocationsView()
                .accessibilityIdentifier("tab.locations")
                .tabItem {
                    Label("Locations", systemImage: "map")
                }

            MyScheduleView()
                .accessibilityIdentifier("tab.mySchedule")
                .tabItem {
                    Label("My Schedule", systemImage: "star")
                }
        }
    }

}

#Preview {
    HomeView()
}
