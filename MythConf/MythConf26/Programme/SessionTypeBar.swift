//
//  SessionTypeBar.swift
//  IOSDevuk26
//

import SwiftUI

/// A coloured strip across the top of a card, ornamented with a row of
/// repeated session-type SF Symbols. Communicates the session type via
/// colour + icon pattern; VoiceOver hears it as the type's display name.
struct SessionTypeBar: View {
    @Environment(\.theme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let sessionType: SessionType
    var isAccessibilitySize: Bool {
        dynamicTypeSize >= .accessibility1
    }

    var body: some View {
        theme.color(for: sessionType)
            .frame(height: isAccessibilitySize ? 32 : 24)
            .overlay {
                if !sessionType.iconName.isEmpty {
                    HStack(spacing: 0) {
                        Image(systemName: sessionType.iconName)
                            .padding(16)
                        Spacer()
                    }
                    .font(.title)
                    .foregroundStyle(
                        .white.opacity(0.8)
                    )
                }
            }
            .clipped()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(sessionType.displayName)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 8) {
            SessionTypeBar(sessionType: .talk)
            SessionTypeBar(sessionType: .workshop)
            SessionTypeBar(sessionType: .panel)
            SessionTypeBar(sessionType: .lightningtalks)
            SessionTypeBar(sessionType: .teaBreak)
            SessionTypeBar(sessionType: .lunch)
            SessionTypeBar(sessionType: .dinner)
            SessionTypeBar(sessionType: .confdinner)
            SessionTypeBar(sessionType: .social)
            SessionTypeBar(sessionType: .registration)
            SessionTypeBar(sessionType: .railtrip)
        }
        .padding()
    }
}
