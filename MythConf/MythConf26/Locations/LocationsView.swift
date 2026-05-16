//
//  LocationsView.swift
//  IOSDevuk26
//

import SwiftUI

struct LocationsView: View {
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            List(viewModel.confData.locations) { location in
                NavigationLink(value: LocationNavigationID(value: location.id)) {
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .bold()
                        Text(location.placeDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(location.name)
                }
            }
            .navigationTitle("Locations")
            .conferenceNavigationDestinations()
        }
    }
}

#Preview {
    LocationsView()
        .environment(ViewModel())
}
