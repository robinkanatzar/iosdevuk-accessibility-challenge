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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.largeTitle)
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
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
}
