//
//  GetDirectionsToSessionIntent.swift
//  MythConf26
//

import AppIntents
import UIKit

struct GetDirectionsToSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Directions to Session"
    static var description = IntentDescription("Open Apple Maps directions for a conference session location.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        description: "The session to get directions to.",
        requestValueDialog: IntentDialog("Which session do you want directions to?")
    )
    var session: SearchableSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Get directions to \(\.$session)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let resolvedSession = ConferenceSessionStore.searchableSession(for: session.id),
              let mapsURL = MapsURLBuilder.url(
                locationName: resolvedSession.locationName,
                latitude: resolvedSession.latitude,
                longitude: resolvedSession.longitude
              ) else {
            throw MythConfIntentError.directionsUnavailable
        }

        let dialog = IntentDialog(
            full: "Opening Apple Maps for directions to \(resolvedSession.locationName), where \(resolvedSession.title) is taking place.",
            supporting: "Opening directions to \(resolvedSession.locationName)."
        )

        await UIApplication.shared.open(mapsURL)
        return .result(dialog: dialog)
    }
}
