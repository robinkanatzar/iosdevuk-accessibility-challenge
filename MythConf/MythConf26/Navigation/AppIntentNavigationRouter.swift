//
//  AppIntentNavigationRouter.swift
//  MythConf26
//

import Foundation
import Observation

@MainActor
@Observable
final class AppIntentNavigationRouter {
    static let shared = AppIntentNavigationRouter()

    var pendingTalkID: UUID?

    private init() {}

    func openSession(talkID: UUID) {
        pendingTalkID = talkID
    }
}
