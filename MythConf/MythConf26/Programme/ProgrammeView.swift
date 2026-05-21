//
//  ProgrammeView.swift
//  IOSDevuk26
//

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
                .sensoryFeedback(trigger: selectedDayIndex) { _, _ in
                    viewModel.hapticFeedbackEnabled ? .selection : nil
                }

                if !days.isEmpty {
                    DayScheduleView(sessions: days[selectedDayIndex])
                }
            }
            .navigationTitle("MythConf 2026")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let confTimeType = viewModel.confData.whereInConf()
                guard confTimeType != .beforeConf, confTimeType != .afterConf else { return }
                if let todayIndex = days.firstIndex(where: { sessions in
                    guard let first = sessions.first else { return false }
                    return Calendar.current.isDateInToday(first.startTime)
                }) {
                    selectedDayIndex = todayIndex
                }
            }
            .conferenceNavigationDestinations()
        }
    }

    private func dayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.abbreviated))
    }
}

#Preview {
    ProgrammeView()
        .environment(ViewModel())
}
