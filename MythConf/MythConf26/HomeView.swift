//
//  HomeView.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var selection: HomeTab = .programme

    var body: some View {
        TabView(selection: $selection) {
            Tab("Programme", systemImage: "calendar", value: HomeTab.programme) {
                ProgrammeView()
            }
            .accessibilityHint("Browse the conference schedule by day")

            Tab("Speakers", systemImage: "person.2", value: HomeTab.speakers) {
                SpeakersView()
            }
            .accessibilityHint("Browse speakers and their sessions")

            Tab("Locations", systemImage: "map", value: HomeTab.locations) {
                LocationsView()
            }
            .accessibilityHint("Browse conference venues")

            Tab("My Schedule", systemImage: "star", value: HomeTab.mySchedule) {
                MyScheduleView()
            }
            .accessibilityHint("View sessions you've favourited")
        }
        .onChange(of: selection) { _, new in
            // The system already announces "[Tab name], selected, tab N of N" the instant the
            // selection changes. Posting our own announcement immediately would race that and
            // get dropped, so we wait a moment to land in VoiceOver's queue afterwards.
            Task {
                try? await Task.sleep(for: .milliseconds(700))
                AccessibilityNotification.Announcement("Now on the \(new.title) screen").post()
            }
        }
    }
}

enum HomeTab: Hashable {
    case programme, speakers, locations, mySchedule

    var title: String {
        switch self {
        case .programme: return "Programme"
        case .speakers: return "Speakers"
        case .locations: return "Locations"
        case .mySchedule: return "My Schedule"
        }
    }
}

#Preview {
    HomeView()
}
