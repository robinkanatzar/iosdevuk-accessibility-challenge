//
//  IOSDevuk26App.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

@main
struct MythConf: App {
    @State private var viewModel = ViewModel()
    
    private var isUITestDarkMode: Bool { ProcessInfo.processInfo.arguments.contains(LaunchArguments.darkModeUITests) }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(viewModel)
                .foregroundStyle(.primary, .primary.opacity(0.7), .primary.opacity(0.45))
                .preferredColorScheme(isUITestDarkMode ? .dark : nil)
        }
    }
}
