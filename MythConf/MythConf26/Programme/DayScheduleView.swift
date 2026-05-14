//
//  DayScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

/// A scrollable list of all time slots for a single conference day.
struct DayScheduleView: View {
    let sessions: [Session]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sessions) { session in
                    // VStack wrap disambiguates SwiftUI's ForEach overload
                    // resolution under Xcode 16 SDKs. A multi-child closure
                    // body — and even Group, which has a MapContent
                    // conformance — otherwise resolves to MapContentBuilder.
                    VStack(spacing: 0) {
                        if session.containsTalk {
                            ParallelSessionsRowView(session: session)
                        } else {
                            BreakRowView(session: session)
                        }
                        Divider()
                            .accessibilityHidden(true)
                    }
                }
            }
        }
    }
}
