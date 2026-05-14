//
//  ViewModel.swift
//  SpeakerCreator
//
//  Created by Chris Price on 08/09/2021.
//

import Foundation

@Observable
class ViewModel {
    var confData: ConfData
    var favouritesBySession: [[Session]] = []
    var check = "Not done"
    
    var favouriteIds: [UUID] = []  // The talk IDs for each favourite
    
    init() {
        confData = loadConfData()
        loadFavourites()
    }
    
    func saveConference(){
        let readListURL =  urlToFileInDocuments("conf.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(confData) {
            try? data.write(to: readListURL, options: .noFileProtection)
            print( "Conf file is at \(readListURL)")
        }
    }
    
    // MARK: Lookups
    //
    // These helpers underpin every accessibility label on talk cards,
    // speaker rows, and location screens. The previous implementations used
    // `filter{...}[0]` which trap-crashes whenever the data has a missing
    // reference — even a single typo'd ID in `conf.json` would take the app
    // down. They now use `first(where:)` with safe fallback strings, and
    // `assertionFailure` so bad references still surface loudly during
    // development.

    func talkFrom(talkID: UUID) -> Talk {
        if let talk = confData.talks.first(where: { $0.id == talkID }) {
            return talk
        }
        assertionFailure("Talk with id \(talkID) not found")
        return Talk(id: talkID, talkTitle: "Talk to be announced", talkDescription: "", speakerIDs: [], locationID: "")
    }

    func talkUUIDFrom(talkTitle: String) -> UUID {
        if let talk = confData.talks.first(where: { $0.talkTitle == talkTitle }) {
            return talk.id
        }
        assertionFailure("Talk with title '\(talkTitle)' not found")
        return UUID()
    }

    func talkTitleFrom(talkID: UUID) -> String {
        confData.talks.first(where: { $0.id == talkID })?.talkTitle ?? "Talk to be announced"
    }

    func speakersFrom(talkID: UUID) -> String {
        guard let talk = confData.talks.first(where: { $0.id == talkID }),
              !talk.speakerIDs.isEmpty else {
            return "Speaker to be announced"
        }
        let names = talk.speakerIDs.map { speakerNameFrom(speakerID: $0) }
        return names.formatted(.list(type: .and))
    }

    func speakerNameFrom(speakerID: String) -> String {
        confData.speakers.first(where: { $0.id == speakerID })?.name ?? "Speaker to be announced"
    }

    func speakerFrom(speakerID: String) -> Speaker {
        if let speaker = confData.speakers.first(where: { $0.id == speakerID }) {
            return speaker
        }
        assertionFailure("Speaker with id \(speakerID) not found")
        return Speaker(id: speakerID, name: "Speaker to be announced", talkIDs: [])
    }

    func locationFrom(talkID: UUID) -> Location {
        guard let talk = confData.talks.first(where: { $0.id == talkID }) else {
            assertionFailure("Talk with id \(talkID) not found")
            return Location(id: "", name: "Location to be announced", latitude: 0, longitude: 0, placeDescription: "")
        }
        return locationFrom(locationID: talk.locationID)
    }

    func locationFrom(locationID: String) -> Location {
        if let location = confData.locations.first(where: { $0.id == locationID }) {
            return location
        }
        assertionFailure("Location with id '\(locationID)' not found")
        return Location(id: locationID, name: "Location to be announced", latitude: 0, longitude: 0, placeDescription: "")
    }

    func locationNameFrom(talkID: UUID) -> String {
        locationFrom(talkID: talkID).name
    }

    func locationNameFrom(locationID: String) -> String {
        locationFrom(locationID: locationID).name
    }

    /// Builds the accessibility label spoken by VoiceOver when focus lands
    /// on a talk card. Centralised here so it can be unit-tested for shape
    /// regressions — every word, comma, and connective in the spoken
    /// sentence matters for VoiceOver clarity.
    ///
    /// Times use the shortened locale format ("9:30 am") rather than the
    /// visible two-digit form ("09:30") which speech engines tend to read
    /// with a pause between hour and minutes.
    ///
    /// Format: "[Type] from [start] to [end]: [title], by [speakers], [location]"
    func talkCardAccessibilityLabel(talkID: UUID, in session: Session, liveStatus: SessionLiveStatus = .upcoming) -> String {
        let type = session.sessionType.displayName
        let title = talkTitleFrom(talkID: talkID)
        let speakers = speakersFrom(talkID: talkID)
        let location = locationNameFrom(talkID: talkID)
        return "\(liveStatus.accessibilityPrefix)\(type) from \(session.startTimeAccessibilityText) to \(session.endTimeAccessibilityText): \(title), by \(speakers), \(location)"
    }
    
    // Handling favourites
    func loadFavourites() {
        if fileExistsInDocuments("favourites.json") {
            let readListURL =  urlToFileInDocuments("favourites.json")
            print( "favourites at \(readListURL)")
            if let dataFromFile = try? Data(contentsOf: readListURL) {
                // Decode the json back to state of program
                // it is a list of talkIDs, and we need to make it into an array of arrays of sessions, with just the favourite talks
                let decoder = JSONDecoder()
                if let loadedArray = try? decoder.decode([UUID].self, from: dataFromFile) {
                    favouriteIds = loadedArray
                    var mappedDaySessions: [[Session]] = []
                    for daySession in confData.sessions {
                        var mappedDaySession: [Session] = []
                        for session in daySession {
                            var faveTalks: [UUID] = []
                            if session.containsTalk {
                                for talkID in session.contentIDs {
                                    if favouriteIds.contains(talkID) {
                                        faveTalks.append(talkID)
                                    }
                                }
                            }
                            if !faveTalks.isEmpty {
                                //Create a version of the session with just the favourite talks
                                let mappedSession = Session(id: session.id, startTime: session.startTime, endTime: session.endTime, sessionType: session.sessionType, sessionCount: faveTalks.count, contentIDs: faveTalks)
                                mappedDaySession.append(mappedSession)
                            }
                        }
                        if mappedDaySession.isEmpty { // Put in dummy session
                            mappedDaySession = [ Session( startTime: daySession[0].startTime, endTime: daySession[0].endTime, sessionType: .dummy, sessionCount: 0)]
                        }
                        mappedDaySessions.append(mappedDaySession)
                    }
                    favouritesBySession = mappedDaySessions
                }
            }
        } else {
            saveFavourites()
            loadFavourites()
        }
    }
    
    func saveFavourites() {
        // Make a list of the favourite Ids and save to disc
        let readListURL =  urlToFileInDocuments("favourites.json")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(favouriteIds) {
            //Write the data to backing store.
            try? data.write(to: readListURL, options: .noFileProtection)
        }
    }
    
    func removeFavourite(talk: Talk) {
        favouriteIds = favouriteIds.filter{$0 != talk.id}
        saveFavourites()
        loadFavourites()
    }
    
    func addFavourite(talk: Talk) {
        favouriteIds.append(talk.id)
        saveFavourites()
        loadFavourites()
    }
    
    func isFavourite(talk: Talk) -> Bool {
        return favouriteIds.contains(talk.id)
    }

    /// Window (in seconds) inside which a future favourite is promoted
    /// to the "Up next" slot on the My Schedule tab. Two hours covers
    /// most of a conference morning or afternoon while keeping the
    /// promotion quiet when the user has nothing imminent.
    static let upNextWindow: TimeInterval = 2 * 60 * 60

    /// The favourited session most relevant *right now* — either
    /// currently underway or starting within the next two hours.
    /// Returns `nil` outside the window so the view can hide the slot
    /// rather than showing far-future or finished sessions.
    func nextUpcomingFavouriteSession(now: Date = .now) -> Session? {
        let candidates = confData.sessions.flatMap { $0 }
            .filter { $0.containsTalk }
            .filter { $0.contentIDs.contains(where: { favouriteIds.contains($0) }) }
            .filter { now <= $0.endTime }

        let live = candidates.first(where: { $0.startTime <= now && now <= $0.endTime })
        if let live { return live }

        let upcoming = candidates
            .filter { $0.startTime > now }
            .sorted { $0.startTime < $1.startTime }
            .first

        guard let upcoming else { return nil }
        return upcoming.startTime.timeIntervalSince(now) <= Self.upNextWindow ? upcoming : nil
    }
}

