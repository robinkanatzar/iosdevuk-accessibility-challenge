import SwiftUI

/// A scrollable list of all time slots for a single conference day.
struct DayScheduleView: View {
    let sessions: [Session]

    private var accessibilityLabel: String {
        let timeSlotCount = sessions.count
        let talkCount = sessions.reduce(0) { partialResult, session in
            session.containsTalk ? partialResult + session.contentIDs.count : partialResult
        }

        return "\(timeSlotCount) time slots, \(talkCount) talks"
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
        .accessibilityLabel(accessibilityLabel)
    }
}
