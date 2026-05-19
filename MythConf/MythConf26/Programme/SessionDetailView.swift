//
//  SessionDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let talkReference: TalkReference
    
    private var talk: Talk { viewModel.talkFrom(talkID: talkReference.talkID) }
    private var session: Session { talkReference.session }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Time and location
                metadataRow
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                
                // Speakers
                if !talk.speakerIDs.isEmpty {
                    Text(talk.speakerIDs.count == 1 ? "Speaker" : "Speakers")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.bottom, 4)
                    
                    ForEach(talk.speakerIDs, id: \.self) { speakerID in
                        NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                            SpeakerRowView(speakerID: speakerID)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Double tap to view speaker details")
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Abstract
                Text("About this talk")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.bottom, 4)
                
                Text(talk.talkDescription)
                    .accessibilityLabel(talk.talkDescription)
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
    
    /// Time + location, adapting to a stacked layout at accessibility text sizes.
    @ViewBuilder
    private var metadataRow: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                timeLabel
                locationLink
            }
        } else {
            HStack {
                timeLabel
                Spacer()
                locationLink
            }
        }
    }
    
    private var timeLabel: some View {
        Label {
            Text(session.timeRange)
        } icon: {
            Image(systemName: "clock")
                .accessibilityHidden(true)
        }
        .accessibilityLabel(session.accessibleTimeRange)
    }
    
    private var locationLink: some View {
        NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
            Label {
                Text(viewModel.locationNameFrom(locationID: talk.locationID))
            } icon: {
                Image(systemName: "mappin")
                    .accessibilityHidden(true)
            }
        }
        .accessibilityLabel("Location: \(viewModel.locationNameFrom(locationID: talk.locationID))")
        .accessibilityHint("Double tap to view location details and map")
    }
}

