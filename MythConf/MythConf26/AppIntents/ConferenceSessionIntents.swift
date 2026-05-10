//
//  ConferenceSessionIntents.swift
//  MythConf26
//

import AppIntents
import Foundation

private struct MythConfIntentError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

struct GetSessionDetailsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Session Details"
    static var description = IntentDescription("Hear the time, speaker, location, and summary for a MythConf session.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        requestValueDialog: IntentDialog("Which MythConf session do you want details for?")
    )
    var session: ConferenceSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Get details for \(\.$session)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog("\(session.spokenDetails)"))
    }
}

struct AddSessionToMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Session to Your Schedule"
    static var description = IntentDescription("Add an existing MythConf session to your schedule.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        requestValueDialog: IntentDialog("Which MythConf session should I add to your schedule?")
    )
    var session: ConferenceSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$session) to your schedule")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let added = try await ConferenceSessionStore.addFavourite(session.id)
            if added {
                return .result(dialog: IntentDialog("Added \(session.title) to your schedule. It is on \(session.dayAndDate) from \(session.timeRange), in \(session.locationName)."))
            } else {
                return .result(dialog: IntentDialog("\(session.title) is already in your schedule. It is on \(session.dayAndDate) from \(session.timeRange), in \(session.locationName)."))
            }
        } catch {
            throw MythConfIntentError(message: "I could not update your schedule. Please try again.")
        }
    }
}

struct RemoveSessionFromMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Remove Session from Your Schedule"
    static var description = IntentDescription("Remove an existing MythConf session from your schedule.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        requestValueDialog: IntentDialog("Which MythConf session should I remove from your schedule?")
    )
    var session: ConferenceSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Remove \(\.$session) from your schedule")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let removed = try await ConferenceSessionStore.removeFavourite(session.id)
            if removed {
                return .result(dialog: IntentDialog("Removed \(session.title) from your schedule."))
            } else {
                return .result(dialog: IntentDialog("\(session.title) was not in your schedule."))
            }
        } catch {
            throw MythConfIntentError(message: "I could not update your schedule. Please try again.")
        }
    }
}

struct ReadMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Read Your Schedule"
    static var description = IntentDescription("Hear a summary of the sessions currently saved in your schedule.")
    static var openAppWhenRun = false

    static var parameterSummary: some ParameterSummary {
        Summary("Read your schedule")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let sessions = await ConferenceSessionStore.favouriteSessions()

        guard !sessions.isEmpty else {
            return .result(dialog: IntentDialog("Your schedule is empty. Add sessions from the Programme by asking me to add a session to your schedule."))
        }

        let sessionCountText = sessions.count == 1 ? "1 session" : "\(sessions.count) sessions"
        let visibleSessions = sessions.prefix(5).map(\.shortScheduleLine).joined(separator: ". ")
        let remainingCount = sessions.count - 5

        if remainingCount > 0 {
            return .result(dialog: IntentDialog("You have \(sessionCountText) in your schedule. \(visibleSessions). There are \(remainingCount) more sessions in the app."))
        } else {
            return .result(dialog: IntentDialog("You have \(sessionCountText) in your schedule. \(visibleSessions)."))
        }
    }
}

struct MythConfShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .blue

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetSessionDetailsIntent(),
            phrases: [
                "Tell me about \(\.$session) in \(.applicationName)",
                "Get details for \(\.$session) in \(.applicationName)",
                "What is \(\.$session) in \(.applicationName)"
            ],
            shortTitle: "Session Details",
            systemImageName: "text.bubble"
        )

        AppShortcut(
            intent: AddSessionToMyScheduleIntent(),
            phrases: [
                "Add \(\.$session) to my schedule in \(.applicationName)",
                "Add \(\.$session) to your schedule in \(.applicationName)",
                "Save \(\.$session) in \(.applicationName)",
                "Favourite \(\.$session) in \(.applicationName)"
            ],
            shortTitle: "Add Session",
            systemImageName: "star"
        )

        AppShortcut(
            intent: RemoveSessionFromMyScheduleIntent(),
            phrases: [
                "Remove \(\.$session) from my schedule in \(.applicationName)",
                "Remove \(\.$session) from your schedule in \(.applicationName)",
                "Unfavourite \(\.$session) in \(.applicationName)",
                "Delete \(\.$session) from my schedule in \(.applicationName)"
            ],
            shortTitle: "Remove Session",
            systemImageName: "star.slash"
        )

        AppShortcut(
            intent: ReadMyScheduleIntent(),
            phrases: [
                "Read my schedule in \(.applicationName)",
                "Read your schedule in \(.applicationName)",
                "What is on my schedule in \(.applicationName)",
                "Tell me my schedule in \(.applicationName)"
            ],
            shortTitle: "Read Schedule",
            systemImageName: "calendar"
        )
    }
}
