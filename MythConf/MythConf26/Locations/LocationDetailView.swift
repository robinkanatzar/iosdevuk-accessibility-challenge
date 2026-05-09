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

    private var mapsURL: URL? {
        let query = location.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? location.name
        return URL(string: "http://maps.apple.com/?ll=\(location.latitude),\(location.longitude)&q=\(query)")
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
                .frame(height: 400)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Map showing \(location.name)")
                .accessibilityValue(location.placeDescription)
                .accessibilityHint("Shows the venue area")

                Text(location.placeDescription)
                    .foregroundStyle(.secondary)
                    .padding()

                if let mapsURL {
                    Link("Open \(location.name) in Maps", destination: mapsURL)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
