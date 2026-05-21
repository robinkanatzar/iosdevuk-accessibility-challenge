//
//  LocationsView.swift
//  IOSDevuk26
//

import SwiftUI

struct LocationsView: View {
    @Environment(ViewModel.self) private var viewModel
    /// Owned by `HomeView` so the navigation stack survives the rotation-
    /// triggered TabView rebuild (`.id(verticalSizeClass)`).
    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(viewModel.confData.locations) { location in
                NavigationLink(value: LocationNavigationID(value: location.id)) {
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .bold()
                        Text(location.placeDescription)
                            .font(.subheadline)
                            .secondaryTextStyle()
                            .a11yLineLimit(2)
                    }
                }
                .accessibilityInputLabels([location.name])
            }
            .navigationTitle("Locations")
            .conferenceNavigationDestinations()
            .languageToggleToolbar()
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    LocationsView(navigationPath: $path)
        .environment(ViewModel())
}
