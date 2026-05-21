//
//  DateOverride.swift
//  IOSDevuk26
//

import Foundation
import Observation

/// Provides the "current time" used by the Programme countdown banner and the
/// `ConfData` time-of-conference calculations. Allows judges, QA, and the
/// developer to override the wall clock from within the app so the
/// before-conf / day-of / after-conf banner states can be previewed without
/// changing the device clock.
@MainActor
@Observable
final class DateOverride {
    static let shared = DateOverride()

    /// When non-nil, this date is used in place of `Date.now`.
    var overrideDate: Date?

    /// Current "now" — uses the override if set, otherwise the real wall clock.
    var now: Date { overrideDate ?? .now }

    /// Whether an override is currently active.
    var isOverriding: Bool { overrideDate != nil }

    private init() {}
}
