import SwiftUI

struct ProgrammeDaySummaryView: View {
    let dayIndex: Int
    let sessions: [Session]

    private var dayTitle: String {
        guard let first = sessions.first else {
            return "Conference day"
        }

        return first.startTime.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    private var talkCount: Int {
        sessions.reduce(0) { partialResult, session in
            guard session.containsTalk else {
                return partialResult
            }

            return partialResult + session.contentIDs.count
        }
    }

    private var activityCount: Int {
        sessions.filter { !$0.containsTalk }.count
    }

    private var summaryText: String {
        let talkText = talkCount == 1 ? "1 talk" : "\(talkCount) talks"
        let activityText = activityCount == 1 ? "1 activity" : "\(activityCount) activities"

        return "\(talkText), \(activityText)"
    }

    private var accessibilityLabel: String {
        "Day \(dayIndex + 1), \(dayTitle). \(summaryText)."
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "calendar")
                .font(.title3)
                .frame(width: 32, height: 32)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Day \(dayIndex + 1)")
                    .font(.headline)

                Text(dayTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(summaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.bottom, 8)
        .conferenceGroupAccessibility(
            label: accessibilityLabel,
            hint: "Swipe right to browse this day's sessions."
        )
    }
}

#Preview {
    ProgrammeDaySummaryView(dayIndex: 0, sessions: [])
}
