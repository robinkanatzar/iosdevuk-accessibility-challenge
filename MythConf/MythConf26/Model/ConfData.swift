//
//  ConfData.swift
//  TalkGenerator
//
//  Created by Chris Price on 28/06/2022.
//

import Foundation

struct ConfData: Codable {
    let version: Int
    let speakers: [Speaker]
    let talks: [Talk]
    let locations: [Location]
    let sessions: [[Session]]

    /// Determines where we are in time relative to the conference schedule.
    /// `now` defaults to the real wall clock but can be supplied so callers
    /// (e.g. the in-app debug date override) can ask "what state would the
    /// conference be in at this hypothetical moment?".
    func whereInConf(now: Date = .now) -> ConfTimeType {
        guard let firstDay = sessions.first,
              let lastDay = sessions.last,
              let confStart = firstDay.first?.startTime,
              let confEnd = lastDay.last?.endTime else {
            return .beforeConf
        }
        if now < confStart && !Calendar.current.isDate(now, inSameDayAs: confStart) { return .beforeConf }
        if now > confEnd { return .afterConf }

        for daySessions in sessions {
            guard let dayStart = daySessions.first?.startTime,
                  let dayEnd = daySessions.last?.endTime else { continue }
            if Calendar.current.isDate(now, inSameDayAs: dayStart) {
                if now < dayStart { return .beforeConfDayStart }
                if now > dayEnd { return .afterConfDayEnd }
                return .duringConfDay
            }
        }
        return .dummy
    }

    /// Returns the session that contains `now` within its `[startTime, endTime]`
    /// range, regardless of conference day. Used by the Programme banner to
    /// surface the currently-active session (talk slot or break).
    func currentSession(now: Date = .now) -> Session? {
        for daySessions in sessions {
            for session in daySessions where now >= session.startTime && now <= session.endTime {
                return session
            }
        }
        return nil
    }

    /// Returns the current session and (if present) the next one for the current day.
    func nowAndNextSession(whereInDay: ConfTimeType, now: Date = .now) -> [Session] {
        for daySessions in sessions {
            guard let dayStart = daySessions.first?.startTime else { continue }

            if Calendar.current.isDate(now, inSameDayAs: dayStart) {
                if whereInDay == .beforeConfDayStart {
                    return Array(daySessions.prefix(2))
                } else if whereInDay == .duringConfDay {
                    var index = 0
                    while now > daySessions[index].endTime && index < daySessions.count - 1 {
                        index += 1
                    }
                    return index == daySessions.count - 1
                        ? [daySessions[index]]
                        : [daySessions[index], daySessions[index + 1]]
                }
            } else if whereInDay == .afterConfDayEnd {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
                if Calendar.current.isDate(tomorrow, inSameDayAs: dayStart) {
                    return Array(daySessions.prefix(2))
                }
            }
        }
        return []
    }
}
