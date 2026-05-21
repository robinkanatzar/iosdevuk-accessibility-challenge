//
//  ConferenceSessionIntents.swift
//  MythConf26
//

import AppIntents
import Foundation
import SwiftUI

struct ReadMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Read Your Schedule"
    static var description = IntentDescription("Hear a summary of the sessions currently saved in your schedule.")
    static var openAppWhenRun = false

    static var parameterSummary: some ParameterSummary {
        Summary("Read your schedule")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let sessions = ConferenceSessionStore.favouriteSessions()

        guard !sessions.isEmpty else {
            let dialog = IntentDialog(
                full: "Your schedule is empty. Favourite sessions from the Programme, then ask me to read your schedule.",
                supporting: "Your schedule is empty."
            )
            return .result(dialog: dialog, view: ScheduleSiriSnippetView(sessions: [], remainingCount: 0))
        }

        let sessionCountText = sessions.count == 1 ? "1 session" : "\(sessions.count) sessions"
        let spokenSessionLimit = 8
        let snippetSessionLimit = 4
        let spokenSessions = sessions.prefix(spokenSessionLimit).map(\.shortScheduleLine).joined(separator: ". ")
        let snippetSessions = Array(sessions.prefix(snippetSessionLimit))
        let snippetRemainingCount = sessions.count - snippetSessions.count
        let remainingCount = sessions.count - spokenSessionLimit
        let fullDialog: String
        let supportingDialog = "Here's your saved schedule."

        if remainingCount > 0 {
            let remainingText = remainingCount == 1 ? "1 more saved session" : "\(remainingCount) more saved sessions"
            fullDialog = "You have \(sessionCountText) in your schedule. \(spokenSessions). There are \(remainingText) in the app."
        } else {
            fullDialog = "You have \(sessionCountText) in your schedule. \(spokenSessions)."
        }

        let dialog = IntentDialog(full: "\(fullDialog)", supporting: "\(supportingDialog)")
        return .result(
            dialog: dialog,
            view: ScheduleSiriSnippetView(sessions: snippetSessions, remainingCount: snippetRemainingCount)
        )
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

        AppShortcut(
            intent: GetSessionDetailsIntent(),
            phrases: [
                "Get session details in \(.applicationName)",
                "Tell me about a session in \(.applicationName)"
            ],
            shortTitle: "Session Details",
            systemImageName: "text.bubble",
            parameterPresentation: ParameterPresentation(
                for: \.$session,
                summary: Summary("Get details for \(\.$session)")
            ) {
                OptionsCollection(SearchableSessionQuery(), title: "Sessions", systemImageName: "text.bubble")
            }
        )

        AppShortcut(
            intent: GetDirectionsToSessionIntent(),
            phrases: [
                "Get directions to a session in \(.applicationName)",
                "Show directions to a session in \(.applicationName)"
            ],
            shortTitle: "Directions",
            systemImageName: "map",
            parameterPresentation: ParameterPresentation(
                for: \.$session,
                summary: Summary("Get directions to \(\.$session)")
            ) {
                OptionsCollection(SearchableSessionQuery(), title: "Sessions", systemImageName: "map")
            }
        )
    }
}
