//
//  SessionSiriDetailSnippetView.swift
//  MythConf26
//

import SwiftUI

struct SessionSiriDetailSnippetView: View {
    let session: SearchableSessionEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(session.title)
                .font(.body.weight(.semibold))
                .lineLimit(3)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 8) {
                detailRow("Speaker", session.speakerNames)
                detailRow("Time", "\(session.dayAndDate), \(session.timeRange)")
                detailRow("Location", session.locationName)
            }

            Text(session.summary)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(4)
        }
        .padding()
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.body)
                .lineLimit(2)
        }
    }
}
