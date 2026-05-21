//
//  MyScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

struct MyScheduleView: View {
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favouriteIds.isEmpty {
                    ContentUnavailableView(
                        "No Favourites Yet",
                        systemImage: "star",
                        description: Text("Tap the star on any session in the Programme to save it here.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(viewModel.favouritesBySession.indices, id: \.self) { dayIndex in
                                let daySessions = viewModel.favouritesBySession[dayIndex]
                                if daySessions.first?.sessionType != .dummy {
                                    Section {
                                        ForEach(daySessions) { session in
                                            ParallelSessionsRowView(session: session)
                                            Divider()
                                        }
                                    } header: {
                                        Text(dayHeader(for: daySessions))
                                            .font(.headline)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(.regularMaterial)
                                            .accessibilityAddTraits(.isHeader)
                                            .accessibilityLabel(dayHeaderAccessible(for: daySessions))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Schedule")
            .conferenceNavigationDestinations()
        }
    }

    private func dayHeader(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    /// Spoken-friendly day header, e.g. "Thursday, 2nd September". VoiceOver expands "2nd"
    /// to "second", whereas the plain digit "2" reads as "two".
    private func dayHeaderAccessible(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        let weekday = first.startTime.formatted(.dateTime.weekday(.wide))
        let month = first.startTime.formatted(.dateTime.month(.wide))
        let day = Calendar.current.component(.day, from: first.startTime)
        let ordinalFormatter = NumberFormatter()
        ordinalFormatter.numberStyle = .ordinal
        let dayOrdinal = ordinalFormatter.string(from: NSNumber(value: day)) ?? "\(day)"
        return "\(weekday), \(dayOrdinal) \(month)"
    }
}

#Preview {
    MyScheduleView()
        .environment(ViewModel())
}
