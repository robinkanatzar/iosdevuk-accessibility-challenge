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
        setupTips()

        if CommandLine.arguments.contains("-UITestingResetFavourites") {
            let favouritesURL = urlToFileInDocuments("favourites.json")
            try? FileManager.default.removeItem(at: favouritesURL)
        }
    }

    // Configure tips in the app.
    func setupTips() {
        do {
            #if DEBUG
            Tips.hideAllTipsForTesting()
            #endif

            try Tips.configure([
                .datastoreLocation(.applicationDefault),
                .displayFrequency(.daily)
            ])
        }
        catch {
            print("Error initializing TipKit \(error.localizedDescription)")
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
