//
//  ScheduleSiriSnippetView.swift
//  MythConf26
//

import SwiftUI

struct ScheduleSiriSnippetView: View {
    let sessions: [ConferenceSessionEntity]
    let remainingCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Schedule")
                    .font(.body.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)

                Text(sessionCountText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if sessions.isEmpty {
                Text("No saved sessions yet.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sessions) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.title)
                            .font(.body.weight(.semibold))
                            .lineLimit(2)

                        Text("\(session.dayAndDate), \(session.timeRange)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(session.locationName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if session.id != sessions.last?.id {
                        Divider()
                    }
                }

                if remainingCount > 0 {
                    Text(remainingText)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    private var sessionCountText: String {
        let total = sessions.count + remainingCount
        return total == 1 ? "1 saved session" : "\(total) saved sessions"
    }

    private var remainingText: String {
        remainingCount == 1 ? "1 more saved session in the app" : "\(remainingCount) more saved sessions in the app"
    }
}
