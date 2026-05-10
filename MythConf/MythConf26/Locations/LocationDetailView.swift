//
//  LocationDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import MapKit
import TipKit

struct LocationDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.openURL) private var openURL
    let locationID: String
    private let openInMapsTip = OpenInMapsTip()

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
                    Button {
                        OpenInMapsTip.hasOpenedMaps = true
                        openInMapsTip.invalidate(reason: .actionPerformed)
                        openURL(mapsURL)
                    } label: {
                        Label("Open \(location.name) in Maps", systemImage: "map")
                    }
                    .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .popoverTip(openInMapsTip, arrowEdge: .bottom)
                }
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            OpenInMapsTip.hasViewedLocationDetail = true
        }
    }
}
