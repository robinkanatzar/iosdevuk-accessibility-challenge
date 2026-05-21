//
//  ConferenceSessionIntents.swift
//  MythConf26
//

import AppIntents
import Foundation

struct ReadMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Read Your Schedule"
    static var description = IntentDescription("Hear a summary of the sessions currently saved in your schedule.")
    static var openAppWhenRun = false

    static var parameterSummary: some ParameterSummary {
        Summary("Read your schedule")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let sessions = ConferenceSessionStore.favouriteSessions()

        guard !sessions.isEmpty else {
            return .result(dialog: IntentDialog("Your schedule is empty. Favourite sessions from the Programme, then ask me to read your schedule."))
        }

        let sessionCountText = sessions.count == 1 ? "1 session" : "\(sessions.count) sessions"
        let spokenSessionLimit = 8
        let visibleSessions = sessions.prefix(spokenSessionLimit).map(\.shortScheduleLine).joined(separator: ". ")
        let remainingCount = sessions.count - spokenSessionLimit

        if remainingCount > 0 {
            let remainingText = remainingCount == 1 ? "1 more saved session" : "\(remainingCount) more saved sessions"
            return .result(dialog: IntentDialog("You have \(sessionCountText) in your schedule. \(visibleSessions). There are \(remainingText) in the app."))
        } else {
            return .result(dialog: IntentDialog("You have \(sessionCountText) in your schedule. \(visibleSessions)."))
        }
    }
}

struct MythConfShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .blue

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ReadMyScheduleIntent(),
            phrases: [
                "Read my schedule in \(.applicationName)",
                "Read your schedule in \(.applicationName)",
                "What is on my schedule in \(.applicationName)",
                "Tell me my schedule in \(.applicationName)",
                "What have I saved in \(.applicationName)",
                "Read saved sessions in \(.applicationName)"
            ],
            shortTitle: "Read Schedule",
            systemImageName: "calendar"
        )
    }
}
