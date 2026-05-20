//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI
import Accessibility

/// A responsive collection of tappable social/web links for a speaker.
struct SocialLinksView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .center, spacing: 8) {
                socialLinkButtons
            }
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    socialLinkButtons
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder
    private var socialLinkButtons: some View {
        ForEach(renderedLinks, id: \.self) { item in
            // SwiftUI limitation have to use Button rather than Link
            Button { // a11y-check:disable button-used-as-link
                announceExternalLinkOpening(item)
                openURL(item.url)
            } label: {
                socialLinkLabel(for: item)
            }
            .buttonStyle(.plain)
            .padding(showButtonShapes ? 8 : 0)
            .background(
                Capsule()
                    .fill(showButtonShapes ? Color(.secondarySystemBackground) : .clear)
            )
            .overlay {
                Capsule()
                    .stroke(showButtonShapes ? Color(.separator) : .clear, lineWidth: 1)
            }
            .contentShape(.rect)
            .accessibilityLabel(accessibilityLabel(for: item))
            .accessibilityInputLabels([
                displayName(for: item.socialType),
                "\(speakerName) \(displayName(for: item.socialType))"
            ])
            .accessibilityHint("Opens an external link")
        }
    }

    @ViewBuilder
    private func socialLinkLabel(for item: RenderedSocialLink) -> some View {
        Label {
            Text(displayName(for: item.socialType))
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        } icon: {
            socialIcon(for: item.socialType)
        }
    }

    @ViewBuilder
    private func socialIcon(for type: String) -> some View {
        if let symbolName = assetSymbolName(for: type) {
            Image(decorative: symbolName)
                .renderingMode(.template)
                .symbolRenderingMode(.monochrome)
        } else {
            Image(systemName: fallbackIconName(for: type))
                .accessibilityHidden(true)
        }
    }

    private func announceExternalLinkOpening(_ item: RenderedSocialLink) {
        let message = "One moment, opening \(displayName(for: item.socialType)) for \(speakerName)"
        AccessibilityNotification.Announcement(message).post()
    }

    private func accessibilityLabel(for item: RenderedSocialLink) -> String {
        switch item.socialType.lowercased() {
        case "website", "web", "www":
            return "\(possessiveSpeakerName) website"
        case "blog":
            return "\(possessiveSpeakerName) blog"
        default:
            return "\(displayName(for: item.socialType))"
        }
    }

    private var possessiveSpeakerName: String {
        if speakerName.lowercased().hasSuffix("s") {
            return "\(speakerName)'"
        }
        return "\(speakerName)'s"
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

    private func displayName(for type: String) -> String {
        switch type.lowercased() {
        case "github": return "GitHub"
        case "linkedin": return "LinkedIn"
        case "twitter": return "Twitter"
        case "x": return "X"
        case "mastodon": return "Mastodon"
        case "bluesky": return "Bluesky"
        case "website", "web", "www": return "Website"
        case "blog": return "Blog"
        default: return type.capitalized
        }
    }

    private func assetSymbolName(for type: String) -> String? {
        switch type.lowercased() {
        case "twitter", "x": return "x"
        case "mastodon": return "mastodon"
        case "github": return "github"
        case "linkedin": return "linkedin"
        case "bluesky": return "bluesky"
        default: return nil
        }
    }

    private func fallbackIconName(for type: String) -> String {
        switch type.lowercased() {
        case "website", "web", "www", "blog": return "globe"
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
