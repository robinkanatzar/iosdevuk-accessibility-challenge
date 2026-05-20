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

    private struct RenderedSocialLink: Hashable {
        let socialType: String
        let url: URL
    }

    private var renderedLinks: [RenderedSocialLink] {
        social.flatMap { item in
            item.socialLink
                .split(whereSeparator: \.isNewline)
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .compactMap { link in
                    guard let url = URL(string: link) else { return nil }
                    return RenderedSocialLink(
                        socialType: displayType(for: url, fallback: item.socialType),
                        url: url
                    )
                }
        }
    }

    var body: some View {
        HStack {
            ForEach(renderedLinks, id: \.self) { item in
                Button { // a11y-check:disable button-used-as-link
                    announceExternalLinkOpening(item)
                    openURL(item.url)
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

    private func announceExternalLinkOpening(_ item: RenderedSocialLink) {
        let message = "One moment, opening \(item.socialType.capitalized) for \(speakerName)"
        AccessibilityNotification.Announcement(message).post()
    }

    private func displayType(for url: URL, fallback: String) -> String {
        guard let host = url.host()?.lowercased() else {
            return fallback
        }

        if host.contains("github.com") {
            return "github"
        }
        if host.contains("linkedin.com") {
            return "linkedin"
        }
        if host.contains("twitter.com") || host.contains("x.com") {
            return "twitter"
        }
        if host.contains("mastodon") || host == "mas.to" {
            return "mastodon"
        }
        if host.contains("bsky.app") {
            return "bluesky"
        }
        return fallback == "www" ? "website" : fallback
    }

    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "twitter", "x": return "at"
        case "mastodon": return "at.badge.plus"
        case "github": return "chevron.left.forwardslash.chevron.right"
        case "linkedin": return "person.crop.square"
        case "website", "web", "www", "blog": return "globe"
        case "bluesky": return "cloud"
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
