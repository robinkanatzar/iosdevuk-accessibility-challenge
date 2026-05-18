import SwiftUI

struct SessionDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkReference: TalkReference

    private var talk: Talk { viewModel.talkFrom(talkID: talkReference.talkID) }
    private var session: Session { talkReference.session }
    private var timeRange: AccessibleTimeRange {
        AccessibleTimeRange(start: session.startTime, end: session.endTime)
    }

    private var locationName: String {
        viewModel.locationNameFrom(locationID: talk.locationID)
    }

    private var speakers: [Speaker] {
        talk.speakerIDs.map { speakerID in
            viewModel.speakerFrom(speakerID: speakerID)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SessionDetailHeaderView(
                    title: talk.talkTitle,
                    timeRange: timeRange,
                    locationID: talk.locationID,
                    locationName: locationName
                )

                SessionDetailSpeakersSectionView(speakers: speakers)

                Divider()

                SessionDetailAbstractSectionView(text: talk.talkDescription)
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
