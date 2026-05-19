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
                    VStack(alignment: .leading, spacing: 16) {
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
                        .accessibilityElement()
                        .accessibilityLabel("Map showing \(location.name)")
                        .accessibilityHint("Visual reference. Use Open in Maps below for directions.")
         
                        // Section header for the description.
                        Text("About this location")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                            .padding(.horizontal)
         
                        Text(location.placeDescription)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
         
                        Button {
                            openInMaps()
                        } label: {
                            Label("Open in Maps", systemImage: "map.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                        .accessibilityHint("Opens \(location.name) in the Maps app for directions")
                        .accessibilityInputLabels(["Open in Maps", "directions", "maps", "navigate"])
                    }
                    .padding(.vertical)
                }
                .navigationTitle(location.name)
                .navigationBarTitleDisplayMode(.large)
            }
         
            private func openInMaps() {
                let placemark = MKPlacemark(coordinate: coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = location.name
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsMapTypeKey: NSNumber(value: MKMapType.standard.rawValue)
                ])
            }
        }
