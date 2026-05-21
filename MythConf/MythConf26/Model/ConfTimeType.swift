//
//  ConfTimeType.swift
//  IOSDevuk26
//
//  Created by Chris Price on 27/03/2026.
//

nonisolated enum ConfTimeType {
    case beforeConf
    case afterConf
    case beforeConfDayStart
    case afterConfDayEnd
    case duringConfDay
    case dummy  // Used when there are no favourites on a day
    
    var displayName: String {
        switch self {
        case .beforeConf: return "iOSDevUK starts on 7th September"
        case .afterConf: return "iOSDevUK has finished - back in 2027!"
        case .beforeConfDayStart: return "Before Day Start"
        case .afterConfDayEnd: return "After Day End"
        case .duringConfDay: return "During Day"
        case .dummy: return ""
        }
    }
}
