//
//  ProgrammeView.swift
//  IOSDevuk26
//

import SwiftUI

struct ProgrammeView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var selectedDayIndex = 0
    @State private var showingSettings = false

    private var days: [[Session]] { viewModel.confData.sessions }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Conference day", selection: $selectedDayIndex) {
                    ForEach(days.indices, id: \.self) { index in
                        Text(dayLabel(for: days[index]))
                            .tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .accessibilityLabel("Conference day")
                .accessibilityValue(currentDayAccessibilityValue)

                if !days.isEmpty {
                    DayScheduleView(sessions: days[selectedDayIndex])
                }
            }
            .navigationTitle("MythConf 2026")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "paintbrush")
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.primary)
                            .font(.title3)
                    }
                    .tint(.primary)
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Opens colour theme settings")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
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

    private var currentDayAccessibilityValue: String {
        guard days.indices.contains(selectedDayIndex) else { return "" }
        let day = days[selectedDayIndex]
        let weekday = day.first?.startTime.formatted(.dateTime.weekday(.wide)) ?? ""
        return "Day \(selectedDayIndex + 1), \(weekday)"
    }
}

// MARK: - Preview

#Preview {
    ProgrammeView()
        .environment(ViewModel())
}
