//
//  SessionDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkReference: TalkReference

    @State private var isInlineTitleVisible = true

    private var talk: Talk { viewModel.talkFrom(talkID: talkReference.talkID) }
    private var session: Session { talkReference.session }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(talk.talkTitle)
                    .font(.title2)
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                    .padding(.bottom, 4)
                    .onScrollVisibilityChange(threshold: 0.1) { visible in
                        isInlineTitleVisible = visible
                    }

                // Time and location
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Label(session.timeRange, systemImage: "clock")
                            .accessibilityLabel(Text("From \(session.startTimeText) to \(session.endTimeText)"))
                        Spacer()
                        NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                            locationLinkLabel
                        }
                    }
                    VStack(alignment: .leading) {
                        Label(session.timeRange, systemImage: "clock")
                            .accessibilityLabel(Text("From \(session.startTimeText) to \(session.endTimeText)"))
                        NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                            locationLinkLabel
                        }
                    }
                }
                .font(.subheadline)
                .secondaryTextStyle()
                .padding(.bottom)

                // Speakers
                ForEach(talk.speakerIDs, id: \.self) { speakerID in
                    NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                        HStack(spacing: 8) {
                            SpeakerRowView(speakerID: speakerID)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }

                Divider()
                    .padding(.vertical)

                // Abstract
                Text(talk.talkDescription)
            }
            .padding()
        }
        .toolbar {
            if !isInlineTitleVisible {
                ToolbarItem(placement: .principal) {
                    Text(talk.talkTitle)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                FavouriteButtonView(talk: talk)
                    // Full Keyboard Access: ⌘D toggles favourite from the
                    // detail screen without having to focus the toolbar star.
                    .keyboardShortcut("d", modifiers: .command)
            }
        }
    }

    private var locationLinkLabel: some View {
        HStack(spacing: 6) {
            Label(viewModel.locationNameFrom(locationID: talk.locationID), systemImage: "mappin")
                .labelStyle(.automatic)
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(5)
                .glassEffect(.regular, in: .circle)
                .accessibilityHidden(true)
        }
    }
}
