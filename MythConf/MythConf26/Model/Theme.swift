//
//  Theme.swift
//  IOSDevuk26
//

import SwiftUI

/// User-selectable colour palette for the app. Each theme provides an
/// accent tint, a page background, and a colour for every `SessionType`.
///
/// The four themes target distinct accessibility needs:
/// - `.default` keeps the app's original palette so existing users see no change.
/// - `.highContrast` uses saturated colours for low-vision users.
/// - `.calm` uses muted, cool tones to reduce sensory load.
/// - `.focus` uses bright, well-separated hues for pre-attentive categorisation
///   (helpful for ADHD-style attention regulation).
///
/// All custom palette entries provide explicit Light and Dark Mode variants so
/// each theme stays legible whichever interface style the user is in. The
/// `.default` theme relies on SwiftUI's system colours, which already adapt.
enum Theme: String, CaseIterable, Identifiable, Codable {
    case `default`
    case highContrast
    case calm
    case focus

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default:      "Default"
        case .highContrast: "High Contrast"
        case .calm:         "Calm"
        case .focus:        "Focus"
        }
    }

    var description: String {
        switch self {
        case .default:      "The app's original palette."
        case .highContrast: "Strong, saturated colours for low vision."
        case .calm:         "Soft, muted tones to reduce sensory load."
        case .focus:        "Bright, distinct colours that scan quickly."
        }
    }

    /// Opacity of the session-type colour tint applied to talk card backgrounds.
    /// High Contrast uses a much higher value so the session category is strongly
    /// visible without relying on the SessionTypeBar alone.
    var cardTintOpacity: (light: Double, dark: Double) {
        switch self {
        case .default:      (0.10, 0.25)
        case .highContrast: (0.22, 0.45)
        case .calm:         (0.10, 0.25)
        case .focus:        (0.13, 0.30)
        }
    }

    /// App-wide tint colour, applied via `.tint(...)` at the app root.
    var accent: Color {
        switch self {
        case .default:      .blue
        case .highContrast: Self.hex(light: 0x1F2A6E, dark: 0xA5A0FF)
        case .calm:         Self.hex(light: 0x7B9C8C, dark: 0x90A89B)
        case .focus:        Self.hex(light: 0xFF6A00, dark: 0xFF9933)
        }
    }

    /// Root background colour applied behind the tab view.
    ///
    /// Each non-default theme provides a distinct background that supports its
    /// character: pure white/black for High Contrast, warm cream/charcoal for
    /// Calm, and a slightly cool tint for Focus so its vivid hues read brighter.
    var pageBackground: Color {
        switch self {
        case .default:      Color(.systemBackground)
        case .highContrast: Self.hex(light: 0xFFFFFF, dark: 0x000000)
        case .calm:         Self.hex(light: 0xF7F2EA, dark: 0x1C1F22)
        case .focus:        Self.hex(light: 0xF8F9FB, dark: 0x10131C)
        }
    }

    /// Resolves the colour used for a session type under the current theme.
    func color(for sessionType: SessionType) -> Color {
        switch self {
        case .default:      sessionType.color
        case .highContrast: Self.highContrastColor(for: sessionType)
        case .calm:         Self.calmColor(for: sessionType)
        case .focus:        Self.focusColor(for: sessionType)
        }
    }

    // MARK: - Palette tables

    // High Contrast: deep saturated colours on a pure-white BG in Light Mode,
    // bright saturated colours on a pure-black BG in Dark Mode. Dark variants
    // are pushed brighter so they reach > 7:1 luminance contrast against black.
    private static func highContrastColor(for sessionType: SessionType) -> Color {
        switch sessionType {
        case .talk:           hex(light: 0x0050C8, dark: 0x4D9FFF)
        case .workshop:       hex(light: 0x006B6E, dark: 0x33E0E5)
        case .panel:          hex(light: 0x5E00B5, dark: 0xCC66FF)
        case .lightningtalks: hex(light: 0xFF6E00, dark: 0xFF9933)
        case .teaBreak:       hex(light: 0x4A4D5A, dark: 0xB8BCC8)
        case .lunch:          hex(light: 0x007D5A, dark: 0x55E08F)
        case .dinner:         hex(light: 0xB41A66, dark: 0xFF80C0)
        case .confdinner:     hex(light: 0xA00010, dark: 0xFF7080)
        case .social:         hex(light: 0x006E80, dark: 0x70E0E5)
        case .registration:   hex(light: 0x2F2A6B, dark: 0xA5A0FF)
        case .railtrip:       hex(light: 0x00626E, dark: 0x70E0D5)
        case .dummy:          .clear
        }
    }

    // Calm: dusty pastels in light mode, mid-tone muted versions in dark mode.
    // Dark variants are lifted from the very-dark previous values so the
    // soft tint actually shows through the card's 30%-opacity background.
    private static func calmColor(for sessionType: SessionType) -> Color {
        switch sessionType {
        case .talk:           hex(light: 0x9CB6D9, dark: 0x7A95B5)
        case .workshop:       hex(light: 0x9CB39A, dark: 0x7A9A7A)
        case .panel:          hex(light: 0xB8A5C8, dark: 0x9783A8)
        case .lightningtalks: hex(light: 0xE5D885, dark: 0xB8AA55)
        case .teaBreak:       hex(light: 0xC8BFC8, dark: 0x847C82)
        case .lunch:          hex(light: 0xA5C0A3, dark: 0x7DA07B)
        case .dinner:         hex(light: 0xD9A5B0, dark: 0xA88086)
        case .confdinner:     hex(light: 0x9F7B91, dark: 0x8A6678)
        case .social:         hex(light: 0xA5B8C7, dark: 0x808F9C)
        case .registration:   hex(light: 0x8B9DC3, dark: 0x6A7A92)
        case .railtrip:       hex(light: 0xA5C7C7, dark: 0x7DA0A0)
        case .dummy:          .clear
        }
    }

    // Focus: vivid colours in light mode, vivid-and-saturated variants in dark
    // mode. Each hue stays pre-attentively distinct, with enough saturation that
    // sighted users can scan-by-colour without conscious decoding.
    private static func focusColor(for sessionType: SessionType) -> Color {
        switch sessionType {
        case .talk:           hex(light: 0x0066FF, dark: 0x3399FF)
        case .workshop:       hex(light: 0xFF8C00, dark: 0xFF9933)
        case .panel:          hex(light: 0x9000E0, dark: 0xC153F0)
        case .lightningtalks: hex(light: 0xFFD000, dark: 0xFFE033)
        case .teaBreak:       hex(light: 0x607080, dark: 0xA8B5C5)
        case .lunch:          hex(light: 0x00C853, dark: 0x33D97A)
        case .dinner:         hex(light: 0xFF1493, dark: 0xFF66BB)
        case .confdinner:     hex(light: 0xDC143C, dark: 0xFF5577)
        case .social:         hex(light: 0x00CED1, dark: 0x33E0E5)
        case .registration:   hex(light: 0x4169E1, dark: 0x5599FF)
        case .railtrip:       hex(light: 0x00BCD4, dark: 0x33D9E5)
        case .dummy:          .clear
        }
    }

    /// Builds a `Color` that switches between light- and dark-mode variants
    /// based on the current `UITraitCollection.userInterfaceStyle`. Both inputs
    /// are 0xRRGGBB constants.
    private static func hex(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { trait in
            let value = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red:   CGFloat((value >> 16) & 0xFF) / 255.0,
                green: CGFloat((value >> 8)  & 0xFF) / 255.0,
                blue:  CGFloat( value        & 0xFF) / 255.0,
                alpha: 1.0
            )
        })
    }
}

extension EnvironmentValues {
    @Entry var theme: Theme = .default
}
