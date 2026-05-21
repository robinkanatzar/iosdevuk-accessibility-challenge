//
//  SessionDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let talkReference: TalkReference
    
    private var talk: Talk { viewModel.talkFrom(talkID: talkReference.talkID) }
    private var session: Session { talkReference.session }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Time and location
                let layout = (horizontalSizeClass == .compact || UIDevice.current.userInterfaceIdiom == .pad) && dynamicTypeSize >= .accessibility3 ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(alignment: .top))
                layout {
                    Label(session.timeRange, systemImage: "clock")
                        .accessibilityLabel(session.voiceOverTimeRange)
                    Spacer()
                    NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                        Label(viewModel.locationNameFrom(locationID: talk.locationID), systemImage: "mappin")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom)
                
                // Speakers
                ForEach(talk.speakerIDs, id: \.self) { speakerID in
                    NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                        SpeakerRowView(speakerID: speakerID)
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
        .navigationTitle(talk.talkTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavouriteButtonView(talk: talk)
            }
        }
    }
}
