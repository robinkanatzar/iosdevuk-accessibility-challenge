//
//  SearchableSessionEntity.swift
//  MythConf26
//

import AppIntents
import Foundation

struct SearchableSessionEntity: AppEntity, IndexedEntity, Identifiable, Sendable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(
        name: "Session",
        numericFormat: "\(placeholder: .int) sessions"
    )

    static var defaultQuery = SearchableSessionQuery()

    let id: UUID

    @Property(title: "Title")
    var title: String

    @Property(title: "Speaker")
    var speakerNames: String

    @Property(title: "Location")
    var locationName: String

    var latitude: Double
    var longitude: Double

    @Property(title: "Day")
    var dayAndDate: String

    @Property(title: "Time")
    var timeRange: String

    var spokenTimeRange: String
    var sessionType: String
    var summary: String

    var spokenDetails: String {
        "\(title) is a \(sessionType.lowercased()) by \(speakerNames), on \(dayAndDate). \(spokenTimeRange) In \(locationName). \(summary)"
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(dayAndDate), \(timeRange) - \(locationName)"
        )
    }

    init(session: ConferenceSessionEntity) {
        id = session.id
        latitude = session.latitude
        longitude = session.longitude
        spokenTimeRange = session.spokenTimeRange
        sessionType = session.sessionType
        summary = session.summary
        title = session.title
        speakerNames = session.speakerNames
        locationName = session.locationName
        dayAndDate = session.dayAndDate
        timeRange = session.timeRange
    }
}
