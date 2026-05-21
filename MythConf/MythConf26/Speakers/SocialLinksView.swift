//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI

/// A horizontal row of tappable social/web links for a speaker. Each
/// `SocialItem.socialLink` may contain multiple newline-separated URLs, which
/// this view splits into individual links and renders with a brand-aware
/// icon (real logo for GitHub / LinkedIn / X, SF Symbol otherwise).
struct SocialLinksView: View {
    let social: [SocialItem]

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ScaledMetric private var iconSize: CGFloat = 18

    private var isLandscape: Bool { verticalSizeClass == .compact }

    var body: some View {
        Group {
            if isLandscape {
                HFlow(spacing: 8, lineSpacing: 0) {
                    linkButtons
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    linkButtons
                }
            }
        }
    }

    @ViewBuilder
    private var linkButtons: some View {
        ForEach(parsedLinks) { link in
            Link(destination: link.url) {
                HStack(spacing: 6) {
                    link.iconView(size: iconSize)
                    Text(link.displayName)
                        .lineLimit(1)
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
            .contentShape(.rect)
            .accessibilityLabel(link.accessibilityLabel)
            .accessibilityHint(Text("Opens in browser", comment: "VoiceOver hint for social links that leave the app and open the URL in Safari or the corresponding native app."))
            .accessibilityInputLabels(link.inputLabels)
        }
    }

    private var parsedLinks: [ParsedSocialLink] {
        social.flatMap { item -> [ParsedSocialLink] in
            item.socialLink
                .split(whereSeparator: \.isNewline)
                .compactMap { line in
                    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }
                    return ParsedSocialLink(url: url)
                }
        }
    }
}

private struct ParsedSocialLink: Identifiable {
    let url: URL

    var id: String { url.absoluteString }

    private var brand: SocialBrand? { SocialBrand(url: url) }

    @ViewBuilder
    func iconView(size: CGFloat) -> some View {
        Group {
            if let brand {
                Image(brand.assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "link")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    var displayName: String {
        if let brand, let account = brand.account(from: url) {
            return account
        }
        if let brand { return brand.displayName }
        return url.host.map(strippingWWW) ?? url.absoluteString
    }

    var inputLabels: [String] {
        if let brand {
            var labels = brand.inputLabels
            if let account = brand.account(from: url) {
                labels.insert(account, at: 0)
            }
            return labels
        }
        guard let host = url.host.map(strippingWWW) else { return ["Link"] }
        return [host, "Link", "Website"]
    }

    /// VoiceOver label like "GitHub account" or "Website, davidkowalski.dev"
    /// so the reader announces what kind of link this is rather than just the
    /// account handle.
    var accessibilityLabel: String {
        if let brand {
            switch brand {
            case .gitHub: return String(localized: "GitHub account")
            case .linkedIn: return String(localized: "LinkedIn account")
            case .x: return String(localized: "X account")
            case .mastodon: return String(localized: "Mastodon account")
            case .blueSky: return String(localized: "Bluesky account")
            case .youTube: return String(localized: "YouTube account")
            }
        }
        let host = url.host.map(strippingWWW) ?? url.absoluteString
        return String(localized: "Website, \(host)")
    }

    private func strippingWWW(_ host: String) -> String {
        host.lowercased().hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}

/// A simple horizontal-flow layout: places subviews left-to-right and wraps to
/// the next line when the next subview would overflow the available width.
/// Each subview is placed at its natural size (no internal text wrapping).
private struct HFlow: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let arrangement = arrange(subviews: subviews, in: maxWidth)
        return arrangement.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arrangement = arrange(subviews: subviews, in: bounds.width)
        for (index, origin) in arrangement.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(subviews: Subviews, in maxWidth: CGFloat) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var currentLineHeight: CGFloat = 0
        var widestLine: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                widestLine = max(widestLine, x - spacing)
                x = 0
                y += currentLineHeight + lineSpacing
                currentLineHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            currentLineHeight = max(currentLineHeight, size.height)
        }

        widestLine = max(widestLine, x - spacing)
        return (positions, CGSize(width: widestLine, height: y + currentLineHeight))
    }
}

private enum SocialBrand {
    case gitHub, linkedIn, x, mastodon, blueSky, youTube

    init?(url: URL) {
        guard let host = url.host?.lowercased() else { return nil }
        switch host {
        case "github.com", "www.github.com":
            self = .gitHub
        case "linkedin.com", "www.linkedin.com":
            self = .linkedIn
        case "x.com", "www.x.com", "twitter.com", "www.twitter.com":
            self = .x
        case "bsky.app", "www.bsky.app", "bsky.social", "www.bsky.social":
            self = .blueSky
        case "youtube.com", "www.youtube.com", "m.youtube.com", "youtu.be":
            self = .youTube
        default:
            // Mastodon instances are federated across many hosts. Identify by
            // the `/@username` path convention or by hosts starting with
            // "mastodon." to cover most cases.
            if url.path.hasPrefix("/@") || host.hasPrefix("mastodon.") {
                self = .mastodon
            } else {
                return nil
            }
        }
    }

    var assetName: String {
        switch self {
        case .gitHub: "GitHub"
        case .linkedIn: "LinkedIn"
        case .x: "X"
        case .mastodon: "Mastodon"
        case .blueSky: "BlueSky"
        case .youTube: "YouTube"
        }
    }

    var displayName: String {
        switch self {
        case .gitHub: "GitHub"
        case .linkedIn: "LinkedIn"
        case .x: "X"
        case .mastodon: "Mastodon"
        case .blueSky: "Bluesky"
        case .youTube: "YouTube"
        }
    }

    var inputLabels: [String] {
        switch self {
        case .gitHub: ["GitHub", "Repository", "Code", "Source"]
        case .linkedIn: ["LinkedIn", "Profile"]
        case .x: ["X", "Twitter", "Tweet"]
        case .mastodon: ["Mastodon", "Toot"]
        case .blueSky: ["Bluesky", "BlueSky", "Bsky", "Skeet"]
        case .youTube: ["YouTube", "Video", "Watch", "Channel"]
        }
    }

    /// Extracts the user-facing account / handle from a brand URL using each
    /// service's path convention. Returns `nil` for shapes we do not
    /// recognise (e.g. a GitHub URL pointing at an issue page).
    func account(from url: URL) -> String? {
        let parts = url.path.split(separator: "/").map(String.init)
        switch self {
        case .gitHub:
            // /{username} or /{username}/{repo}
            return parts.first
        case .linkedIn:
            // /in/{handle} or /company/{handle}
            if parts.count >= 2, parts[0] == "in" || parts[0] == "company" {
                return parts[1]
            }
            return nil
        case .x:
            // /{handle}
            return parts.first
        case .mastodon:
            // /@{handle}
            return parts.first?.hasPrefix("@") == true ? parts.first : nil
        case .blueSky:
            // /profile/{handle}
            if parts.count >= 2, parts[0] == "profile" {
                return parts[1]
            }
            return nil
        case .youTube:
            // /@{channel}, /c/{channel}, or /channel/{id}
            if let first = parts.first {
                if first.hasPrefix("@") { return first }
                if (first == "c" || first == "channel" || first == "user"), parts.count >= 2 {
                    return parts[1]
                }
            }
            return nil
        }
    }
}
