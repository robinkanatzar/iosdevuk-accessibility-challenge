import SwiftUI

struct SessionStatusBadge: View {
    @Environment(ViewModel.self) private var viewModel

    let session: Session

    private var display: Session.StatusDisplay {
        session.statusDisplay(now: viewModel.currentDate)
    }

    private var tint: Color {
        switch display.status {
        case .live:     return .red
        case .upcoming: return .orange
        case .ended:    return .secondary
        }
    }

    @ViewBuilder
    var body: some View {
        if display.isVisible {
            Label {
                Text(display.title)
            } icon: {
                Image(systemName: display.symbolName)
                    .accessibilityHidden(true)
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(tint)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .background(Capsule().fill(tint.opacity(0.12)))
            .accessibilityLabel(display.accessibilityLabel)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        }
    }
}
