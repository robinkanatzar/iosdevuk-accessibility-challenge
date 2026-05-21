//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI

/// A horizontal row of tappable social/web links for a speaker.
struct SocialLinksView: View {
    @Environment(ViewModel.self) private var viewModel
    let social: [SocialItem]

    var body: some View {
        HStack {
            ForEach(social, id: \.self) { item in
                if let url = URL(string: item.socialLink) {
                    Link(destination: url) {
                        Label(item.socialType.capitalized, systemImage: iconName(for: item.socialType))
                            .appFont(.subheadline, useLexend: viewModel.useLexendFont)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                    }
                    .contentShape(.rect)
                    .accessibilityLabel("\(item.socialType.capitalized), opens in browser")
                }
            }
        }
    }

    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "twitter", "x": return "at"
        case "mastodon": return "at.badge.plus"
        case "github": return "chevron.left.forwardslash.chevron.right"
        case "linkedin": return "person.crop.square"
        case "website", "web", "blog": return "globe"
        default: return "link"
        }
    }
}
