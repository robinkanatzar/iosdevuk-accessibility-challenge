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
    @State private var networkMonitor = NetworkMonitor()
    @AppStorage("languageOverride") private var languageOverride: String = ""

    /// Locale to apply to SwiftUI's `\.locale` environment so that
    /// `Text` / `Label` look up the right translations. When no override is
    /// set we fall back to the system's locale.
    private var effectiveLocale: Locale {
        languageOverride.isEmpty ? Locale.current : Locale(identifier: languageOverride)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(viewModel)
                .environment(networkMonitor)
                .environment(\.locale, effectiveLocale)
                .onChange(of: effectiveLocale) { _, _ in
                    // Reload the bundled conf JSON because the active language
                    // determines which file (conf.json / conf-ja.json) we read.
                    viewModel.reload()
                }
                .task {
                    // Pre-fetch venue map snapshots so the Locations screens
                    // remain usable when the network is unavailable. Only
                    // missing files are generated, so this is a no-op on
                    // subsequent launches.
                    await LocationMapSnapshotCache.shared.prefetchMissing(
                        locations: viewModel.confData.locations
                    )
                }
        }
    }
}
