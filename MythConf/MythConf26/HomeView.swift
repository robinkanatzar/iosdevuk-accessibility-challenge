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
            Tab("Programme", systemImage: "calendar") {
                ProgrammeView()
            }
            Tab("Speakers", systemImage: "person.2") {
                SpeakersView()
            }
            Tab("Locations", systemImage: "map") {
                LocationsView()
            }
            Tab("My Schedule", systemImage: "star") {
                MyScheduleView()
            }
        }
    }

}

// MARK: - Preview

#Preview {
    HomeView()
        .environment(ViewModel())
}
