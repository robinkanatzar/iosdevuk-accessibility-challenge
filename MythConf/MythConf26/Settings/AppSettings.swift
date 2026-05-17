//
//  AppSettings.swift
//  IOSDevuk26
//

import SwiftUI

@Observable
final class AppSettings {
    private let defaults: UserDefaults

    var usesOpenDyslexicReadingFont: Bool {
        didSet {
            defaults.set(usesOpenDyslexicReadingFont, forKey: Self.openDyslexicReadingFontKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.usesOpenDyslexicReadingFont = defaults.bool(forKey: Self.openDyslexicReadingFontKey)
    }

    static let openDyslexicReadingFontKey = "usesOpenDyslexicReadingFont"
}

private struct AppSettingsKey: EnvironmentKey {
    static let defaultValue = AppSettings()
}

extension EnvironmentValues {
    var appSettings: AppSettings {
        get { self[AppSettingsKey.self] }
        set { self[AppSettingsKey.self] = newValue }
    }
}
