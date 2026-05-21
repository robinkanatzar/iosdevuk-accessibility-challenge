//
//  SupportFunctions.swift
//  IOSDevuk26
//
//  Created by Chris Price on 01/04/2026.
//

import Foundation

func loadConfData() -> ConfData {
    let baseName = bundledConfFileName()
    var result = ConfData(version: 0, speakers: [], talks: [], locations: [], sessions: [])
    // The Documents copy only applies to the original English `conf.json` (it
    // is written by `saveConference()`). Localised variants always come from
    // the bundle so translations stay in sync with the app build.
    if baseName == "conf", fileExistsInDocuments("conf.json") {
        let filePath = urlToFileInDocuments("conf.json")
        if let dataFromFile = try? Data(contentsOf: filePath),
           let confInfo = try? JSONDecoder().decode(ConfData.self, from: dataFromFile) {
            return confInfo
        }
    }
    guard let bundlePath = pathToFileInBundle(fileName: baseName, ending: ".json") else {
        print("Failed to find \(baseName).json in bundle")
        return result
    }
    if let dataFromFile = try? Data(contentsOf: bundlePath),
       let confInfo = try? JSONDecoder().decode(ConfData.self, from: dataFromFile) {
        result = confInfo
    }
    return result
}

/// Picks the conf JSON file name based on the effective content language.
/// Falls back to the default English `conf` file when a localised variant is
/// not bundled, so the schedule never appears empty.
private func bundledConfFileName() -> String {
    let override = UserDefaults.standard.string(forKey: "languageOverride") ?? ""
    let effective = override.isEmpty ? (Locale.current.language.languageCode?.identifier ?? "en") : override
    let candidate = effective == "ja" ? "conf-ja" : "conf"
    guard candidate != "conf" else { return "conf" }
    return Bundle.main.url(forResource: candidate, withExtension: "json") != nil ? candidate : "conf"
}

func pathToFileInBundle(fileName: String, ending: String) -> URL? {
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

func urlToFileInDocuments( _ fileName: String ) -> URL {
    let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = docDirectory.appendingPathComponent(fileName)
    return fileURL
}

func fileExistsInDocuments( _ fileName: String ) -> Bool {
    let fileManager = FileManager.default
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docsDir = dirPaths[0]
    let filepathName = docsDir + "/\(fileName)"
    return fileManager.fileExists(atPath: filepathName)
}


