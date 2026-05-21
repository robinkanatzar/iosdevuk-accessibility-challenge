//
//  DayScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

/// A scrollable list of all time slots for a single conference day.
struct DayScheduleView: View {
    let sessions: [Session]

    private var talkSessions: [Session] {
        sessions.filter { $0.containsTalk }
    }

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
        }
        .accessibilityRotor("Sessions") {
            ForEach(talkSessions) { session in
                ForEach(session.contentIDs, id: \.self) { talkID in
                    AccessibilityRotorEntry(talkID.uuidString, id: talkID)
                }
            }
        }
    }
}
