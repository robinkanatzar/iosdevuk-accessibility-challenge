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
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
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
        GeometryReader { proxy in
            if shouldScroll(in: proxy.size) {
                ScrollView {
                    locationContent
                        .padding(.horizontal, 16.0)
                }
            } else {
                locationContent
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.automatic)
        .onAppear {
            OpenInMapsTip.hasViewedLocationDetail = true
        }
    }

    private func shouldScroll(in size: CGSize) -> Bool {
        size.width > size.height || dynamicTypeSize.isAccessibilitySize
    }

    private var locationContent: some View {
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
            .frame(height: 300)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Map showing \(location.name)")
            .accessibilityValue(location.placeDescription)
            .accessibilityHint("Shows the venue area")

            Text(location.placeDescription)
                .foregroundStyle(.secondary)
                .padding()

            Spacer()

            if let mapsURL {
                Button {
                    OpenInMapsTip.hasOpenedMaps = true
                    openInMapsTip.invalidate(reason: .actionPerformed)
                    openURL(mapsURL)
                } label: {
                    mapsButtonLabel
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open \(location.name) in Maps for directions")
                .accessibilityHint("Opens this location in Apple Maps for directions")
                .accessibilityIdentifier("location.openInMaps")
                .padding(.horizontal)
                .padding(.bottom)
                .popoverTip(openInMapsTip, arrowEdge: .bottom)
            }

            Spacer()
        }
    }

    private var mapsButtonLabel: some View {
        HStack(alignment: dynamicTypeSize.isAccessibilitySize ? .top : .center, spacing: 14) {
            Image(systemName: "map")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.accentColor))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Open in Maps")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)

                Text("Use Apple Maps for directions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
            }

            Spacer(minLength: 8)

            Image(systemName: "arrow.up.forward")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: colorSchemeContrast == .increased ? 1.5 : 0.5)
        }
        .contentShape(.rect)
    }
}

#Preview {
    NavigationStack {
        LocationDetailView(locationID: "tyndallLecture")
            .environment(ViewModel())
    }
}
