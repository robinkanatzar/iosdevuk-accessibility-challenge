//
//  AppFont.swift
//  IOSDevuk26
//

import SwiftUI

enum AppFontStyle {
    case body
    case title2
    case headline
    case subheadline
    case caption

    var systemFont: Font {
        switch self {
        case .body: .body
        case .title2: .title2
        case .headline: .headline
        case .subheadline: .subheadline
        case .caption: .caption
        }
    }

    var textStyle: Font.TextStyle {
        switch self {
        case .body: .body
        case .title2: .title2
        case .headline: .headline
        case .subheadline: .subheadline
        case .caption: .caption
        }
    }

    var size: CGFloat {
        switch self {
        case .body: 17
        case .title2: 22
        case .headline: 17
        case .subheadline: 15
        case .caption: 12
        }
    }
}

extension View {
    func appFont(_ style: AppFontStyle, useLexend: Bool) -> some View {
        font(useLexend ? .custom("Lexend", size: style.size, relativeTo: style.textStyle) : style.systemFont)
    }
}
