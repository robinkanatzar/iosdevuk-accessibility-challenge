//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI

/// A grid of tappable social/web links for a speaker.
///
/// The bundled conference data packs multiple URLs into a single
/// `SocialItem.socialLink` separated by newlines (e.g.
/// `"https://example.com\nhttps://github.com/foo\n"`). `URL(string:)` is
/// lenient enough to accept the whole string, but the resulting URL has
/// embedded newlines and the system fails to open it — leaving Voice
/// Control commands like "Open GitHub" producing no result. This view
/// splits each `socialLink` into its constituent URLs and renders one
/// `Link` per chunk, each with a host-derived label so VoiceOver and
/// Voice Control can address them individually.
///
/// Each link is rendered as an icon-only target with a 50×50pt frame —
/// above the HIG 44pt minimum and small enough that a row of five fits
/// on iPhone portrait. The friendly host-derived name ("GitHub",
/// "Website", etc.) is exposed via `.accessibilityLabel` so VoiceOver
/// and Voice Control announce and target each profile independently.
///
/// Glyph resolution is two-tier: each `ResolvedLink` carries an
/// `assetName` that points at an Asset Catalog entry (e.g.
/// `"social-github"`). When the asset exists, the official brand glyph
/// is rendered as a template image so it picks up the foreground style.
/// When the asset is missing, the SF Symbol fallback in `symbolName` is
/// rendered instead, so the view works without further code changes
/// whether or not the brand-icon assets have been added.
struct SocialLinksView: View {
    let social: [SocialItem]

    private let columns = [GridItem(.adaptive(minimum: 50), spacing: 0)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
            ForEach(Array(expandedLinks.enumerated()), id: \.offset) { _, link in
                Link(destination: link.url) {
                    icon(for: link)
                        .frame(width: 50, height: 50)
                        .contentShape(.rect)
                }
                .accessibilityLabel(link.displayLabel)
                .accessibilityHint("Opens in browser")
                .accessibilityInputLabels([link.displayLabel, "\(link.displayLabel) profile"])
            }
        }
    }

    @ViewBuilder
    private func icon(for link: ResolvedLink) -> some View {
        if let assetName = link.assetName, UIImage(named: assetName) != nil {
            Image(assetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.primary)
                .padding(8)
        } else {
            Image(systemName: link.symbolName)
                .font(.title3)
                .foregroundStyle(.primary)
        }
    }

    private var expandedLinks: [ResolvedLink] {
        social.flatMap { item -> [ResolvedLink] in
            item.socialLink
                .split(separator: "\n", omittingEmptySubsequences: true)
                .map { String($0).trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .compactMap { chunk -> ResolvedLink? in
                    guard let url = URL(string: chunk), url.scheme != nil else { return nil }
                    return ResolvedLink(
                        url: url,
                        displayLabel: Self.displayLabel(for: url, fallbackType: item.socialType),
                        symbolName: Self.symbolName(for: url, fallbackType: item.socialType),
                        assetName: Self.assetName(for: url, fallbackType: item.socialType)
                    )
                }
        }
    }

    fileprivate struct ResolvedLink {
        let url: URL
        let displayLabel: String
        let symbolName: String
        let assetName: String?
    }

    /// Picks a friendly label from a URL's host. Falls back to the
    /// `SocialItem.socialType` when the host doesn't match a known
    /// network, with the generic web/blog/`www` bucket reading as
    /// "Website" rather than the raw token so VoiceOver doesn't speak
    /// "Www" character-by-character.
    static func displayLabel(for url: URL, fallbackType: String) -> String {
        let host = (url.host ?? "").lowercased()
        if host.contains("github") { return "GitHub" }
        if host.contains("linkedin") { return "LinkedIn" }
        if host.contains("mastodon") || host.hasSuffix("mas.to") || host.hasPrefix("mstdn.") || host.hasPrefix("mas.") { return "Mastodon" }
        if host.contains("bsky.app") { return "Bluesky" }
        if host.contains("twitter.com") || host == "x.com" || host.hasSuffix(".x.com") { return "Twitter / X" }

        let lower = fallbackType.lowercased()
        if ["www", "web", "website", "blog"].contains(lower) { return "Website" }
        return fallbackType.capitalized
    }

    /// Picks an SF Symbol from a URL's host. Used as the fallback glyph
    /// when an Asset Catalog brand icon is not present.
    static func symbolName(for url: URL, fallbackType: String) -> String {
        let host = (url.host ?? "").lowercased()
        if host.contains("github") { return "chevron.left.forwardslash.chevron.right" }
        if host.contains("linkedin") { return "person.crop.square" }
        if host.contains("mastodon") || host.hasSuffix("mas.to") || host.hasPrefix("mstdn.") || host.hasPrefix("mas.") { return "at.badge.plus" }
        if host.contains("bsky.app") { return "cloud" }
        if host.contains("twitter.com") || host == "x.com" || host.hasSuffix(".x.com") { return "at" }
        return Self.fallbackSymbolName(for: fallbackType)
    }

    /// Maps a URL's host to an Asset Catalog name. The corresponding
    /// asset should be a vector PDF template image (single colour, alpha
    /// channel) so it inherits `foregroundStyle(.primary)`. Drop the
    /// official brand SVGs from simpleicons.org (or each brand's own
    /// guidelines) into `Assets.xcassets` with these names and they will
    /// be picked up automatically. Returns `nil` for unknown buckets so
    /// the SF Symbol fallback is used.
    static func assetName(for url: URL, fallbackType: String) -> String? {
        let host = (url.host ?? "").lowercased()
        if host.contains("github") { return "social-github" }
        if host.contains("linkedin") { return "social-linkedin" }
        if host.contains("mastodon") || host.hasSuffix("mas.to") || host.hasPrefix("mstdn.") || host.hasPrefix("mas.") { return "social-mastodon" }
        if host.contains("bsky.app") { return "social-bluesky" }
        if host.contains("twitter.com") || host == "x.com" || host.hasSuffix(".x.com") { return "social-twitter-x" }

        let lower = fallbackType.lowercased()
        if ["www", "web", "website", "blog"].contains(lower) { return "social-website" }
        return nil
    }

    private static func fallbackSymbolName(for type: String) -> String {
        switch type.lowercased() {
        case "twitter", "x": return "at"
        case "mastodon": return "at.badge.plus"
        case "github": return "chevron.left.forwardslash.chevron.right"
        case "linkedin": return "person.crop.square"
        case "website", "web", "blog", "www": return "globe"
        default: return "link"
        }
    }
}
