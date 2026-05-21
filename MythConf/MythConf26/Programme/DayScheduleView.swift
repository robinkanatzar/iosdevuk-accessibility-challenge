//
//  DayScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

/// A scrollable list of all time slots for a single conference day.
struct DayScheduleView: View {
    let sessions: [Session]
    /// Extra bottom padding so the floating countdown banner above the tab
    /// bar doesn't cover the last row.
    var bottomInset: CGFloat = 0
    /// Reports whether the scroll content has reached its bottom edge. Used
    /// by the parent to defer the countdown banner's VoiceOver focus until
    /// the user has finished navigating through every session row.
    var onScrolledToBottomChange: ((Bool) -> Void)? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sessions) { session in
                    if session.containsTalk {
                        ParallelSessionsRowView(session: session)
                    } else {
                        BreakRowView(session: session)
                    }
                    Divider()
                }
            }
            .padding(.bottom, bottomInset)
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            let maxOffset = geometry.contentSize.height - geometry.containerSize.height
            guard maxOffset > 0 else { return true }
            return geometry.contentOffset.y >= maxOffset - 1
        } action: { _, isAtBottom in
            onScrolledToBottomChange?(isAtBottom)
        }
    }
}
