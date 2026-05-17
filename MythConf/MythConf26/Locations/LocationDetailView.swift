//
//  LocationDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    let locationID: String
    
    private var location: Location { viewModel.locationFrom(locationID: locationID) }
    
    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    // MARK: - State Management for Controls
    @State private var position: MapCameraPosition = .automatic
    @State private var currentRegion = MKCoordinateRegion()
    
    private var panStep: CLLocationDegrees { currentRegion.span.latitudeDelta * 0.3 }
    private var zoomFactor: Double { 0.5 }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.largeTitle)
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .accessibilityAddTraits(.isHeader)
                
                Map(position: $position) {
                    Marker(location.name, coordinate: coordinate)
                }
                .frame(height: 400)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal)
                .onMapCameraChange(frequency: .continuous) { context in
                    currentRegion = context.region
                }
                .onAppear {
                    let initialRegion = MKCoordinateRegion(
                        center: coordinate,
                        latitudinalMeters: 500,
                        longitudinalMeters: 500
                    )
                    currentRegion = initialRegion
                    position = .region(initialRegion)
                }
                .overlay(alignment: .bottomTrailing) {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(spacing: 6) {
                            mapButton(systemName: "chevron.up", label: "Pan Up", hint: "Moves the map view North") {
                                moveMap(latDelta: panStep, lonDelta: 0)
                            }
                            HStack(spacing: 6) {
                                mapButton(systemName: "chevron.left", label: "Pan Left", hint: "Moves the map view West") {
                                    moveMap(latDelta: 0, lonDelta: -panStep)
                                }
                                mapButton(systemName: "chevron.right", label: "Pan Right", hint: "Moves the map view East") {
                                    moveMap(latDelta: 0, lonDelta: panStep)
                                }
                            }
                            mapButton(systemName: "chevron.down", label: "Pan Down", hint: "Moves the map view South") {
                                moveMap(latDelta: -panStep, lonDelta: 0)
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Directional Controls")
                        
                        VStack(spacing: 10) {
                            mapButton(systemName: "plus", label: "Zoom In", hint: "Zooms closer into the map layout") {
                                adjustZoom(multiplyBy: zoomFactor)
                            }
                            mapButton(systemName: "minus", label: "Zoom Out", hint: "Zooms further away from the map layout") {
                                adjustZoom(multiplyBy: 1 / zoomFactor)
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Zoom Controls")
                    }
                    .padding(.trailing, 28)
                    .padding(.bottom, 16)
                }
                
                Text(location.placeDescription)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                }
                .accessibilityHint("Go back to all locations")
            }
        }
    }
    
    // MARK: - Reusable Accessible Button Builder
    @ViewBuilder
    private func mapButton(systemName: String, label: String, hint: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.body)
                .bold()
                .frame(width: 44, height: 44)
                .background(.ultraThickMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 3)
        }
        .accessibilityLabel(label)
        .accessibilityHint(hint)
    }
    
    // MARK: - Navigation Control Logic
    private func moveMap(latDelta: CLLocationDegrees, lonDelta: CLLocationDegrees) {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentRegion.center = CLLocationCoordinate2D(
                latitude: currentRegion.center.latitude + latDelta,
                longitude: currentRegion.center.longitude + lonDelta
            )
            position = .region(currentRegion)
        }
    }
    
    private func adjustZoom(multiplyBy factor: Double) {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentRegion.span = MKCoordinateSpan(
                latitudeDelta: max(0.001, min(currentRegion.span.latitudeDelta * factor, 100.0)),
                longitudeDelta: max(0.001, min(currentRegion.span.longitudeDelta * factor, 100.0))
            )
            position = .region(currentRegion)
        }
    }
}
