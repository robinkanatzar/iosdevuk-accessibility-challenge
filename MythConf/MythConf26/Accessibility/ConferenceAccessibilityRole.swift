import SwiftUI

/// Common accessibility roles used by conference UI components.
///
/// Keeping role handling in one place helps avoid accidental combinations such
/// as a link also being announced as a button.
enum ConferenceAccessibilityRole {
    case button
    case link

    var trait: AccessibilityTraits {
        switch self {
        case .button: .isButton
        case .link: .isLink
        }
    }

    static var mutuallyExclusiveTraits: AccessibilityTraits {
        [.isButton, .isLink]
    }
}
