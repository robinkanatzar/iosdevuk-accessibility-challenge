import SwiftUI

struct ScheduleConflictWarningView: View {
    @Environment(ViewModel.self) private var viewModel

    let conflicts: [ScheduleConflict]

    var body: some View {
        if !conflicts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Schedule conflicts")
                    .font(.headline)
                    .conferenceHeaderAccessibility(label: "Schedule conflicts")

                ForEach(conflicts) { conflict in
                    conflictRow(for: conflict)
                }
            }
            .padding()
            .background(.orange.opacity(0.14), in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.orange.opacity(0.45), lineWidth: 1)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    private func conflictRow(for conflict: ScheduleConflict) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(
                "\(conflict.conflictCount) saved sessions at \(conflict.timeRange.visualText)",
                systemImage: "exclamationmark.triangle"
            )
            .font(.subheadline)
            .bold()

            ForEach(conflict.talkIDs, id: \.self) { talkID in
                Text(viewModel.talkTitleFrom(talkID: talkID))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .conferenceGroupAccessibility(
            label: accessibilityLabel(for: conflict),
            hint: "Choose one of these sessions to avoid a schedule overlap."
        )
    }

    private func accessibilityLabel(for conflict: ScheduleConflict) -> String {
        let titles = conflict.talkIDs
            .map { viewModel.talkTitleFrom(talkID: $0) }
            .joined(separator: ", ")

        return "Conflict. \(conflict.conflictCount) saved sessions at \(conflict.timeRange.accessibilityLabel): \(titles)"
    }
}

#Preview {
    ScheduleConflictWarningView(conflicts: [])
        .environment(ViewModel())
}
