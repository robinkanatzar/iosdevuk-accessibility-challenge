//
//  IOSDevuk26App.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI
import TipKit

@main
struct MythConf: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = ViewModel()

    init() {
        try? Tips.configure([
            .datastoreLocation(.applicationDefault),
            .displayFrequency(.daily)
        ])

        if CommandLine.arguments.contains("-UITestingResetFavourites") {
            Tips.hideAllTipsForTesting()
            let favouritesURL = urlToFileInDocuments("favourites.json")
            try? FileManager.default.removeItem(at: favouritesURL)
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(viewModel)
                .foregroundStyle(.primary, .secondary, .tertiary)
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    viewModel.loadFavourites()
                }
        }
    }
}
