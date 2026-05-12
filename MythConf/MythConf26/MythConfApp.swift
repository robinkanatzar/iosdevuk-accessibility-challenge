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
    @State private var viewModel = MythConf.makeViewModel()
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    init() {
        setupTips()
    }

    private static func makeViewModel() -> ViewModel {
        if CommandLine.arguments.contains("-UITestingResetFavourites") {
            let favouritesURL = urlToFileInDocuments("favourites.json")
            try? FileManager.default.removeItem(at: favouritesURL)
            print("favourites Removed")
        }
        return ViewModel() // now loads from an already-deleted file
    }


    // Configure tips in the app.
    func setupTips() {
        let accessibilityEnabled = UIAccessibility.isVoiceOverRunning
        do {
            if CommandLine.arguments.contains("-UITesting") ||
                CommandLine.arguments.contains("-UITestingResetFavourites") ||
                accessibilityEnabled {

                Tips.hideAllTipsForTesting()

            }

            try Tips.configure()
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
