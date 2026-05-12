//
//  LocationsView.swift
//  IOSDevuk26
//

import SwiftUI

struct LocationsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            List(viewModel.confData.locations) { location in
                NavigationLink(value: LocationNavigationID(value: location.id)) {
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .bold()
                        Text(location.placeDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    }
                    .accessibilityElement(children: .combine)
                }
                .accessibilityIdentifier("locations.row.\(location.id)")
            }
            .accessibilityIdentifier("locations.list")
            .navigationTitle("Locations")
            .conferenceNavigationDestinations()
        }
    }
}

#Preview {
    LocationsView()
        .environment(ViewModel())
}
