//
//  SupportFunctions.swift
//  IOSDevuk26
//
//  Created by Chris Price on 01/04/2026.
//

import Foundation

nonisolated func loadConfData() -> ConfData{
    var result = ConfData(version: 0, speakers: [], talks: [], locations: [], sessions: [])
    let filename = "conf.json"
    var filePath = urlToFileInDocuments(filename)
    print("File in docs is \(filePath)")
    
    if !fileExistsInDocuments(filename) {
        guard let bundlePath = pathToFileInBundle(fileName: "conf", ending: ".json")  else {
            print("Failed to find speaker file in bundle")
            return result
        }
        filePath = bundlePath
    }
    if let dataFromFile = try? Data(contentsOf: filePath) {
        // Decode the JSON back to state of program
        let decoder = JSONDecoder()
        if let confInfo = try? decoder.decode(ConfData.self, from: dataFromFile) {
            result = confInfo
        }
    }
    
    return result
}

nonisolated func pathToFileInBundle(fileName: String, ending: String) -> URL? {
    //Set up path to default DB, and open
    let bundle = Bundle.main
    guard let bundlePath = bundle.url( forResource: fileName, withExtension: ending)
    else {
        assertionFailure( "Couldn't find file path for \(fileName).json in bundle")
        return nil
    }
    print("bundle path is ", bundlePath)
    return bundlePath
}

nonisolated func urlToFileInDocuments( _ fileName: String ) -> URL {
    let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = docDirectory.appendingPathComponent(fileName)
    return fileURL
}

nonisolated func fileExistsInDocuments( _ fileName: String ) -> Bool {
    let fileManager = FileManager.default
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docsDir = dirPaths[0]
    let filepathName = docsDir + "/\(fileName)"
    return fileManager.fileExists(atPath: filepathName)
}

extension Locale {
    var uses24HourClock: Bool {
        switch hourCycle {
        case .zeroToTwentyThree, .oneToTwentyFour:
            return true
        case .zeroToEleven, .oneToTwelve:
            return false
        @unknown default:
            return false
        }
    }
}

