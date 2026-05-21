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
                HStack {
                    Label(session.timeRange, systemImage: "clock")
                    Spacer()
                    NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                        Label(viewModel.locationNameFrom(locationID: talk.locationID), systemImage: "mappin")
                    }
                }
                .appFont(.subheadline, useLexend: viewModel.useLexendFont)
                .foregroundStyle(.secondary)
                .padding(.bottom)

                // Speakers
                ForEach(talk.speakerIDs, id: \.self) { speakerID in
                    NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                        SpeakerRowView(speakerID: speakerID)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("""
                    \(viewModel.speakerFrom(speakerID: speakerID).name).
                    \(accessibilityPreview(text: viewModel.speakerFrom(speakerID: speakerID).speakerInfo))
                    Double tap for full biography.
                    """)
                }

                Divider()
                    .padding(.vertical)

                // Abstract
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
    }
    
    private func accessibilityPreview(
        text: String,
        maxLength: Int = 120
    ) -> String {
        if text.count <= maxLength {
            return text
        }

        return String(text.prefix(maxLength)) + "…"
    }
}
