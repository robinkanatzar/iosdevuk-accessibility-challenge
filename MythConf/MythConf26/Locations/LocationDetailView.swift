//
//  LocationDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let locationID: String

    private var location: Location { viewModel.locationFrom(locationID: locationID) }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        latitudinalMeters: 500,
                        longitudinalMeters: 500
                    )
                )) {
                    Marker(location.name, coordinate: coordinate)
                }
                .frame(minHeight: 200, maxHeight: 400)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal)
                .accessibilityLabel("Map showing \(location.name)")

                Text(location.placeDescription)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ViewModel()
    NavigationStack {
        LocationDetailView(locationID: viewModel.confData.locations.first!.id)
    }
    .environment(viewModel)
}
