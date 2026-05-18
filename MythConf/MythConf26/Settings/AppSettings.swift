//
//  AppSettings.swift
//  IOSDevuk26
//

import SwiftUI

enum FavouriteReminderTiming: Int, CaseIterable, Identifiable {
    case off = 0
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .off:
            return "Off"
        case .fiveMinutes:
            return "5 minutes"
        case .tenMinutes:
            return "10 minutes"
        case .fifteenMinutes:
            return "15 minutes"
        }
    }

    var notificationBodyText: String {
        switch self {
        case .off:
            return ""
        case .fiveMinutes:
            return "5 minutes"
        case .tenMinutes:
            return "10 minutes"
        case .fifteenMinutes:
            return "15 minutes"
        }
    }

    var leadTime: TimeInterval? {
        guard self != .off else { return nil }
        return TimeInterval(rawValue * 60)
    }
}

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

    var favouriteReminderTiming: FavouriteReminderTiming {
        didSet {
            defaults.set(favouriteReminderTiming.rawValue, forKey: Self.favouriteReminderTimingKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.usesOpenDyslexicReadingFont = defaults.bool(forKey: Self.openDyslexicReadingFontKey)
        self.usesFavouriteHaptics = defaults.object(forKey: Self.favouriteHapticsKey) as? Bool ?? true
        self.usesFavouriteSounds = defaults.object(forKey: Self.favouriteSoundsKey) as? Bool ?? true
        let storedReminderRawValue = defaults.object(forKey: Self.favouriteReminderTimingKey) as? Int
        self.favouriteReminderTiming = storedReminderRawValue
            .flatMap(FavouriteReminderTiming.init(rawValue:)) ?? .tenMinutes
    }

    static let openDyslexicReadingFontKey = "usesOpenDyslexicReadingFont"
    static let favouriteHapticsKey = "usesFavouriteHaptics"
    static let favouriteSoundsKey = "usesFavouriteSounds"
    static let favouriteReminderTimingKey = "favouriteReminderTiming"

    static func resetStoredSettings(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: openDyslexicReadingFontKey)
        defaults.removeObject(forKey: favouriteHapticsKey)
        defaults.removeObject(forKey: favouriteSoundsKey)
        defaults.removeObject(forKey: favouriteReminderTimingKey)
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
