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

    var usesFavouriteHaptics: Bool {
        didSet {
            defaults.set(usesFavouriteHaptics, forKey: Self.favouriteHapticsKey)
        }
    }

    var usesFavouriteSounds: Bool {
        didSet {
            defaults.set(usesFavouriteSounds, forKey: Self.favouriteSoundsKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.usesOpenDyslexicReadingFont = defaults.bool(forKey: Self.openDyslexicReadingFontKey)
        self.usesFavouriteHaptics = defaults.object(forKey: Self.favouriteHapticsKey) as? Bool ?? true
        self.usesFavouriteSounds = defaults.object(forKey: Self.favouriteSoundsKey) as? Bool ?? true
    }

    static let openDyslexicReadingFontKey = "usesOpenDyslexicReadingFont"
    static let favouriteHapticsKey = "usesFavouriteHaptics"
    static let favouriteSoundsKey = "usesFavouriteSounds"

    static func resetStoredSettings(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: openDyslexicReadingFontKey)
        defaults.removeObject(forKey: favouriteHapticsKey)
        defaults.removeObject(forKey: favouriteSoundsKey)
    }
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
