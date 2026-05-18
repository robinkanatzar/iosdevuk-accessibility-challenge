import SwiftUI

struct ScheduleStatusView: View {
    let favouriteCount: Int
    let conflictCount: Int

    private var title: String {
        if favouriteCount == 1 {
            return "1 saved session"
        }

        return "\(favouriteCount) saved sessions"
    }

    private var subtitle: String {
        if conflictCount == 0 {
            return "Your personal schedule is ready."
        }

        if conflictCount == 1 {
            return "1 time slot has overlapping saved sessions."
        }

        return "\(conflictCount) time slots have overlapping saved sessions."
    }

    private var symbolName: String {
        conflictCount == 0 ? "checkmark.circle" : "exclamationmark.triangle"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbolName)
                .font(.title3)
                .foregroundStyle(conflictCount == 0 ? .green : .orange)
                .frame(width: 32, height: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top)
        .conferenceGroupAccessibility(
            label: "\(title). \(subtitle)",
            hint: "Review your saved conference sessions."
        )
    }
}

#Preview {
    VStack {
        ScheduleStatusView(favouriteCount: 3, conflictCount: 0)
        ScheduleStatusView(favouriteCount: 4, conflictCount: 1)
    }
}
