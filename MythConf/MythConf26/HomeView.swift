import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Tab("Programme", systemImage: "calendar") {
                ProgrammeView()
                    .accessibilityLabel("Programme")
                    .accessibilityHint("Browse conference sessions by day.")
            }

            Tab("Speakers", systemImage: "person.2") {
                SpeakersView()
                    .accessibilityLabel("Speakers")
                    .accessibilityHint("Browse speaker profiles and their sessions.")
            }

            Tab("Locations", systemImage: "map") {
                LocationsView()
                    .accessibilityLabel("Locations")
                    .accessibilityHint("Browse conference venues and maps.")
            }

            Tab("My Schedule", systemImage: "star") {
                MyScheduleView()
                    .accessibilityLabel("My Schedule")
                    .accessibilityHint("Review your saved sessions and schedule conflicts.")
            }
        }
        .accessibilityElement(children: .contain)
    }

}

#Preview {
    HomeView()
        .environment(ViewModel())
}
