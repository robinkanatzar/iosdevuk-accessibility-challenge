//
//  GetSessionDetailsIntent.swift
//  MythConf26
//

import AppIntents
import SwiftUI

struct GetSessionDetailsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Session Details"
    static var description = IntentDescription("Hear and view details for a conference session.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        description: "The session to get details for.",
        requestValueDialog: IntentDialog("Which session do you want details for?")
    )
    var session: SearchableSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Get details for \(\.$session)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<SearchableSessionEntity> & ProvidesDialog & ShowsSnippetView {
        guard let resolvedSession = ConferenceSessionStore.searchableSession(for: session.id) else {
            throw MythConfIntentError.sessionNotFound
        }

        let dialog = IntentDialog(
            full: "\(resolvedSession.spokenDetails)",
            supporting: "Here's the session information."
        )

        return .result(
            value: resolvedSession,
            dialog: dialog,
            view: SessionSiriDetailSnippetView(session: resolvedSession)
        )
    }
}

enum MythConfIntentError: Error, CustomLocalizedStringResourceConvertible {
    case sessionNotFound
    case directionsUnavailable

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .sessionNotFound:
            return "I could not find that session."
        case .directionsUnavailable:
            return "I could not open directions for that session."
        }
    }
}
