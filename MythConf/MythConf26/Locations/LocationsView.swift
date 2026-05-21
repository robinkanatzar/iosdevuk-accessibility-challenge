//
//  LocationsView.swift
//  IOSDevuk26
//

import SwiftUI

struct LocationsView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var isAccessibilitySize: Bool {
        dynamicTypeSize >= .accessibility1
    }

    var isTwoLargestAccessibilitySizes: Bool {
        dynamicTypeSize >= .accessibility4
    }

    var body: some View {
        NavigationStack {
            List(viewModel.confData.locations) { location in
                NavigationLink(value: LocationNavigationID(value: location.id)) {
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .bold()
                        if !isTwoLargestAccessibilitySizes {
                            Text(location.placeDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(isAccessibilitySize ? 3 : 2)
                        }
                    }
                }
                .accessibilityHint("Opens location detail")
            }
            .navigationTitle("Locations")
            .conferenceNavigationDestinations()
            .toolbarBackground(.background, for: .navigationBar)
        }
    }
}

// MARK: - Preview

#Preview {
    LocationsView()
        .environment(ViewModel())
}
