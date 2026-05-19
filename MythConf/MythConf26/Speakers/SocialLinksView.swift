//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI

/// A horizontal row of tappable social/web links for a speaker.
struct SocialLinksView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let social: [SocialItem]
    var speakerName: String = ""

    var body: some View {
            layout {
                ForEach(social, id: \.self) { item in
                    if let url = URL(string: item.socialLink) {
                        Link(destination: url) {
                            Label(displayName(for: item.socialType), systemImage: iconName(for: item.socialType))
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                        }
                        // Ensure a minimum 44x44pt tap target (WCAG 2.5.5 / Apple HIG).
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(.rect)
                        .accessibilityLabel(accessibilityLabel(for: item))
                        .accessibilityHint("Opens link in browser")
                        // Voice Control synonyms — users may say any of these to tap.
                        .accessibilityInputLabels([
                            displayName(for: item.socialType),
                            item.socialType,
                            "\(displayName(for: item.socialType)) link"
                        ])
                    }
                }
            }
        }
     
        @ViewBuilder
        private func layout<Content: View>(@ViewBuilder content: () -> Content) -> some View {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) { content() }
            } else {
                HStack { content() }
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
     
        private func displayName(for type: String) -> String {
            // Normalize names — "x" should display as "X", not "X".capitalized weirdness.
            switch type.lowercased() {
            case "x": return "X"
            case "github": return "GitHub"
            case "linkedin": return "LinkedIn"
            default: return type.capitalized
            }
        }
     
        private func accessibilityLabel(for item: SocialItem) -> String {
            let display = displayName(for: item.socialType)
            if speakerName.isEmpty {
                return "\(display) profile"
            }
            return "\(speakerName)'s \(display) profile"
        }
    }
     
