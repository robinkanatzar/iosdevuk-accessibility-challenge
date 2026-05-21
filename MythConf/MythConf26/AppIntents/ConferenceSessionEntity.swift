//
//  ConferenceSessionEntity.swift
//  MythConf26
//

import Foundation

nonisolated struct ConferenceSessionEntity: Identifiable, Sendable {
    let id: UUID
    let title: String
    let sessionType: String
    let speakerNames: String
    let locationName: String
    let dayAndDate: String
    let timeRange: String
    let spokenTimeRange: String
    let startDate: Date
    let summary: String
    let details: String
    let isFavourite: Bool

    nonisolated var shortScheduleLine: String {
        "\(title). \(dayAndDate), \(spokenTimeRange) In \(locationName)"
    }

    nonisolated func withFavouriteState(_ isFavourite: Bool) -> ConferenceSessionEntity {
        ConferenceSessionEntity(
            id: id,
            title: title,
            sessionType: sessionType,
            speakerNames: speakerNames,
            locationName: locationName,
            dayAndDate: dayAndDate,
            timeRange: timeRange,
            spokenTimeRange: spokenTimeRange,
            startDate: startDate,
            summary: summary,
            details: details,
            isFavourite: isFavourite
        )
    }
}
