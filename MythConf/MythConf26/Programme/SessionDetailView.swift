//
//  SessionDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkReference: TalkReference

    private var talk: Talk { viewModel.talkFrom(talkID: talkReference.talkID) }
    private var session: Session { talkReference.session }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Time and location
                ViewThatFits {
                    HStack {
                        Label(session.timeRange, systemImage: "clock")
                            .accessibilityLabel(session.timeRange)
                        Spacer(minLength: 0)
                        NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                            Label(viewModel.locationNameFrom(locationID: talk.locationID), systemImage: "mappin")
                                .labelStyle(.automatic)
                        }
                        .accessibilityHint("Opens location on map")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)

                    VStack(alignment: .leading) {
                        Label(session.timeRange, systemImage: "clock")
                            .accessibilityLabel(session.timeRange)
                            .padding(.bottom, 4)
                        NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                            Label(viewModel.locationNameFrom(locationID: talk.locationID), systemImage: "mappin")
                                .labelStyle(.automatic)
                        }
                        .accessibilityHint("Opens location on map")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                }

                // Speakers
                ForEach(talk.speakerIDs, id: \.self) { speakerID in
                    NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                        SpeakerRowView(speakerID: speakerID)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens speaker profile")
                }

                Divider()
                    .padding(.vertical)
                    .accessibilityHidden(true)

                // Abstract
                Text(talk.talkDescription)
            }
            .padding()
        }
        .navigationTitle(talk.talkTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavouriteButtonView(talk: talk)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let viewModel = ViewModel()
    let session = viewModel.confData.sessions.flatMap { $0 }.first { $0.containsTalk }!
    NavigationStack {
        SessionDetailView(
            talkReference: TalkReference(talkID: session.contentIDs.first!, session: session)
        )
    }
    .environment(viewModel)
}
