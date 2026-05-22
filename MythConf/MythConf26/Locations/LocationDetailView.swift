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
        MapsURLBuilder.url(
            locationName: location.name,
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
    
    var body: some View {
        ScrollView {
            locationContent
                .padding(.horizontal, 16.0)
        }
        .defaultScrollAnchor(.center, for: .alignment)
        .accessibilityActions { // SwiftUI limitation have to use Button rather than Link
            Button("Open in Maps") { // a11y-check:disable button-used-as-link
                openInMaps()
            }

            Button("Copy Link") {
                copyLocationLink()
            }
        }
        .navigationTitle("Location Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        copyLocationLink()
                    } label: {
                        Label("Copy Link", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .accessibilityHidden(true)
                }
                // The menu is hidden from VoiceOver below because its actions are
                // exposed through the page-level Actions rotor, but XCTest's
                // accessibility audit still needs a description for the control.
                .accessibilityLabel("More location actions")
                // VoiceOver gets this action from the page-level Actions
                // rotor, so the visible menu does not add a duplicate stop.
                .accessibilityHiddenFromVoiceOver()
            }
        }
        .onAppear {
            OpenInMapsTip.hasViewedLocationDetail = true
        }
    }
    
    
    private var locationContent: some View {
        VStack {
            Text(location.name)
                .dyslexiaReadingFont(.title, size: 28, weight: .heavy)
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
            .accessibilityLabel("Map showing \(location.name)")
            
            Text(location.placeDescription)
                .dyslexiaReadingFont(.body, size: 17)
                .foregroundStyle(.secondary)
                .padding()
                .accessibilityLabel(Text(location.placeDescription))
            
            
            Spacer()
            
            if mapsURL != nil {
                Button { // a11y-check:disable button-used-as-link
                    openInMaps()
                } label: {
                    mapsButtonLabel
                }
                .buttonStyle(.plain)
                .contentShape(.rect)
                .accessibilityLabel("Open \(location.name) in Maps")
                .accessibilityInputLabels([
                    "Open in Maps",
                    "Open \(location.name) in Maps"
                ])
                .accessibilityHint("Gets directions")
                .accessibilityIdentifier("location.openInMaps")
                // VoiceOver gets the same Maps handoff through the custom
                // action on the page, so this visible button stays available
                // for touch, Switch Control, and keyboard users without
                // creating a duplicate VoiceOver stop.
                .accessibilityHiddenFromVoiceOver()
                .padding(.horizontal)
                .padding(.bottom)
                .popoverTip(openInMapsTip, arrowEdge: .bottom)
            }
            
            Spacer()
        }
    }

    private func openInMaps() {
        guard let mapsURL else { return }

        let message = "One moment, opening Apple Maps for directions to \(location.name)"
        AccessibilityNotification.Announcement(message).post()
        openURL(mapsURL)
    }

    private func copyLocationLink() {
        guard let mapsURL else { return }

        UIPasteboard.general.string = mapsURL.absoluteString
        AccessibilityNotification.Announcement("Location link copied").post()
    }

    private var mapsButtonLabel: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Image(systemName: "map")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color.myWhite)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.accentColor))
                            .accessibilityHidden(true)

                        Spacer()

                        Image(systemName: "arrow.up.forward")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.accentColor)
                            .accessibilityHidden(true)
                    }

                    Text("Open in Maps")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .accessibilityAddTraits(.isHeader)

                    Text("Use Apple Maps for directions")
                        .font(.caption)
                        .foregroundStyle(Color(.label))
                }
            } else {
                HStack(alignment: .center) {
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
                            .lineLimit(2)
                            .accessibilityAddTraits(.isHeader)

                        Text("Use Apple Maps for directions")
                            .font(.caption)
                            .foregroundStyle(Color(.label))
                            .lineLimit(2)
                    }

                    Image(systemName: "arrow.up.forward")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                }
            }
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
