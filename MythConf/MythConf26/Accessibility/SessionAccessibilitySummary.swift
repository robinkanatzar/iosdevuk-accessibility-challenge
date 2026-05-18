import Foundation

/// Builds consistent accessibility copy for talks displayed across Programme,
/// My Schedule, speaker detail, and search results.
struct SessionAccessibilitySummary: Equatable {
    let sessionType: String
    let title: String
    let speakers: [String]
    let location: String
    let timeRange: AccessibleTimeRange
    let isFavourite: Bool

    var label: String {
        [
            sessionType,
            title,
            speakerText,
            timeRange.accessibilityLabel,
            location
        ]
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }

    var value: String {
        isFavourite ? "Saved to My Schedule" : "Not saved"
    }

    var hint: String {
        "Double tap to view details. Use the actions rotor to \(favouriteActionName.lowercased())."
    }

    var favouriteActionName: String {
        isFavourite ? "Remove from favourites" : "Add to favourites"
    }

    var inputLabels: [String] {
        [
            title,
            sessionType,
            "Session",
            "Talk",
            "Favourite",
            "Save",
            location
        ] + speakers
    }

    private var speakerText: String {
        switch speakers.count {
        case 0:
            return ""
        case 1:
            return "by \(speakers[0])"
        case 2:
            return "by \(speakers[0]) and \(speakers[1])"
        default:
            let leadingSpeakers = speakers.dropLast().joined(separator: ", ")
            return "by \(leadingSpeakers), and \(speakers.last ?? "")"
        }
    }
}
