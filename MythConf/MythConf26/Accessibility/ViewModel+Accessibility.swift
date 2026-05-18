import Foundation

extension ViewModel {
    func sessionAccessibilitySummary(
        for talkID: UUID,
        in session: Session
    ) -> SessionAccessibilitySummary {
        let talk = talkFrom(talkID: talkID)
        let speakers = talk.speakerIDs.map { speakerNameFrom(speakerID: $0) }
        let location = locationNameFrom(talkID: talkID)
        let timeRange = AccessibleTimeRange(
            start: session.startTime,
            end: session.endTime
        )

        return SessionAccessibilitySummary(
            sessionType: session.sessionType.displayName,
            title: talk.talkTitle,
            speakers: speakers,
            location: location,
            timeRange: timeRange,
            isFavourite: isFavourite(talk: talk)
        )
    }
}
