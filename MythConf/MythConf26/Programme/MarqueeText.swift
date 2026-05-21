//
//  MarqueeText.swift
//  IOSDevuk26
//

import SwiftUI

/// A single-line text view that scrolls horizontally (right-to-left) when
/// its content is wider than the available space. Falls back to a static,
/// tail-truncated label when Reduce Motion is enabled, and always exposes
/// the full text to VoiceOver regardless of how much is visually on screen.
struct MarqueeText: View {
    let text: String
    var font: Font = .headline
    /// Scroll speed in points per second.
    var speed: Double = 32
    /// Gap between the trailing edge of the text and its repeated copy.
    var spacing: CGFloat = 40

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var textSize: CGSize = .zero

    var body: some View {
        // Invisible Text anchors the view's height to the font's natural
        // single-line height from the very first frame. Without it, a
        // freshly inserted MarqueeText would start at 1pt (because
        // `textSize` is .zero before `measurement` runs) and visibly grow
        // once measurement reported back, producing a jumpy fade.
        // `.frame(maxWidth: .infinity)` keeps the view greedy horizontally
        // so the row width stays stable across cycles regardless of the
        // current talk title's natural width.
        Text(text)
            .font(font)
            .lineLimit(1)
            .opacity(0)
            .accessibilityHidden(true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    content(containerWidth: proxy.size.width)
                }
            }
            .background(measurement)
            .accessibilityLabel(Text(text))
    }

    @ViewBuilder
    private func content(containerWidth: CGFloat) -> some View {
        let needsScroll = !reduceMotion && textSize.width > containerWidth + 0.5
        if needsScroll {
            scrollingText(containerWidth: containerWidth)
        } else {
            Text(text)
                .font(font)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    private func scrollingText(containerWidth: CGFloat) -> some View {
        TimelineView(.animation) { context in
            let cycle = textSize.width + spacing
            let elapsed = context.date.timeIntervalSinceReferenceDate
            let offset = -((elapsed * speed).truncatingRemainder(dividingBy: cycle))

            HStack(spacing: spacing) {
                singleText
                singleText
            }
            .offset(x: offset)
            .frame(width: containerWidth, alignment: .leading)
            .clipped()
        }
    }

    private var singleText: some View {
        Text(text)
            .font(font)
            .fixedSize(horizontal: true, vertical: false)
    }

    private var measurement: some View {
        Text(text)
            .font(font)
            .fixedSize(horizontal: true, vertical: false)
            .hidden()
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { textSize = proxy.size }
                        .onChange(of: proxy.size) { _, newSize in textSize = newSize }
                }
            }
    }
}
