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
                .appFont(.body, useLexend: viewModel.useLexendFont)
                .foregroundStyle(.primary, .primary.opacity(0.7), .primary.opacity(0.45))
        }
    }
}
