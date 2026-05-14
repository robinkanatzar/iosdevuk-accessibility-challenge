//
//  HomeView.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

struct HomeView: View {
    /// When the user has Settings → Accessibility → Increase Contrast on,
    /// force the tab bar background to render opaque so its labels and
    /// icons sit on a high-contrast surface instead of the variable-contrast
    /// Liquid Glass material that picks up the colours of whatever is
    /// scrolling beneath. Defaults to `.automatic` so non-opted-in users
    /// keep Apple's intended translucent look.
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        TabView {
            Tab("Programme", systemImage: "calendar") {
                ProgrammeView()
                    .accessibilityInputLabels(["Programme", "Schedule", "Sessions"])
            }
            Tab("Speakers", systemImage: "person.2") {
                SpeakersView()
                    .accessibilityInputLabels(["Speakers", "People"])
            }
            Tab("Locations", systemImage: "map") {
                LocationsView()
                    .accessibilityInputLabels(["Locations", "Map", "Venues"])
            }
            Tab("My Schedule", systemImage: "star") {
                MyScheduleView()
                    .accessibilityInputLabels(["My Schedule", "Favourites", "Saved"])
            }
        }
        .toolbarBackground(contrast == .increased ? .visible : .automatic, for: .tabBar)
    }

}

#Preview {
    HomeView()
}
