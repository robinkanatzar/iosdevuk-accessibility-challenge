//
//  ProgrammeView.swift
//  IOSDevuk26
//

import SwiftUI

struct ProgrammeView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedDayIndex = 0
    
    private var days: [[Session]] { viewModel.confData.sessions }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                dayPicker
                
                if !days.isEmpty {
                    DayScheduleView(sessions: days[selectedDayIndex])
                        .animation(reduceMotion ? nil : .default, value: selectedDayIndex)
                        .onChange(of: selectedDayIndex) { _, newIndex in
                            let label = fullDayLabel(for: days[newIndex])
                            UIAccessibility.post(notification: .pageScrolled,
                                                 argument: "Showing \(label)")
                        }
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
    
    @ViewBuilder
    private var dayPicker: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Picker("Conference day", selection: $selectedDayIndex) {
                ForEach(days.indices, id: \.self) { index in
                    Text(fullDayLabel(for: days[index]))
                        .tag(index)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .accessibilityLabel("Conference day")
            .accessibilityHint("Double tap to choose a day")
        } else {
            Picker("Conference day", selection: $selectedDayIndex) {
                ForEach(days.indices, id: \.self) { index in
                    Text(dayLabel(for: days[index]))
                        .tag(index)
                        .accessibilityLabel("Day \(index + 1), \(fullDayLabel(for: days[index]))")
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    private func dayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.abbreviated))
    }
    
    
    private func fullDayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}

#Preview {
    ProgrammeView()
        .environment(ViewModel())
}

