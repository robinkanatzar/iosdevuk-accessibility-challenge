//
//  LocationDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.openURL) private var openURL
    @ScaledMetric private var mapHeight: CGFloat = 400
    let locationID: String

    private var location: Location { viewModel.locationFrom(locationID: locationID) }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    private var mapsURL: URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "ll", value: "\(location.latitude),\(location.longitude)"),
            URLQueryItem(name: "q", value: location.name)
        ]
        return components?.url
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(location.name)
                    .font(.largeTitle)
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .accessibilityAddTraits(.isHeader)

                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        latitudinalMeters: 500,
                        longitudinalMeters: 500
                    )
                )) {
                    Marker(location.name, coordinate: coordinate)
                }
                .frame(height: min(mapHeight, 600))
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Map showing \(location.name)")
                .accessibilityHint("Use the Open in Apple Maps button below for directions")

                if let url = mapsURL {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Open in Apple Maps", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .accessibilityLabel("Open \(location.name) in Apple Maps")
                    .accessibilityHint("Opens the Maps app for directions")
                }

                Text("About this location")
                    .font(.headline)
                    .padding(.horizontal)
                    .accessibilityAddTraits(.isHeader)

                Text(location.placeDescription)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .resetVoiceOverFocusOnAppear()
    }
}
