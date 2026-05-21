//
//  IOSDevuk26App.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI
import TipKit
import Dependencies
import AppIntents
import CoreSpotlight

@main
struct MythConf: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = MythConf.makeViewModel()
    @State private var appSettings = AppSettings()
    @State private var appIntentNavigationRouter = AppIntentNavigationRouter.shared
    @State private var didUpdateAppShortcuts = false
    @State private var didIndexSearchableSessions = false

    init() {
        UIImageView.appearance().accessibilityIgnoresInvertColors = true
        setupTips()
    }

    private static func makeViewModel() -> ViewModel {
        if CommandLine.arguments.contains("-UITestingResetFavourites") {
            let favouritesURL = urlToFileInDocuments("favourites.json")
            try? FileManager.default.removeItem(at: favouritesURL)
            print("favourites Removed")
        }

        if CommandLine.arguments.contains("-UITestingResetSettings") {
            AppSettings.resetStoredSettings()
        }

        if CommandLine.arguments.contains("-UITestingResetNotifications") {
            NotificationManager.shared.cancelAll()
        }
        
        let timestamp = CommandLine.arguments.firstIndex(of: "-TestingDate")
            .flatMap { index in
                CommandLine.arguments.indices.contains(index + 1) ? Double(CommandLine.arguments[index + 1]) : nil
            }

        if let timestamp {
            let customDate = Date(timeIntervalSinceReferenceDate: timestamp)
            let offset = customDate.timeIntervalSince(Date())
            print("Injecting Testing Date: \(customDate) (Offset: \(Int(offset))s)")
            
            return withDependencies {
                $0.date = DateGenerator { Date().addingTimeInterval(offset) }
            } operation: {
                ViewModel()
            }
        } else {
            return ViewModel()
        }
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
                .environment(\.appSettings, appSettings)
                .environment(appIntentNavigationRouter)
                .foregroundStyle(.primary, .secondary, .tertiary)
                .task {
                    updateAppShortcutsOnce()
                    await indexSearchableSessionsOnce()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    updateAppShortcutsOnce()
                    viewModel.loadFavourites()
                }
        }
    }

    @MainActor
    private func updateAppShortcutsOnce() {
        guard !didUpdateAppShortcuts else { return }
        didUpdateAppShortcuts = true
        MythConfShortcutsProvider.updateAppShortcutParameters()
    }

    @MainActor
    private func indexSearchableSessionsOnce() async {
        guard !didIndexSearchableSessions else { return }
        didIndexSearchableSessions = true

        do {
            try await CSSearchableIndex
                .default()
                .indexAppEntities(ConferenceSessionStore.searchableSessions())
        } catch {
            print("Unable to index searchable sessions: \(error.localizedDescription)")
        }
    }
}
