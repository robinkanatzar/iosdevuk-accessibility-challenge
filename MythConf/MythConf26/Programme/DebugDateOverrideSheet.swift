//
//  DebugDateOverrideSheet.swift
//  IOSDevuk26
//

import SwiftUI

/// In-app controls for overriding the "current" date used by the Programme
/// countdown banner and `ConfData.whereInConf`. Lets reviewers preview the
/// before-conf, day-of, and after-conf states without changing the device
/// clock.
struct DebugDateOverrideSheet: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    let dateOverride: DateOverride

    @State private var isEnabled: Bool
    @State private var draftDate: Date

    init(dateOverride: DateOverride) {
        self.dateOverride = dateOverride
        _isEnabled = State(initialValue: dateOverride.isOverriding)
        _draftDate = State(initialValue: dateOverride.overrideDate ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $isEnabled) {
                        Text("Override current date")
                    }
                    .accessibilityInputLabels(["Override", "Override date", "Enable override"])

                    if isEnabled {
                        DatePicker(
                            selection: $draftDate,
                            displayedComponents: [.date, .hourAndMinute]
                        ) {
                            Text("Date & time")
                        }
                    }
                } footer: {
                    Text("When enabled, the Programme banner and \"now / next\" calculations use this date instead of the real clock. This is for previewing before-conf, day-of, and after-conf states.")
                }

                Section("Presets") {
                    presetButton(title: "Real time (no override)") {
                        applyPreset(nil)
                    }
                    if let confStart = confStartDate {
                        presetButton(title: "1 week before conf") {
                            applyPreset(daysOffset(from: confStart, days: -7))
                        }
                        presetButton(title: "Day before conf, 18:00") {
                            applyPreset(combine(date: daysOffset(from: confStart, days: -1) ?? confStart, hour: 18))
                        }
                    }
                    ForEach(Array(viewModel.confData.sessions.enumerated()), id: \.offset) { idx, daySessions in
                        if let first = daySessions.first {
                            presetButton(title: "Day \(idx + 1) morning, 10:00") {
                                applyPreset(combine(date: first.startTime, hour: 10))
                            }
                        }
                    }
                    if let confEnd = confEndDate {
                        presetButton(title: "1 day after conf") {
                            applyPreset(daysOffset(from: confEnd, days: 1))
                        }
                    }
                }

                Section("Computed state") {
                    LabeledContent("Resolved now") {
                        Text(resolvedNow.formatted(date: .abbreviated, time: .shortened))
                    }
                    LabeledContent("State") {
                        Text(stateName)
                    }
                }
            }
            .navigationTitle("Date override")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .accessibilityInputLabels(["Close", "Dismiss", "Done"])
                }
            }
            .onChange(of: isEnabled) { _, newValue in
                dateOverride.overrideDate = newValue ? draftDate : nil
            }
            .onChange(of: draftDate) { _, newValue in
                if isEnabled { dateOverride.overrideDate = newValue }
            }
        }
    }

    // MARK: - Computed

    private var resolvedNow: Date {
        isEnabled ? draftDate : .now
    }

    private var stateName: String {
        switch viewModel.confData.whereInConf(now: resolvedNow) {
        case .beforeConf:         return String(localized: "Before conference")
        case .beforeConfDayStart: return String(localized: "Before day start")
        case .duringConfDay:      return String(localized: "During conference day")
        case .afterConfDayEnd:    return String(localized: "After day end")
        case .afterConf:          return String(localized: "After conference")
        case .dummy:              return String(localized: "Outside known days")
        }
    }

    private var confStartDate: Date? {
        viewModel.confData.sessions.first?.first?.startTime
    }

    private var confEndDate: Date? {
        viewModel.confData.sessions.last?.last?.endTime
    }

    // MARK: - Helpers

    @ViewBuilder
    private func presetButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
        }
        .accessibilityInputLabels([title])
    }

    private func applyPreset(_ date: Date?) {
        if let date {
            draftDate = date
            isEnabled = true
            dateOverride.overrideDate = date
        } else {
            isEnabled = false
            dateOverride.overrideDate = nil
        }
    }

    private func daysOffset(from date: Date, days: Int) -> Date? {
        Calendar.current.date(byAdding: .day, value: days, to: date)
    }

    private func combine(date: Date, hour: Int) -> Date {
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = 0
        return cal.date(from: components) ?? date
    }
}
