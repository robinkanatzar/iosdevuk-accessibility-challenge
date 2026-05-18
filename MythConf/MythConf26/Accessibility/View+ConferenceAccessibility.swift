import SwiftUI

extension View {
    /// Applies consistent accessibility semantics for tappable conference controls.
    func conferenceButtonAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        inputLabels: [String] = []
    ) -> some View {
        modifier(
            ConferenceActionAccessibilityModifier(
                role: .button,
                label: label,
                hint: hint,
                value: value,
                inputLabels: inputLabels
            )
        )
    }

    /// Applies consistent accessibility semantics for links that open speaker,
    /// location, web, or session detail destinations.
    func conferenceLinkAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        inputLabels: [String] = []
    ) -> some View {
        modifier(
            ConferenceActionAccessibilityModifier(
                role: .link,
                label: label,
                hint: hint,
                value: value,
                inputLabels: inputLabels
            )
        )
    }

    /// Marks a view as a navigable heading for VoiceOver rotor users.
    func conferenceHeaderAccessibility(label: String? = nil) -> some View {
        modifier(ConferenceHeaderAccessibilityModifier(label: label))
    }

    /// Groups visual children into one concise VoiceOver element.
    func conferenceGroupAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil
    ) -> some View {
        modifier(
            ConferenceGroupAccessibilityModifier(
                label: label,
                hint: hint,
                value: value
            )
        )
    }

    /// Hides purely decorative imagery from assistive technologies.
    func conferenceDecorativeAccessibility() -> some View {
        accessibilityHidden(true)
    }
}

private struct ConferenceActionAccessibilityModifier: ViewModifier {
    let role: ConferenceAccessibilityRole
    let label: String
    let hint: String?
    let value: String?
    let inputLabels: [String]

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityRemoveTraits(ConferenceAccessibilityRole.mutuallyExclusiveTraits)
            .accessibilityAddTraits(role.trait)
            .accessibilityInputLabels(inputLabels)
    }
}

private struct ConferenceHeaderAccessibilityModifier: ViewModifier {
    let label: String?

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label ?? "")
            .accessibilityAddTraits(.isHeader)
    }
}

private struct ConferenceGroupAccessibilityModifier: ViewModifier {
    let label: String
    let hint: String?
    let value: String?

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
    }
}
