//
//  SearchableSessionQuery.swift
//  MythConf26
//

import AppIntents
import Foundation

struct SearchableSessionQuery: EntityQuery {
    func entities(for identifiers: [SearchableSessionEntity.ID]) async throws -> [SearchableSessionEntity] {
        ConferenceSessionStore.searchableSessions()
            .filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [SearchableSessionEntity] {
        Array(ConferenceSessionStore.searchableSessions().prefix(12))
    }
}

extension SearchableSessionQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [SearchableSessionEntity] {
        ConferenceSessionStore.searchableSessions(matching: string)
    }
}
