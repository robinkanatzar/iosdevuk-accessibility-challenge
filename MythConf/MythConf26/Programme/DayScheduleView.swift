//
//  DayScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

/// A scrollable list of all time slots for a single conference day.
struct DayScheduleView: View {
    let sessions: [Session]
    var rotorNamespace: Namespace.ID? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sessions) { session in
                    if session.containsTalk {
                        ParallelSessionsRowView(session: session, rotorNamespace: rotorNamespace)
                    } else {
                        BreakRowView(session: session)
                    }
                    Divider()
                }
            }
        }
    }
}
