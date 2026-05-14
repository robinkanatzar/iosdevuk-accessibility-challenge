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

    /// SF Symbol that represents this session type. Used as a redundant,
    /// shape-based cue alongside `color` so users with the
    /// `Differentiate Without Color` accessibility setting can tell session
    /// types apart by icon as well as colour.
    var symbolName: String {
        switch self {
        case .talk:           return "bubble.left.and.bubble.right"
        case .panel:          return "person.3.sequence"
        case .workshop:       return "hammer"
        case .lightningtalks: return "bolt"
        case .teaBreak:       return "cup.and.saucer"
        case .lunch:          return "fork.knife"
        case .dinner:         return "fork.knife.circle"
        case .confdinner:     return "wineglass"
        case .social:         return "person.2.wave.2"
        case .registration:   return "person.badge.plus"
        case .railtrip:       return "train.side.front.car"
        case .dummy:          return ""
        }
    }
}
