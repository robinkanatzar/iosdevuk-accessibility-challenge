//
//  LanguageToggleButton.swift
//  IOSDevuk26
//

import SwiftUI

/// A small toolbar button that flips the in-app language between English and
/// the device's system language. Only shown when the system language is not
/// already English, since English-system users have nothing to toggle to.
struct LanguageToggleButton: View {
    @AppStorage("languageOverride") private var languageOverride: String = ""

    private var systemLanguage: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    /// `true` while the app should display English (either by override or
    /// because the system itself is English).
    private var isShowingEnglish: Bool {
        if languageOverride == "en" { return true }
        if languageOverride.isEmpty { return systemLanguage == "en" }
        return false
    }

    var body: some View {
        if systemLanguage != "en" {
            Button(action: toggle) {
                Text(isShowingEnglish ? "あ" : "EN")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: .capsule)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(.rect)
            }
            .accessibilityLabel(isShowingEnglish ? "日本語表示に戻す" : "Switch to English")
            .accessibilityInputLabels(
                isShowingEnglish
                    ? ["Japanese", "日本語", "Switch language", "Toggle language"]
                    : ["English", "EN", "Switch language", "Toggle language"]
            )
        }
    }

    private func toggle() {
        languageOverride = isShowingEnglish ? "" : "en"
    }
}

/// Toolbar modifier that installs the language toggle in the trailing slot of
/// a NavigationStack's nav bar.
private struct LanguageToggleToolbar: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LanguageToggleButton()
            }
        }
    }
}

extension View {
    func languageToggleToolbar() -> some View {
        modifier(LanguageToggleToolbar())
    }
}
