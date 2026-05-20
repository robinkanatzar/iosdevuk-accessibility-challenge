//
//  DayScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

/// A scrollable list of all time slots for a single conference day.
struct DayScheduleView: View {
    @Environment(ViewModel.self) private var viewModel
    @Namespace private var scheduleRotorNamespace

    let sessions: [Session]

    var body: some View {
        ScrollView {
                ForEach(sessions) { session in
                    if session.containsTalk {
                        ParallelSessionsRowView(
                            session: session,
                            daySessions: sessions,
                            rotorNamespace: scheduleRotorNamespace
                        )
                        .padding(.vertical, 4.0)
                    } else {
                        BreakRowView(
                            session: session,
                            daySessions: sessions,
                            rotorNamespace: scheduleRotorNamespace
                        )
                        .padding(.vertical, 4.0)
                    }
                    Divider()
            }
        }
        .accessibilityIdentifier("programme.schedule")
        .accessibilityElement(children: .contain)
        .scheduleAccessibilityRotors(entries: scheduleRotorEntries, namespace: scheduleRotorNamespace)
    }

    private var scheduleRotorEntries: [ScheduleRotorCategory: [ScheduleRotorEntry]] {
        [
            .liveSessions: ScheduleRotorEntries.liveEntries(in: sessions, viewModel: viewModel),
            .upcomingSessions: ScheduleRotorEntries.upcomingEntries(in: sessions, viewModel: viewModel),
            .favouritedSessions: ScheduleRotorEntries.favouritedEntries(in: sessions, viewModel: viewModel),
            .breaks: ScheduleRotorEntries.breakEntries(in: sessions, now: viewModel.currentDate)
        ]
    }
}

#Preview {
    let viewModel = ViewModel()
    DayScheduleView(sessions: viewModel.confData.sessions[1])
        .environment(viewModel)
}
