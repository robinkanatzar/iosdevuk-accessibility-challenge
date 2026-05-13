//
//  LocationDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import MapKit
import TipKit
import Accessibility

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
        ScrollView {
            locationContent
                .padding(.horizontal, 16.0)
        }
        .defaultScrollAnchor(.center, for: .alignment)
        .accessibilityActions { // SwiftUI limitation have to use Button rather than Link
            Button("Open in Maps") { // a11y-check:disable button-used-as-link
                if let mapsURL {
                    openURL(mapsURL)
                }
            }
        }
        .navigationTitle("Location Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            OpenInMapsTip.hasViewedLocationDetail = true
        }
    }


    private var locationContent: some View {
        VStack {
            Text(location.name)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("sessionDetail.title")

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
            .accessibilityLabel("Map showing the location of \(location.name)")

            Text(location.placeDescription)
                .foregroundStyle(.secondary)
                .padding()
                .accessibilityLabel("Details about the venue: \(location.placeDescription)")

            Spacer()

            if let mapsURL {
                Button { // a11y-check:disable button-used-as-link
                    let message = "One moment, opening Apple Maps for directions to \(location.name)"
                    AccessibilityNotification.Announcement(message).post()
                    openURL(mapsURL)
                } label: {
                    mapsButtonLabel
                }
                .contentShape(.rect)
                .accessibilityLabel("Open \(location.name) in Maps for directions")
                .accessibilityHint("Opens Apple Maps App for directions")
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
                .foregroundStyle(Color.myWhite)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.accentColor))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Open in Maps")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                    .accessibilityAddTraits(.isHeader)

                Text("Use Apple Maps for directions")
                    .font(.caption)
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
