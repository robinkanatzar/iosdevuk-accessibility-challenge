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
                Label(session.timeRange, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Time, \(session.timeRangeAccessible)")

                NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                    Label(viewModel.locationNameFrom(locationID: talk.locationID), systemImage: "mappin")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Location, \(viewModel.locationNameFrom(locationID: talk.locationID))")
                .accessibilityHint("Opens location details")
                .padding(.bottom)

                Text("Speakers")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                ForEach(talk.speakerIDs, id: \.self) { speakerID in
                    NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                        SpeakerRowView(speakerID: speakerID)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens speaker profile")
                }
                .accessibilityRotor("Speakers") {
                    ForEach(talk.speakerIDs, id: \.self) { speakerID in
                        AccessibilityRotorEntry(viewModel.speakerNameFrom(speakerID: speakerID), id: speakerID)
                    }
                }

                Divider()
                    .padding(.vertical)

                Text("About this session")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                Text(talk.talkDescription)
            }
            .padding()
        }
        .navigationTitle(talk.talkTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavouriteButtonView(talk: talk)
            }
        }
        .resetVoiceOverFocusOnAppear()
    }
}
