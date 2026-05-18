import SwiftUI

/// A horizontal row of tappable social/web links for a speaker.
struct SocialLinksView: View {
    let social: [SocialItem]

    var body: some View {
        HStack {
            ForEach(social, id: \.self) { item in
                if let url = URL(string: item.socialLink) {
                    Link(destination: url) {
                        Label(displayName(for: item.socialType), systemImage: iconName(for: item.socialType))
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 6)
                            .frame(minHeight: 44)
                    }
                    .contentShape(.rect)
                    .conferenceLinkAccessibility(
                        label: "\(displayName(for: item.socialType)) profile",
                        hint: "Opens \(displayName(for: item.socialType)) in a browser.",
                        inputLabels: [
                            displayName(for: item.socialType),
                            "\(displayName(for: item.socialType)) profile",
                            "Open \(displayName(for: item.socialType))"
                        ]
                    )
                }
            }
        }
    }

    private func displayName(for type: String) -> String {
        switch type.lowercased() {
        case "twitter", "x": "X"
        case "mastodon": "Mastodon"
        case "github": "GitHub"
        case "linkedin": "LinkedIn"
        case "website", "web", "blog": "Website"
        default: type.capitalized
        }
    }

    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "twitter", "x": "at"
        case "mastodon": "at.badge.plus"
        case "github": "chevron.left.forwardslash.chevron.right"
        case "linkedin": "person.crop.square"
        case "website", "web", "blog": "globe"
        default: "link"
        }
    }
}
