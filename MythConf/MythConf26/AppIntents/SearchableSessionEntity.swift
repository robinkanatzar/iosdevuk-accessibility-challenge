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

    @Property(title: "Day")
    var dayAndDate: String

    @Property(title: "Time")
    var timeRange: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(dayAndDate), \(timeRange) - \(locationName)"
        )
    }

    init(session: ConferenceSessionEntity) {
        id = session.id
        title = session.title
        speakerNames = session.speakerNames
        locationName = session.locationName
        dayAndDate = session.dayAndDate
        timeRange = session.timeRange
    }
}
