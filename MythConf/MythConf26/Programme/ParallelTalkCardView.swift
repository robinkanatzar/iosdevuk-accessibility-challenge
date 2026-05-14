//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    let talkID: UUID
    let session: Session
    /// Reserved bottom space inside the card so the favourite star icon
    /// doesn't sit on top of the location text. Scales with Dynamic Type so
    /// the icon stays clear at larger text sizes.
    @ScaledMetric(relativeTo: .caption) private var starReservedHeight: CGFloat = 28

    private var cardOpacity: Double { (contrast == .increased || reduceTransparency) ? 0.25 : 0.1 }

    var body: some View {
        // Re-evaluate the live status every minute so badges flip from
        // "Starts in 12 min" through "Now" to gone without any manual
        // refresh. TimelineView only rebuilds the inside of its closure,
        // so the cost is a cheap label-string change plus an overlay.
        TimelineView(.everyMinute) { context in
            let liveStatus = SessionLiveStatus.status(for: session, now: context.date)
            cardBody(liveStatus: liveStatus)
        }
    }

    @ViewBuilder
    private func cardBody(liveStatus: SessionLiveStatus) -> some View {
        NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
            VStack(alignment: .leading, spacing: 0) {
                session.sessionType.color
                    .frame(height: 4)
                    .accessibilityHidden(true)

                HStack(alignment: .top) {
                    TimeColumnView(
                        startTime: session.startTimeText,
                        endTime: session.endTimeText,
                        startTimeAccessibility: session.startTimeAccessibilityText,
                        endTimeAccessibility: session.endTimeAccessibilityText
                    )

                    VStack(alignment: .leading) {
                        Text(viewModel.talkTitleFrom(talkID: talkID))
                            .bold()
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                        Text(viewModel.speakersFrom(talkID: talkID))
                            .font(.caption)
                            .contrastAdaptiveSecondary()
                            .multilineTextAlignment(.leading)
                        Text(viewModel.locationNameFrom(talkID: talkID))
                            .font(.caption)
                            .contrastAdaptiveSecondary()
                        // Space reserved so the overlay star icon doesn't sit on
                        // top of the location text. The button's invisible hit
                        // area extends further up but doesn't push layout.
                        Color.clear.frame(height: starReservedHeight)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(session.sessionType.color.opacity(cardOpacity), in: .rect(cornerRadius: 10))
            .clipShape(.rect(cornerRadius: 10))
            .overlay(
                (contrast == .increased || reduceTransparency || differentiateWithoutColor) ?
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(session.sessionType.color, lineWidth: 1.5)
                        .allowsHitTesting(false) : nil
            )
            .overlay(alignment: .topTrailing) {
                if let badge = liveStatus.badgeText {
                    LiveStatusBadge(text: badge, isLive: liveStatus == .live)
                        .padding(8)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityLabel(viewModel.talkCardAccessibilityLabel(talkID: talkID, in: session, liveStatus: liveStatus))
        .accessibilityHint("Opens session details")
        .accessibilityInputLabels([viewModel.talkTitleFrom(talkID: talkID)])
        .buttonStyle(.plain)
        .overlay(alignment: .bottomTrailing) {
            FavouriteButtonView(talk: viewModel.talkFrom(talkID: talkID))
                .padding(8)
        }
    }
}

/// Small pill rendered over a talk card to flag the talk as currently
/// underway or starting soon. Visual cue only — the same information is
/// spoken via the talk card's `accessibilityLabel` prefix.
private struct LiveStatusBadge: View {
    let text: String
    let isLive: Bool

    var body: some View {
        Text(text)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(isLive ? Color.orange : Color.secondary, in: .capsule)
    }
}
