//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI

/// A horizontal row of tappable social/web links for a speaker. Switches to a vertical
/// stack at accessibility text sizes so labels don't overlap.
struct SocialLinksView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let social: [SocialItem]

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())

        layout {
            ForEach(social, id: \.self) { item in
                if let url = URL(string: item.socialLink) {
                    Link(destination: url) {
                        Label(item.socialType.capitalized, systemImage: iconName(for: item.socialType))
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                    }
                    .contentShape(.rect)
                    .accessibilityLabel("\(item.socialType.capitalized) profile")
                    .accessibilityHint("Opens in browser")
                    .accessibilityAddTraits(.isLink)
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
