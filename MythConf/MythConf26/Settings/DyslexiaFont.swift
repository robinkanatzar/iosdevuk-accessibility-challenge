//
//  DyslexiaFont.swift
//  IOSDevuk26
//

import FontKit
import SwiftUI

enum DyslexiaFont {
    static var regular: CustomFont {
        CustomFont.openDyslexicFonts.first { $0.name.localizedCaseInsensitiveContains("regular") }
            ?? CustomFont.openDyslexicFonts[0]
    }

    static var bold: CustomFont {
        CustomFont.openDyslexicFonts.first { $0.name.localizedCaseInsensitiveContains("bold") }
            ?? regular
    }
}

private struct DyslexiaReadingFontModifier: ViewModifier {
    @Environment(\.appSettings) private var appSettings
    let textStyle: Font.TextStyle
    let size: CGFloat
    let weight: Font.Weight?

    func body(content: Content) -> some View {
        if appSettings.usesOpenDyslexicReadingFont {
            content.font(.relative(customFont, size: size, relativeTo: textStyle))
        } else {
            content.font(systemFont)
        }
    }

    private var customFont: CustomFont {
        switch weight {
        case .bold, .heavy, .black, .semibold:
            DyslexiaFont.bold
        default:
            DyslexiaFont.regular
        }
    }

    private var systemFont: Font {
        let baseFont = textStyle.systemFont
        guard let weight else { return baseFont }
        return baseFont.weight(weight)
    }
}

extension View {
    func dyslexiaReadingFont(
        _ textStyle: Font.TextStyle,
        size: CGFloat,
        weight: Font.Weight? = nil
    ) -> some View {
        modifier(DyslexiaReadingFontModifier(textStyle: textStyle, size: size, weight: weight))
    }
}

private extension Font.TextStyle {
    var systemFont: Font {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption
        case .caption2:
            return .caption2
        @unknown default:
            return .body
        }
    }
}
