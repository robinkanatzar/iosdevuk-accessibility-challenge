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

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(viewModel)
                .foregroundStyle(.primary, .secondary, .tertiary)
        }
    }
}
