//
//  ConferenceSessionEntity.swift
//  MythConf26
//

import AppIntents
import Foundation

struct ConferenceSessionEntity: AppEntity, Identifiable, Sendable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Conference Session")
    static var defaultQuery = ConferenceSessionQuery()

    let id: UUID
    let title: String
    let sessionType: String
    let speakerNames: String
    let locationName: String
    let dayAndDate: String
    let timeRange: String
    let startDate: Date
    let summary: String
    let details: String
    let isFavourite: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(dayAndDate), \(timeRange) - \(locationName)"
        )
    }

    var spokenDetails: String {
        "\(title) is a \(sessionType.lowercased()) by \(speakerNames), on \(dayAndDate) from \(timeRange), in \(locationName). \(summary)"
    }

    var shortScheduleLine: String {
        "\(timeRange), \(title), in \(locationName)"
    }
}

struct ConferenceSessionQuery: EntityStringQuery {
    func entities(for identifiers: [ConferenceSessionEntity.ID]) async throws -> [ConferenceSessionEntity] {
        let sessions = await ConferenceSessionStore.allSessions()
        return sessions.filter { identifiers.contains($0.id) }
    }

    func entities(matching string: String) async throws -> [ConferenceSessionEntity] {
        await ConferenceSessionStore.sessions(matching: string)
    }

    func suggestedEntities() async throws -> [ConferenceSessionEntity] {
        let sessions = await ConferenceSessionStore.allSessions()
        return Array(sessions.prefix(12))
    }

    func defaultResult() async -> ConferenceSessionEntity? {
        await ConferenceSessionStore.allSessions().first
    }
}
