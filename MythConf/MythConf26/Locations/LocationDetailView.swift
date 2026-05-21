//
//  LocationDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let locationID: String

    @State private var isInlineTitleVisible = true

    private var location: Location { viewModel.locationFrom(locationID: locationID) }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    private var isLandscape: Bool { verticalSizeClass == .compact }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.title2)
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .onScrollVisibilityChange(threshold: 0.1) { visible in
                        isInlineTitleVisible = visible
                    }

                if isLandscape {
                    HStack(alignment: .top, spacing: 16) {
                        mapView
                            .frame(maxWidth: .infinity, minHeight: 280)
                        Text(location.placeDescription)
                            .secondaryTextStyle()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                } else {
                    mapView
                        .frame(height: 400)
                        .padding(.horizontal)

                    Text(location.placeDescription)
                        .secondaryTextStyle()
                        .padding()
                }
            }
        }
        .toolbar {
            if !isInlineTitleVisible {
                ToolbarItem(placement: .principal) {
                    Text(location.name)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
    }

    private var mapView: some View {
        LocationSnapshotMapView(location: location, coordinate: coordinate)
            .accessibilityRepresentation {
                // Substitute the map's complex a11y subtree with a single button that
                // VoiceOver/Switch Control users can activate to open Apple Maps.
                Button("") {
                    openInMaps()
                }
                .accessibilityLabel(Text("Open in Maps: \(location.name)"))
                .accessibilityInputLabels([
                    "Map", "Open map", "Open in Maps",
                    "Show map", "Directions", location.name
                ])
            }
    }

    private func openInMaps() {
        let mapLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let mapItem = MKMapItem(location: mapLocation, address: nil)
        mapItem.name = location.name
        mapItem.openInMaps()
    }
}

/// Shows the live `Map` when online and falls back to a cached
/// `MKMapSnapshotter` image (with an explicit offline notice) when the device
/// has no network connectivity.
private struct LocationSnapshotMapView: View {
    let location: Location
    let coordinate: CLLocationCoordinate2D

    @Environment(\.colorScheme) private var colorScheme
    @Environment(NetworkMonitor.self) private var network
    @State private var cachedImage: UIImage?

    private var isDark: Bool { colorScheme == .dark }
    private var shouldShowCache: Bool { !network.isOnline && cachedImage != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if shouldShowCache, let cachedImage {
                    // Color.clear is the layout anchor that takes the parent's
                    // offered size; the overlay image fills it without bleeding
                    // its intrinsic width up the layout chain.
                    Color.clear
                        .overlay {
                            Image(uiImage: cachedImage)
                                .resizable()
                                .scaledToFill()
                        }
                        .clipped()
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 32))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .red)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                } else {
                    Map(initialPosition: .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            latitudinalMeters: 500,
                            longitudinalMeters: 500
                        )
                    )) {
                        Marker(location.name, coordinate: coordinate)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 12))

            if shouldShowCache {
                Label(
                    "No network connection — showing a saved snapshot of this map.",
                    systemImage: "wifi.slash"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityElement(children: .combine)
            }
        }
        .task(id: isDark) {
            cachedImage = LocationMapSnapshotCache.shared.cachedImage(
                locationID: location.id,
                isDark: isDark
            )
        }
    }
}
