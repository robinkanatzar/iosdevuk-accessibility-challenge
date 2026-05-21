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

    /// Reloads `confData` from disk. Called when the user toggles the in-app
    /// language so the on-screen content matches the new locale.
    func reload() {
        confData = loadConfData()
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
    
    func talkFrom(talkID: UUID) -> Talk {
        let matchingTalks = confData.talks.filter{$0.id == talkID}
        if matchingTalks.count != 1 {print("Error - talkID did not exist")}
        return matchingTalks[0]
    }
    
    func talkUUIDFrom(talkTitle: String) -> UUID {
        let matchingTalks = confData.talks.filter{$0.talkTitle == talkTitle}
        if matchingTalks.count != 1 {print("Error - talkTitle did not exist")}
        return matchingTalks[0].id
    }
    
    func talkTitleFrom(talkID: UUID) -> String {
        let matchingTalks = confData.talks.filter{$0.id == talkID}
        if matchingTalks.count != 1 {print("Error - talkID did not exist")}
        return matchingTalks[0].talkTitle
    }
    
    func speakersFrom(talkID: UUID) -> String {
        let matchingTalks = confData.talks.filter{$0.id == talkID}
        if matchingTalks.count != 1 {print("Error - talkID did not exist")}
        let speakerIDs = matchingTalks[0].speakerIDs
        var speakers = speakerNameFrom(speakerID: speakerIDs[0])
        if speakerIDs.count > 1 {
            speakers = speakers + " and \(speakerNameFrom(speakerID: speakerIDs[1]))"
        }
        return speakers
    }
    
    func speakerNameFrom(speakerID: String) -> String {
        let matchingSpeakers = confData.speakers.filter{$0.id == speakerID}
        if matchingSpeakers.count != 1 {print("Error - speakerID did not exist")}
        return matchingSpeakers[0].name
    }
    
    func speakerFrom(speakerID: String) -> Speaker {
        let matchingSpeakers = confData.speakers.filter{$0.id == speakerID}
        if matchingSpeakers.count != 1 {print("Error - speakerID did not exist")}
        return matchingSpeakers[0]
    }
    
    func locationFrom(talkID: UUID) -> Location {
        let matchingTalks = confData.talks.filter{$0.id == talkID}
        if matchingTalks.count != 1 {print("Error - talkID did not exist")}
        let locationID = matchingTalks[0].locationID
        let matchingLocations = confData.locations.filter{$0.id == locationID}
        return matchingLocations[0]
    }
    
    func locationFrom(locationID: String) -> Location {
        let matchingLocations = confData.locations.filter{$0.id == locationID}
        return matchingLocations[0]
    }
    
    func locationNameFrom(talkID: UUID) -> String {
        let location = locationFrom(talkID: talkID)
        return location.name
    }
    
    func locationNameFrom(locationID: String) -> String {
        let location = locationFrom(locationID: locationID)
        return location.name
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
 
}

