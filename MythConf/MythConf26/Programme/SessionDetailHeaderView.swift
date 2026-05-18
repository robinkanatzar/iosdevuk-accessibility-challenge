import SwiftUI

struct SessionDetailHeaderView: View {
    let title: String
    let timeRange: AccessibleTimeRange
    let locationID: String
    let locationName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .bold()
                .conferenceHeaderAccessibility(label: title)

            Label(timeRange.visualText, systemImage: "clock")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Time")
                .accessibilityValue(timeRange.accessibilityLabel)

            NavigationLink(value: LocationNavigationID(value: locationID)) {
                Label(locationName, systemImage: "mappin")
                    .font(.subheadline)
            }
            .conferenceLinkAccessibility(
                label: "Location, \(locationName)",
                hint: "Opens venue details and map.",
                inputLabels: [
                    locationName,
                    "Location",
                    "Venue",
                    "Open location"
                ]
            )
        }
    }
}

#Preview {
    NavigationStack {
        SessionDetailHeaderView(
            title: "Building Accessible SwiftUI Apps",
            timeRange: AccessibleTimeRange(start: .now, end: .now.addingTimeInterval(3_600)),
            locationID: "main",
            locationName: "Main Theatre"
        )
    }
}
