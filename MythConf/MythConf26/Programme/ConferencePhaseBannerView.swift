//
//  ConferencePhaseBannerView.swift
//  IOSDevuk26
//

import SwiftUI

/// A thin banner at the top of the Programme tab that places the user
/// in time relative to the whole conference — "Day 2 of 3", "Conference
/// starts tomorrow", "Conference has ended". Reduces the cognitive load
/// of figuring out where you are in the schedule.
///
/// Re-evaluates once a minute via `TimelineView(.everyMinute)` so the
/// phrasing automatically updates as the conference progresses (the day
/// rolls over, "starts in 3 days" becomes "tomorrow", and so on)
/// without a manual refresh.
struct ConferencePhaseBannerView: View {
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        TimelineView(.everyMinute) { context in
            let phase = viewModel.confData.phase(now: context.date)
            HStack(spacing: 8) {
                Image(systemName: phase.bannerSymbolName)
                    .accessibilityHidden(true)
                Text(phase.bannerText)
                    .font(.subheadline)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(background(for: phase))
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
        }
    }

    @ViewBuilder
    private func background(for phase: ConferencePhase) -> some View {
        switch phase {
        case .upcoming:   Color.blue.opacity(0.12)
        case .inProgress: Color.green.opacity(0.15)
        case .finished:   Color.secondary.opacity(0.12)
        }
    }
}
