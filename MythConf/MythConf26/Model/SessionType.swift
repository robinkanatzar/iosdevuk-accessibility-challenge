//
//  SessionType.swift
//  IOSDevuk26
//
//  Created by Chris Price on 27/03/2026.
//

import SwiftUI

enum SessionType: Codable {
    case talk
    case panel
    case workshop
    case teaBreak
    case lunch
    case dinner
    case social
    case confdinner
    case registration
    case railtrip
    case lightningtalks
    case dummy  // Used when there are no favourites on a day
    
    var displayName: String {
        switch self {
        case .talk: return "Talk"
        case .panel: return "Discussion Panel"
        case .workshop: return "Workshop"
        case .teaBreak: return "Tea / Coffee Break"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .social: return "Social Event"
        case .confdinner: return "Conference Dinner"
        case .registration: return "Registration"
        case .railtrip: return "Rail Trip"
        case .lightningtalks: return "Lightning Talks"
        case .dummy: return ""
        }
    }
    
    var symbolName: String {
        switch self {
        case .talk: "person.wave.2"
        case .panel: "person.3"
        case .workshop: "hammer"
        case .teaBreak: "cup.and.saucer"
        case .lunch: "fork.knife"
        case .dinner, .confdinner: "fork.knife.circle"
        case .social: "person.2"
        case .registration: "checkmark.seal"
        case .railtrip: "tram"
        case .lightningtalks: "bolt"
        case .dummy: "calendar"
        }
    }

    var color: Color {
        switch self {
        case .talk:          return .blue
        case .panel:         return .purple
        case .workshop:      return .blue
        case .lightningtalks: return .yellow
        case .teaBreak:      return .green
        case .lunch:         return .mint
        case .dinner:        return .pink
        case .confdinner:    return .pink
        case .social:        return .teal
        case .registration:  return .indigo
        case .railtrip:      return .cyan
        case .dummy:         return .clear
        }
    }
}
