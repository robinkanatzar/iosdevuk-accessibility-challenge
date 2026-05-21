//
//  MapsURLBuilder.swift
//  MythConf26
//

import Foundation

enum MapsURLBuilder {
    static func url(locationName: String, latitude: Double, longitude: Double) -> URL? {
        let query = locationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? locationName
        return URL(string: "http://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(query)")
    }
}
