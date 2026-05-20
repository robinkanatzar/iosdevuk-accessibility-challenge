//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI
import Accessibility

/// A horizontal row of tappable social/web links for a speaker.
struct SocialLinksView: View {
    @Environment(\.openURL) private var openURL

    let social: [SocialItem]
    let speakerName: String

    var body: some View {
        HStack {
            ForEach(social, id: \.self) { item in
                if let url = URL(string: item.socialLink) {
                    Button { // a11y-check:disable button-used-as-link
                        announceExternalLinkOpening(item)
                        openURL(url)
                    } label: {
                        Label(item.socialType.capitalized, systemImage: iconName(for: item.socialType))
                            .font(.subheadline)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .contentShape(.rect)
                    .accessibilityLabel("Open \(speakerName) on \(item.socialType.capitalized)")
                    .accessibilityInputLabels([
                        item.socialType.capitalized,
                        "\(speakerName) \(item.socialType.capitalized)"
                    ])
                    .accessibilityHint("Opens an external link")
                }
            }
        }
    }

    private func announceExternalLinkOpening(_ item: SocialItem) {
        let message = "One moment, opening \(item.socialType.capitalized) for \(speakerName)"
        AccessibilityNotification.Announcement(message).post()
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

#Preview {
    SocialLinksView(
        social: [
            SocialItem(socialType: "Twitter", socialLink: "https://twitter.com/apple"),
            SocialItem(socialType: "GitHub", socialLink: "https://github.com/apple"),
            SocialItem(socialType: "LinkedIn", socialLink: "https://linkedin.com")
        ],
        speakerName: "Sample Speaker"
    )
    .padding()
}
