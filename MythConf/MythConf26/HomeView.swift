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
                .tabItem {
                    Label("Programme", systemImage: "calendar")
                }

            SpeakersView()
                .tabItem {
                    Label("Speakers", systemImage: "person.2")
                }

            LocationsView()
                .tabItem {
                    Label("Locations", systemImage: "map")
                }

            MyScheduleView()
                .tabItem {
                    Label("My Schedule", systemImage: "star")
                }
        }
    }

}

#Preview {
    HomeView()
}
