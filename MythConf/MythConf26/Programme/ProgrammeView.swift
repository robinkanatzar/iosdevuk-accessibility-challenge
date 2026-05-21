//
//  ProgrammeView.swift
//  IOSDevuk26
//

import SwiftUI

struct ProgrammeView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var selectedDayIndex = 0
    @Namespace private var rotorNamespace

    private var days: [[Session]] { viewModel.confData.sessions }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Select conference day", selection: $selectedDayIndex) {
                    ForEach(days.indices, id: \.self) { index in
                        Text(dayLabel(for: days[index]))
                            .tag(index)
                            .accessibilityLabel("Day \(index + 1), \(fullDayLabel(for: days[index]))")
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if !days.isEmpty {
                    DayScheduleView(sessions: days[selectedDayIndex], rotorNamespace: rotorNamespace)
                        .accessibilityRotor("Favourites") {
                            ForEach(favouritedTalkIDs(in: days[selectedDayIndex]), id: \.self) { talkID in
                                AccessibilityRotorEntry(viewModel.talkTitleFrom(talkID: talkID), talkID, in: rotorNamespace)
                            }
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
            .onChange(of: selectedDayIndex) { _, newValue in
                guard days.indices.contains(newValue) else { return }
                let label = fullDayLabel(for: days[newValue])
                AccessibilityNotification.Announcement("Now showing \(label)").post()
            }
            .conferenceNavigationDestinations()
        }
    }

    private func dayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.abbreviated))
    }

    private func fullDayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide))
    }

    private func favouritedTalkIDs(in sessions: [Session]) -> [UUID] {
        sessions.flatMap { session in
            session.contentIDs.filter { id in
                guard session.containsTalk else { return false }
                return viewModel.isFavourite(talk: viewModel.talkFrom(talkID: id))
            }
        }
    }
}

#Preview {
    ProgrammeView()
        .environment(ViewModel())
}
