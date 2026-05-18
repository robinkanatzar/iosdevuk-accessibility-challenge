import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let locationID: String

    private var location: Location {
        viewModel.locationFrom(locationID: locationID)
    }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(location.name)
                    .font(.title2)
                    .bold()
                    .conferenceHeaderAccessibility(label: location.name)
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
                .frame(height: 320)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal)
                .conferenceGroupAccessibility(
                    label: "Map showing \(location.name)",
                    hint: "The venue is \(location.placeDescription)."
                )

                Text(location.placeDescription)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .conferenceGroupAccessibility(
                        label: "Venue description, \(location.placeDescription)"
                    )
            }
            .padding(.vertical)
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
