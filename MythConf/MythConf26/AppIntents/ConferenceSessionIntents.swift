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

struct FavouriteSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Favourite Session"
    static var description = IntentDescription("Favourite an existing MythConf session so it appears in your schedule.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        requestValueDialog: IntentDialog("Which MythConf session should I favourite?")
    )
    var session: ConferenceSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Favourite \(\.$session)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let added = try await ConferenceSessionStore.addFavourite(session.id)
            if added {
                return .result(dialog: IntentDialog("Favourited \(session.title). It is now in your schedule. It is on \(session.dayAndDate). \(session.spokenTimeRange) In \(session.locationName)."))
            } else {
                return .result(dialog: IntentDialog("\(session.title) is already favourited and in your schedule. It is on \(session.dayAndDate). \(session.spokenTimeRange) In \(session.locationName)."))
            }
        } catch {
            throw MythConfIntentError(message: "I could not update your favourites. Please try again.")
        }
    }
}

struct UnfavouriteSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Unfavourite Session"
    static var description = IntentDescription("Remove an existing MythConf session from favourites and your schedule.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        requestValueDialog: IntentDialog("Which MythConf session should I unfavourite?")
    )
    var session: ConferenceSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Unfavourite \(\.$session)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let removed = try await ConferenceSessionStore.removeFavourite(session.id)
            if removed {
                return .result(dialog: IntentDialog("Removed \(session.title) from favourites. It is no longer in your schedule."))
            } else {
                return .result(dialog: IntentDialog("\(session.title) was not favourited."))
            }
        } catch {
            throw MythConfIntentError(message: "I could not update your favourites. Please try again.")
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
            return .result(dialog: IntentDialog("Your schedule is empty. Favourite sessions from the Programme, or ask me to favourite a session."))
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
            intent: FavouriteSessionIntent(),
            phrases: [
                "Favourite \(\.$session) in \(.applicationName)",
                "Add \(\.$session) to favourites in \(.applicationName)",
                "Save \(\.$session) in \(.applicationName)"
            ],
            shortTitle: "Favourite",
            systemImageName: "star"
        )

        AppShortcut(
            intent: UnfavouriteSessionIntent(),
            phrases: [
                "Unfavourite \(\.$session) in \(.applicationName)",
                "Remove \(\.$session) from favourites in \(.applicationName)"
            ],
            shortTitle: "Unfavourite",
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
