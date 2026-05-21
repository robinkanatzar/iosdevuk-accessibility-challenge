//
//  ProgrammeView.swift
//  IOSDevuk26
//

import SwiftUI

struct ProgrammeView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var selectedDayIndex = 0
    @AppStorage("useDyslexiaFont") private var useDyslexiaFont = false

    private var days: [[Session]] { viewModel.confData.sessions }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                let phase = viewModel.confData.whereInConf()
                if !phase.displayName.isEmpty {
                    Text(phase.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                        .accessibilityAddTraits(.isHeader)
                }

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
            .onChange(of: selectedDayIndex) { _, newValue in
                let label = dayLabel(for: days[newValue])
                UIAccessibility.post(notification: .announcement, argument: "Showing \(label)")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            AppLocalization.shared.isHindi.toggle()
                        } label: {
                            Image(systemName: "globe")
                        }
                        .accessibilityLabel(AppLocalization.shared.isHindi ? "Switch to English" : "हिंदी में बदलें")

                        Button {
                            useDyslexiaFont.toggle()
                        } label: {
                            Image(systemName: useDyslexiaFont ? "textformat.alt" : "textformat")
                        }
                        .accessibilityLabel(useDyslexiaFont ? "Disable reading-friendly font" : "Enable reading-friendly font")
                        .accessibilityHint("Switches to a rounded font design that may improve readability")
                    }
                }
            }
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
