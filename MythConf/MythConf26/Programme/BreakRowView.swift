//
//  BreakRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
struct BreakRowView: View {
    @Environment(ViewModel.self) private var viewModel
    let session: Session
    /// SF Symbols ship with non-uniform glyph widths (e.g. `cup.and.saucer.fill`
    /// vs `tram.fill`), so a `.font(...)` modifier alone produces visibly
    /// different icon sizes per break type. Locking each icon into a square
    /// frame keeps them visually consistent and still scales with Dynamic Type.
    @ScaledMetric private var iconSize: CGFloat = 22

    var body: some View {
        AStack(vAlignment: .leading) {
            TimeColumnView(
                startTime: session.startTimeText,
                endTime: session.endTimeText,
                actsAsHeader: false
            )

            HStack(alignment: .center, spacing: 12) {
                if let iconName = session.sessionType.iconName {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundStyle(session.sessionType.color)
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey(session.sessionType.displayName))
                        .italic()
                        .foregroundStyle(.primary)
                    if let talkID = session.contentIDs.first {
                        Text(viewModel.locationNameFrom(talkID: talkID))
                            .font(.caption)
                            .secondaryTextStyle()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(session.sessionType.color.opacity(0.12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        // Break rows are not tappable. VoiceOver still reads them, but exclude
        // them from Voice Control / Switch Control / Full Keyboard targets.
        .accessibilityRespondsToUserInteraction(false)
    }

    private var accessibilityDescription: String {
        let start = session.startTimeText
        let end = session.endTimeText
        let typeName = String(localized: String.LocalizationValue(session.sessionType.displayName))
        if let talkID = session.contentIDs.first {
            let location = viewModel.locationNameFrom(talkID: talkID)
            return String(localized: "Break Time from \(start) to \(end), \(typeName) at \(location)")
        }
        return String(localized: "Break Time from \(start) to \(end), \(typeName)")
    }
}
