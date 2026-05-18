import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
struct BreakRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    let session: Session

    private var timeRange: AccessibleTimeRange {
        AccessibleTimeRange(start: session.startTime, end: session.endTime)
    }

    private var locationName: String? {
        guard let talkID = session.contentIDs.first else { return nil }
        return viewModel.locationNameFrom(talkID: talkID)
    }

    private var accessibilityLabel: String {
        [
            session.sessionType.displayName,
            timeRange.accessibilityLabel,
            locationName
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }

    private var backgroundOpacity: Double {
        0.14
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            TimeColumnView(startTime: session.startTime, endTime: session.endTime)

            Image(systemName: session.sessionType.symbolName)
                .font(.title3)
                .frame(width: 32, height: 32)
                .foregroundStyle(session.sessionType.color)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.sessionType.displayName)
                    .italic()
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                if let locationName {
                    Label(locationName, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if differentiateWithoutColor {
                    Text("Session type: \(session.sessionType.displayName)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(session.sessionType.color.opacity(backgroundOpacity), in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(session.sessionType.color.opacity(0.35), lineWidth: differentiateWithoutColor ? 2 : 1)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .conferenceGroupAccessibility(
            label: accessibilityLabel,
            hint: "Break or conference activity."
        )
    }
}
