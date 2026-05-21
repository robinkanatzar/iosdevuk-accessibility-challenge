//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI

/// A horizontal row of tappable social/web links for a speaker.
struct SocialLinksView: View {
    let social: [SocialItem]

    var body: some View {
        HStack {
            ForEach(social, id: \.self) { item in
                if let url = URL(string: item.socialLink) {
                    Link(destination: url) {
                        Label(item.socialType.capitalized, systemImage: iconName(for: item.socialType))
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                    }
                    .contentShape(.rect)
                    .accessibilityLabel("Open \(item.socialType.capitalized) profile")
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
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

// MARK: - Preview

#Preview {
    SocialLinksView(social: [
        SocialItem(socialType: "twitter", socialLink: "https://twitter.com/example"),
        SocialItem(socialType: "github", socialLink: "https://github.com/example"),
        SocialItem(socialType: "website", socialLink: "https://example.com")
    ])
}
