//
//  IOSDevuk26App.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI
import AppIntents

enum AppTab: String, CaseIterable {
    case programme, speakers, locations, mySchedule
}

@Observable
class AppNavigation {
    static let shared = AppNavigation()
    var selectedTab: AppTab = .programme
}

@main
struct MythConf: App {
    @State private var viewModel = ViewModel()
    @State private var appNavigation = AppNavigation.shared
    @AppStorage("useDyslexiaFont") private var useDyslexiaFont = false

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(viewModel)
                .environment(appNavigation)
                .fontDesign(useDyslexiaFont ? .rounded : .default)
        }
    }
}

// MARK: - App Intents for Siri Shortcuts

struct ShowMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Show My Schedule"
    static var description = IntentDescription("Opens your favourited conference sessions")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppNavigation.shared.selectedTab = .mySchedule
        return .result()
    }
}

struct WhatsOnNextIntent: AppIntent {
    static var title: LocalizedStringResource = "What's On Next"
    static var description = IntentDescription("Shows the current or next conference session")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppNavigation.shared.selectedTab = .programme
        return .result()
    }
}

struct ConferenceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowMyScheduleIntent(),
            phrases: ["Show my schedule in \(.applicationName)", "My \(.applicationName) schedule"],
            shortTitle: "My Schedule",
            systemImageName: "star"
        )
        AppShortcut(
            intent: WhatsOnNextIntent(),
            phrases: ["What's on next in \(.applicationName)", "Next session in \(.applicationName)"],
            shortTitle: "What's Next",
            systemImageName: "calendar"
        )
    }
}
