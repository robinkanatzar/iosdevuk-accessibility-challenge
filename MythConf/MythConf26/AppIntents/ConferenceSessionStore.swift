//
//  ConferenceSessionStore.swift
//  MythConf26
//

import Foundation

enum ConferenceSessionStore {
    private static let favouritesFileName = "favourites.json"

    static func allSessions() -> [ConferenceSessionEntity] {
        let confData = loadConfData()
        let favourites = Set(favouriteIDs())
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
                        startDate: session.startTime,
                        summary: firstSentence(from: talk.talkDescription),
                        details: talk.talkDescription,
                        isFavourite: favourites.contains(talk.id)
                    )
                }
            }
        }

        return entities.sorted { lhs, rhs in
            if lhs.startDate == rhs.startDate {
                return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            }
            return lhs.startDate < rhs.startDate
        }
    }

    static func sessions(matching searchText: String) -> [ConferenceSessionEntity] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return Array(allSessions().prefix(8))
        }

        return allSessions().filter { session in
            [
                session.title,
                session.sessionType,
                session.speakerNames,
                session.locationName,
                session.dayAndDate
            ]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(trimmed)
        }
    }

    static func session(for id: UUID) -> ConferenceSessionEntity? {
        allSessions().first { $0.id == id }
    }

    static func favouriteSessions() -> [ConferenceSessionEntity] {
        let favourites = Set(favouriteIDs())
        return allSessions().filter { favourites.contains($0.id) }
    }

    static func favouriteIDs() -> [UUID] {
        let url = urlToFileInDocuments(favouritesFileName)
        guard let data = try? Data(contentsOf: url),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return ids
    }

    @discardableResult
    static func addFavourite(_ id: UUID) throws -> Bool {
        var ids = favouriteIDs()
        guard !ids.contains(id) else { return false }
        ids.append(id)
        try saveFavouriteIDs(ids)
        return true
    }

    @discardableResult
    static func removeFavourite(_ id: UUID) throws -> Bool {
        let ids = favouriteIDs()
        let updated = ids.filter { $0 != id }
        guard updated.count != ids.count else { return false }
        try saveFavouriteIDs(updated)
        return true
    }

    private static func saveFavouriteIDs(_ ids: [UUID]) throws {
        let data = try JSONEncoder().encode(ids)
        try data.write(to: urlToFileInDocuments(favouritesFileName), options: [.atomic])
    }

    private static func formattedList(_ values: [String]) -> String {
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

    private static func firstSentence(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let sentenceEnd = trimmed.firstIndex(where: { ".!?".contains($0) }) else {
            return trimmed
        }
        return String(trimmed[...sentenceEnd])
    }
}
