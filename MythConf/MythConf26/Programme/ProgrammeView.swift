//
//  ProgrammeView.swift
//  IOSDevuk26
//

import SwiftUI
import TipKit

struct ProgrammeView: View {
    @Environment(ViewModel.self) private var viewModel
    @Binding var selectedTab: Int
    @State private var selectedDayIndex = 0
    @State private var path: [TalkReference] = []   // ← new
    @State private var isShowingSettings = false
    @AccessibilityFocusState private var isSettingsButtonFocused: Bool
    private let dayPickerTip = ConferenceDayPickerTip()

    private var days: [[Session]] { viewModel.confData.sessions }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                Picker("Conference day", selection: $selectedDayIndex) {
                    ForEach(days.indices, id: \.self) { index in
                        Text(dayLabel(for: days[index]))
                            .tag(index)
                            .frame(minHeight: 44)
                            .accessibilityLabel("\(ordinalDayLabel(for: index)), \(fullDayLabel(for: days[index]))")
                            .accessibilityInputLabels([
                                dayLabel(for: days[index]),
                                fullDayLabel(for: days[index]),
                                ordinalDayLabel(for: index)
                            ])
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("programme.dayPicker")
                .padding(.horizontal)
                .padding(.vertical, 8)
                .popoverTip(dayPickerTip, arrowEdge: .top)

                if !days.isEmpty {
                    DayScheduleView(sessions: days[selectedDayIndex])
                }

                if CommandLine.arguments.contains("-UITesting") {
                    Text(viewModel.pendingReminderDebugSummary)
                        .accessibilityIdentifier("debug.pendingReminderSummary")
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                }
            }
            .navigationTitle("MythConf 2026")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsToolbarButton {
                        isShowingSettings = true
                    }
                    .accessibilityFocused($isSettingsButtonFocused)
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .onChange(of: isShowingSettings) { _, isPresented in
                guard !isPresented else { return }
                restoreSettingsButtonFocus()
            }
            .onAppear {
                SaveSessionTip.hasViewedSaveContext = true
                ConferenceDayPickerTip.hasViewedProgramme = true
                ConferenceDayPickerTip.hasMultipleConferenceDays = days.count > 1

                let confTimeType = viewModel.confData.whereInConf()
                guard confTimeType != .beforeConf, confTimeType != .afterConf else { return }
                if let todayIndex = days.firstIndex(where: { sessions in
                    guard let first = sessions.first else { return false }
                    return Calendar.current.isDateInToday(first.startTime)
                }) {
                    selectedDayIndex = todayIndex
                }
            }
            .onChange(of: selectedDayIndex) { _, _ in
                ConferenceDayPickerTip.hasChangedProgrammeDay = true
                dayPickerTip.invalidate(reason: .actionPerformed)
            }
            .conferenceNavigationDestinations()
        }.onChange(of: viewModel.pendingDeepLinkTalkID) { _, talkID in
            print("📍 [DeepLink] onChange(pendingDeepLinkTalkID) fired — value: \(talkID?.uuidString ?? "nil")")

            guard let talkID else {
                print("📍 [DeepLink] talkID is nil, ignoring")
                return
            }
            guard let session = viewModel.sessionFor(talkID: talkID) else {
                print("📍 [DeepLink] ❌ No session found for talkID: \(talkID)")
                return
            }

            print("📍 [DeepLink] ✅ Found session starting \(session.startTime) — pushing TalkReference")
            if let dayIndex = days.firstIndex(where: { $0.contains(session) }) {
                print("📍 [DeepLink] Switching day picker to index \(dayIndex)")
                selectedDayIndex = dayIndex
            } else {
                print("📍 [DeepLink] ⚠️ Session not found in any day — day picker not changed")
            }

            path = [TalkReference(talkID: talkID, session: session)]
            viewModel.pendingDeepLinkTalkID = nil
            print("📍 [DeepLink] path set, pendingDeepLinkTalkID cleared")
        }
    }

    private func restoreSettingsButtonFocus() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            isSettingsButtonFocused = true
        }
    }

    private func dayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.abbreviated))
    }

    private func fullDayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    private func ordinalDayLabel(for index: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal

        let number = NSNumber(value: index + 1)
        let ordinal = formatter.string(from: number) ?? "\(index + 1)"

        return "\(ordinal) day"
    }
}

#Preview {
    ProgrammeView(selectedTab: .constant(0))
        .environment(ViewModel())
}
