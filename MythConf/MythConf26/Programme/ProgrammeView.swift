import SwiftUI

struct ProgrammeView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var selectedDayIndex = 0

    private var days: [[Session]] { viewModel.confData.sessions }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Conference day", selection: $selectedDayIndex) {
                    ForEach(days.indices, id: \.self) { index in
                        Text(dayLabel(for: days[index]))
                            .tag(index)
                            .accessibilityLabel("Day \(index + 1), \(dayLabel(for: days[index]))")
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if let selectedDay = selectedDay {
                    ProgrammeDaySummaryView(
                        dayIndex: selectedDayIndex,
                        sessions: selectedDay
                    )

                    DayScheduleView(sessions: selectedDay)
                }
            }
            .navigationTitle("MythConf 2026")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectTodayIfConferenceIsRunning()
            }
            .conferenceNavigationDestinations()
        }
    }

    private var selectedDay: [Session]? {
        guard days.indices.contains(selectedDayIndex) else {
            return nil
        }

        return days[selectedDayIndex]
    }

    private func dayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.abbreviated))
    }

    private func selectTodayIfConferenceIsRunning() {
        let confTimeType = viewModel.confData.whereInConf()
        guard confTimeType != .beforeConf, confTimeType != .afterConf else {
            return
        }

        if let todayIndex = days.firstIndex(where: { sessions in
            guard let first = sessions.first else {
                return false
            }

            return Calendar.current.isDateInToday(first.startTime)
        }) {
            selectedDayIndex = todayIndex
        }
    }
}

#Preview {
    ProgrammeView()
        .environment(ViewModel())
}
