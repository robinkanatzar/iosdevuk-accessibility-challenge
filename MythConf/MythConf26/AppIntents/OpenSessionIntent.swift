//
//  OpenSessionIntent.swift
//  MythConf26
//

import AppIntents

struct OpenSessionIntent: AppIntent, OpenIntent {
    static let title: LocalizedStringResource = "Open Session"
    static var isDiscoverable = false

    @Parameter(title: "Session")
    var target: SearchableSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$target)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        AppIntentNavigationRouter.shared.openSession(talkID: target.id)
        return .result()
    }
}
