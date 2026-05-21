//
//  ConferenceSessionStore.swift
//  MythConf26
//

import Foundation

private final class ConferenceSessionCache: @unchecked Sendable {
    private let lock = NSLock()
    nonisolated(unsafe) private var cachedSessions: [ConferenceSessionEntity]?

    nonisolated func sessions(load: () -> [ConferenceSessionEntity]) -> [ConferenceSessionEntity] {
        lock.lock()
        defer { lock.unlock() }

        if let cachedSessions {
            return cachedSessions
        }

        let loadedSessions = load()
        cachedSessions = loadedSessions
        return loadedSessions
    }
}

enum ConferenceSessionStore {
    nonisolated private static let favouritesFileName = "favourites.json"
    nonisolated private static let cache = ConferenceSessionCache()

    nonisolated static func allSessions() -> [ConferenceSessionEntity] {
        let baseSessions = cache.sessions {
            loadBaseSessions()
        }
        let favourites = Set(favouriteIDs())

        return baseSessions.map { session in
            session.withFavouriteState(favourites.contains(session.id))
        }
    }

    nonisolated private static func loadBaseSessions() -> [ConferenceSessionEntity] {
        let confData = loadConfData()
        let speakersByID = Dictionary(uniqueKeysWithValues: confData.speakers.map { ($0.id, $0) })
        let locationsByID = Dictionary(uniqueKeysWithValues: confData.locations.map { ($0.id, $0) })
        let talksByID = Dictionary(uniqueKeysWithValues: confData.talks.map { ($0.id, $0) })

        let entities = confData.sessions.flatMap { daySessions in
            daySessions.flatMap { session in
                session.contentIDs.compactMap { talkID -> ConferenceSessionEntity? in
                    guard session.containsTalk,
                          let talk = talksByID[talkID],
                          let location = locationsByID[talk.locationID] else {
                        return nil
                    }

                    let speakerNames = talk.speakerIDs.compactMap { speakersByID[$0]?.name }

                    return ConferenceSessionEntity(
                        id: talk.id,
                        title: talk.talkTitle,
                        sessionType: session.sessionType.displayName,
                        speakerNames: formattedList(speakerNames),
                        locationName: location.name,
                        dayAndDate: session.dayAndDate,
                        timeRange: session.timeRange,
                        spokenTimeRange: session.accessibilityTimeRange,
                        startDate: session.startTime,
                        summary: firstSentence(from: talk.talkDescription),
                        details: talk.talkDescription,
                        isFavourite: false
                    )
                }
            }
        }

        let sortedEntities = entities.sorted { lhs, rhs in
            if lhs.startDate == rhs.startDate {
                return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            }
            return lhs.startDate < rhs.startDate
        }
        return sortedEntities
    }

    nonisolated static func favouriteSessions() -> [ConferenceSessionEntity] {
        allSessions().filter(\.isFavourite)
    }

    nonisolated static func searchableSessions() -> [SearchableSessionEntity] {
        allSessions().map(SearchableSessionEntity.init(session:))
    }

    nonisolated static func searchableSessions(matching searchText: String) -> [SearchableSessionEntity] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return searchableSessions()
        }

        return allSessions()
            .filter { session in
                [
                    session.title,
                    session.sessionType,
                    session.speakerNames,
                    session.locationName,
                    session.dayAndDate,
                    session.timeRange
                ]
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(trimmed)
            }
            .map(SearchableSessionEntity.init(session:))
    }

    nonisolated static func favouriteIDs() -> [UUID] {
        let url = urlToFileInDocuments(favouritesFileName)
        guard let data = try? Data(contentsOf: url),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return ids
    }

    nonisolated private static func formattedList(_ values: [String]) -> String {
        switch values.count {
        case 0:
            return "Unknown speaker"
        case 1:
            return values[0]
        case 2:
            return "\(values[0]) and \(values[1])"
        default:
            let leading = values.dropLast().joined(separator: ", ")
            return "\(leading), and \(values[values.count - 1])"
        }
    }

    nonisolated private static func firstSentence(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let sentenceEnd = trimmed.firstIndex(where: { ".!?".contains($0) }) else {
            return trimmed
        }
        return String(trimmed[...sentenceEnd])
    }
}
