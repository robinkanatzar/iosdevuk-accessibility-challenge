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

    var iconName: String {
        switch self {
        case .talk: return "mic.fill"
        case .panel: return "person.3.fill"
        case .workshop: return "hammer.fill"
        case .lightningtalks: return "bolt.fill"
        case .teaBreak: return "cup.and.saucer.fill"
        case .lunch: return "fork.knife"
        case .dinner: return "fork.knife"
        case .confdinner: return "fork.knife"
        case .social: return "bubbles.and.sparkles.fill"
        case .registration: return "person.badge.key.fill"
        case .railtrip: return "tram.fill"
        case .dummy: return ""
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
