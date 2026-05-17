import SwiftUI

struct NowNextBadge: View {
    let position: ViewModel.SchedulePosition

    private var title: String {
        switch position {
        case .now:
            return "Now"
        case .next:
            return "Next"
        }
    }

    private var tint: Color {
        switch position {
        case .now:
            return .blue
        case .next:
            return .green
        }
    }

    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.black)
            .textCase(.uppercase)
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(tint.opacity(0.16)))
            .accessibilityIdentifier("schedule.position.\(title.lowercased())")
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 12) {
        NowNextBadge(position: .now)
        NowNextBadge(position: .next)
    }
    .padding()
}
