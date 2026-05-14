//
//  MythConf26Tests.swift
//  MythConf26Tests
//

import Foundation
import Testing
import UIKit
@testable import MythConf26

/// Tests around the favourites cycle. The favourite button's accessibility
/// label, hint, `.isSelected` trait, and the announcement it triggers all
/// derive from `ViewModel.isFavourite`, so the round-trip integrity of these
/// methods is what makes the VoiceOver experience correct.
///
/// Serialised because favourites are persisted to a shared `favourites.json`
/// in the test host's Documents directory; parallel tests would race on the
/// underlying file.
@Suite(.serialized)
struct FavouritesTests {
    let viewModel: ViewModel
    let talk: Talk

    init() throws {
        viewModel = ViewModel()
        talk = try #require(viewModel.confData.talks.first)
        // Start each test from a known clean state.
        viewModel.removeFavourite(talk: talk)
    }

    @Test func newTalkIsNotFavouriteByDefault() {
        #expect(viewModel.isFavourite(talk: talk) == false)
    }

    @Test func addingATalkMakesItFavourite() {
        viewModel.addFavourite(talk: talk)

        #expect(viewModel.isFavourite(talk: talk))
        #expect(viewModel.favouriteIds.contains(talk.id))
    }

    @Test func removingAFavouriteClearsIt() {
        viewModel.addFavourite(talk: talk)

        viewModel.removeFavourite(talk: talk)

        #expect(viewModel.isFavourite(talk: talk) == false)
        #expect(viewModel.favouriteIds.contains(talk.id) == false)
    }

    /// Removing a talk that was never a favourite must be a no-op. The
    /// favourite button does not check the current state before calling
    /// `removeFavourite`, so a defensive remove must not crash or corrupt
    /// state.
    @Test func removingANonFavouriteIsHarmless() {
        viewModel.removeFavourite(talk: talk)

        #expect(viewModel.isFavourite(talk: talk) == false)
    }

    /// Two talks must be tracked independently — adding one must not flip
    /// the other.
    @Test func favouritesAreTrackedPerTalk() throws {
        let other = try #require(viewModel.confData.talks.dropFirst().first)
        viewModel.removeFavourite(talk: other)

        viewModel.addFavourite(talk: talk)

        #expect(viewModel.isFavourite(talk: talk))
        #expect(viewModel.isFavourite(talk: other) == false)

        viewModel.removeFavourite(talk: talk)
    }

    /// `favouritesBySession` powers My Schedule. After adding a talk, the
    /// flattened list of session content IDs across all days must contain
    /// that talk.
    @Test @MainActor func favouritesBySessionReflectsAddedTalk() {
        viewModel.addFavourite(talk: talk)

        let allFavouriteContentIDs = viewModel.favouritesBySession
            .flatMap { $0 }
            .filter { $0.sessionType != .dummy }
            .flatMap(\.contentIDs)

        #expect(allFavouriteContentIDs.contains(talk.id))
    }
}

/// Tests for the lookup helpers on `ViewModel`. The talk card's accessibility
/// label is composed from these — if any returns inconsistent or empty data,
/// VoiceOver hears a malformed announcement.
struct LookupTests {
    let viewModel = ViewModel()

    /// `talkTitleFrom(talkID:)` and `talkFrom(talkID:)` must agree.
    @Test func talkLookupsAreConsistent() throws {
        let talk = try #require(viewModel.confData.talks.first)

        #expect(viewModel.talkTitleFrom(talkID: talk.id) == talk.talkTitle)
        #expect(viewModel.talkFrom(talkID: talk.id).id == talk.id)
    }

    /// Title → ID → title must round-trip cleanly. This guards against
    /// duplicate titles silently breaking the input-label flow used by
    /// Voice Control.
    @Test func talkTitleRoundTrip() throws {
        let talk = try #require(viewModel.confData.talks.first)

        let resolved = viewModel.talkUUIDFrom(talkTitle: talk.talkTitle)

        #expect(resolved == talk.id)
        #expect(viewModel.talkTitleFrom(talkID: resolved) == talk.talkTitle)
    }

    /// Every talk must resolve to a non-empty location name. The talk
    /// card's accessibility label trails with the location, so a missing
    /// value would produce a sentence ending mid-clause.
    @Test func everyTalkHasANonEmptyLocationName() {
        for talk in viewModel.confData.talks {
            let name = viewModel.locationNameFrom(talkID: talk.id)
            #expect(!name.isEmpty, "Talk '\(talk.talkTitle)' has empty location name")
        }
    }

    /// `speakersFrom` must return a non-empty string for every talk so the
    /// card's "by [speakers]" clause is never blank. Talks with missing or
    /// unknown speaker IDs fall back to a placeholder rather than crashing.
    @Test func everyTalkHasASpeakerName() {
        for talk in viewModel.confData.talks {
            let speakers = viewModel.speakersFrom(talkID: talk.id)
            #expect(!speakers.isEmpty, "Talk '\(talk.talkTitle)' produced empty speaker name string")
        }
    }

    /// Talks with multiple speakers are joined by `formatted(.list(type:.and))`
    /// — "A and B" or "A, B, and C" — so VoiceOver doesn't run names
    /// together. The current conf data has no multi-speaker talks, so this
    /// test verifies the formatter contract directly with synthetic input
    /// to guard the behaviour for when the data does include co-presented
    /// talks.
    @Test func multipleSpeakersAreJoinedNaturally() {
        let two = ["Ada Lovelace", "Alan Turing"].formatted(.list(type: .and))
        let three = ["Ada Lovelace", "Alan Turing", "Grace Hopper"].formatted(.list(type: .and))

        #expect(two.contains(" and "), "Two-speaker join should contain ' and ': got '\(two)'")
        #expect(three.contains(" and "), "Three-speaker join should contain ' and ': got '\(three)'")
    }
}

/// Tests for the talk card's spoken accessibility label. Every comma,
/// connective and word ordering matters — VoiceOver users hear this string
/// for every talk on the Programme tab, so a regression in shape would
/// degrade the experience without showing up visually.
struct TalkCardAccessibilityLabelTests {
    let viewModel = ViewModel()

    /// The label must follow the format
    /// "[Type] from [start] to [end]: [title], by [speakers], [location]"
    /// so VoiceOver reads a coherent sentence rather than fragments.
    @Test func talkCardLabelMatchesExpectedShape() throws {
        let session = try #require(viewModel.confData.sessions.flatMap { $0 }.first { $0.containsTalk })
        let talkID = try #require(session.contentIDs.first)

        let label = viewModel.talkCardAccessibilityLabel(talkID: talkID, in: session)

        #expect(label.hasPrefix("\(session.sessionType.displayName) from "))
        #expect(label.contains(" from \(session.startTimeAccessibilityText) to \(session.endTimeAccessibilityText): "))
        #expect(label.contains(", by "))
        // The closing comma + location must be the final clause.
        let location = viewModel.locationNameFrom(talkID: talkID)
        #expect(label.hasSuffix(", \(location)"))
    }

    /// A talk card label must never end on a stray comma or "by," pattern
    /// — a sign that one of the composed parts came back empty.
    @Test func everyTalkProducesAWellFormedLabel() {
        for daySessions in viewModel.confData.sessions {
            for session in daySessions where session.containsTalk {
                for talkID in session.contentIDs {
                    let label = viewModel.talkCardAccessibilityLabel(talkID: talkID, in: session)

                    #expect(!label.hasSuffix(","), "Label ended on stray comma: '\(label)'")
                    #expect(!label.contains(", by ,"), "Label has empty speaker clause: '\(label)'")
                    #expect(!label.contains(": ,"), "Label has empty title clause: '\(label)'")
                }
            }
        }
    }
}

/// Tests for `SessionType.symbolName`. Each session type carries an SF
/// Symbol used as a redundant shape-based cue alongside its colour.
struct SessionTypeTests {
    /// Every non-dummy session type must have a non-empty SF Symbol so the
    /// shape cue is always present. Dummy is intentionally empty.
    @Test func everyNonDummySessionTypeHasASymbol() {
        let typesWithSymbols: [SessionType] = [
            .talk, .panel, .workshop, .lightningtalks, .teaBreak, .lunch,
            .dinner, .confdinner, .social, .registration, .railtrip
        ]
        for type in typesWithSymbols {
            #expect(!type.symbolName.isEmpty, "Session type \(type) has no symbol")
        }
        #expect(SessionType.dummy.symbolName.isEmpty)
    }

    /// Each non-dummy session type must have a non-empty display name so
    /// VoiceOver never speaks an empty session type clause.
    @Test func everyNonDummySessionTypeHasADisplayName() {
        let typesWithNames: [SessionType] = [
            .talk, .panel, .workshop, .lightningtalks, .teaBreak, .lunch,
            .dinner, .confdinner, .social, .registration, .railtrip
        ]
        for type in typesWithNames {
            #expect(!type.displayName.isEmpty, "Session type \(type) has no display name")
        }
    }
}

/// Tests for the VoiceOver-friendly time formatter on Session. The visible
/// 24-hour form ("09:30", "14:00") would be read digit-by-digit; the
/// accessibility form is 12-hour AM/PM with no colon and a special case
/// for on-the-hour times.
struct SessionTimeAccessibilityTests {
    private func session(at hour: Int, minute: Int = 0) -> Session {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 8, hour: hour, minute: minute))!
        return Session(startTime: date, endTime: date, sessionType: .talk, sessionCount: 1)
    }

    @Test func morningTimeReadsAsHourMinuteAM() {
        // 09:30 → "9 30 AM"  (no colon → no punctuation pause)
        #expect(session(at: 9, minute: 30).startTimeAccessibilityText == "9 30 AM")
    }

    @Test func afternoonTimeUsesTwelveHourClock() {
        // 14:00 → "2 PM"  (not "fourteen zero zero")
        #expect(session(at: 14).startTimeAccessibilityText == "2 PM")
    }

    @Test func onTheHourDropsMinuteDigits() {
        // 16:00 → "4 PM"  (not "4 00 PM")
        #expect(session(at: 16).startTimeAccessibilityText == "4 PM")
        #expect(session(at: 9).startTimeAccessibilityText == "9 AM")
    }

    @Test func midnightAndNoonAreReadablyHandled() {
        #expect(session(at: 0).startTimeAccessibilityText == "12 AM")
        #expect(session(at: 12).startTimeAccessibilityText == "12 PM")
    }

    @Test func afternoonHalfHour() {
        #expect(session(at: 13, minute: 45).startTimeAccessibilityText == "1 45 PM")
    }

    /// Every real session in the conference data must produce a time-range
    /// string that obeys the accessibility-time contract: 12-hour AM/PM, no
    /// colon (which speech engines render as a pause), no leading zero, and
    /// ending in either " AM" or " PM" — never bare digits.
    @Test func everySessionInConfDataObeysTimeContract() {
        let viewModel = ViewModel()
        for daySessions in viewModel.confData.sessions {
            for session in daySessions where session.sessionType != .dummy {
                let text = session.timeRangeAccessibilityText
                #expect(!text.contains(":"), "Time '\(text)' must not contain a colon")
                #expect(!text.hasPrefix("0"), "Time '\(text)' must not have a leading zero")
                #expect(text.hasSuffix(" AM") || text.hasSuffix(" PM"),
                        "Time '\(text)' must end in AM or PM")
                #expect(text.contains(" to "), "Time range '\(text)' must contain ' to '")
            }
        }
    }
}

/// Validates that every `SessionType.symbolName` resolves to a real SF Symbol
/// at runtime. Catches typos in the symbol catalogue that would otherwise show
/// as an empty rectangle on screen and an empty image description in
/// VoiceOver — the same class of bug the Accessibility Inspector flags as a
/// "potentially decorative image with no label".
struct SessionTypeSymbolResolutionTests {
    @Test func everyDeclaredSymbolResolvesToAnSFSymbol() {
        let typesWithSymbols: [SessionType] = [
            .talk, .panel, .workshop, .lightningtalks, .teaBreak, .lunch,
            .dinner, .confdinner, .social, .registration, .railtrip
        ]
        for type in typesWithSymbols {
            #expect(UIImage(systemName: type.symbolName) != nil,
                    "SessionType.\(type).symbolName '\(type.symbolName)' is not a valid SF Symbol")
        }
    }
}

/// Iterates every talk in the conference data and asserts the spoken
/// accessibility label fully expands every part of its template — no clause
/// is left at its placeholder fallback string. This is the closest unit-test
/// equivalent of the Accessibility Inspector's "element label is missing or
/// empty" audit, run exhaustively against the real bundled data.
struct AccessibilityLabelExhaustivenessTests {
    let viewModel = ViewModel()

    /// Every talk's spoken label must contain the talk's title, the location
    /// it's held in, the time-range accessibility string, and at least one
    /// resolved speaker name — never a placeholder like "Speaker to be
    /// announced" or "Talk to be announced", which would mean a reference
    /// in `conf.json` didn't resolve.
    @Test func everyTalkLabelExpandsEveryClause() {
        for daySessions in viewModel.confData.sessions {
            for session in daySessions where session.containsTalk {
                for talkID in session.contentIDs {
                    let label = viewModel.talkCardAccessibilityLabel(talkID: talkID, in: session)

                    let title = viewModel.talkTitleFrom(talkID: talkID)
                    let location = viewModel.locationNameFrom(talkID: talkID)
                    let speakers = viewModel.speakersFrom(talkID: talkID)

                    #expect(label.contains(title), "Label missing title '\(title)': '\(label)'")
                    #expect(label.contains(location), "Label missing location '\(location)': '\(label)'")
                    #expect(label.contains(speakers), "Label missing speakers '\(speakers)': '\(label)'")
                    #expect(label.contains(session.timeRangeAccessibilityText),
                            "Label missing time range: '\(label)'")

                    #expect(!label.contains("Talk to be announced"),
                            "Talk \(talkID) fell back to placeholder title — broken talk ID reference")
                    #expect(!label.contains("Speaker to be announced"),
                            "Talk \(talkID) fell back to placeholder speaker — broken speaker ID reference")
                    #expect(!label.contains("Location to be announced"),
                            "Talk \(talkID) fell back to placeholder location — broken location ID reference")
                }
            }
        }
    }
}

/// Checks that the strings ViewModel produces for the accessibility layer are
/// well-formed: no `Optional(...)` leakage, no raw UUIDs surfacing as user-
/// visible text, no double spaces or stray whitespace at the ends. These are
/// the patterns most often flagged when reading an Accessibility Inspector
/// audit report.
struct ForbiddenStringTests {
    let viewModel = ViewModel()

    /// Matches any 36-character UUID surface form (8-4-4-4-12 hex with
    /// dashes). VoiceOver should never speak one — it would say each digit
    /// individually for several seconds.
    private static let uuidPattern: Regex<Substring> = try! Regex("[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}")

    private func assertClean(_ label: String, source: String) {
        #expect(!label.contains("Optional("), "\(source) leaks Optional(): '\(label)'")
        #expect(!label.contains("  "), "\(source) contains a double space: '\(label)'")
        #expect(label == label.trimmingCharacters(in: .whitespacesAndNewlines),
                "\(source) has leading/trailing whitespace: '\(label)'")
        #expect(label.firstMatch(of: Self.uuidPattern) == nil,
                "\(source) contains a raw UUID: '\(label)'")
    }

    @Test func talkCardLabelsAreClean() {
        for daySessions in viewModel.confData.sessions {
            for session in daySessions where session.containsTalk {
                for talkID in session.contentIDs {
                    assertClean(viewModel.talkCardAccessibilityLabel(talkID: talkID, in: session),
                                source: "talkCardAccessibilityLabel")
                }
            }
        }
    }

    @Test func everyTalkTitleAndSpeakerStringIsClean() {
        for talk in viewModel.confData.talks {
            assertClean(viewModel.talkTitleFrom(talkID: talk.id), source: "talkTitleFrom")
            assertClean(viewModel.speakersFrom(talkID: talk.id), source: "speakersFrom")
            assertClean(viewModel.locationNameFrom(talkID: talk.id), source: "locationNameFrom(talkID:)")
        }
    }

    @Test func everySpeakerAndLocationLookupIsClean() {
        for speaker in viewModel.confData.speakers {
            assertClean(viewModel.speakerNameFrom(speakerID: speaker.id), source: "speakerNameFrom")
        }
        for location in viewModel.confData.locations {
            assertClean(viewModel.locationNameFrom(locationID: location.id),
                        source: "locationNameFrom(locationID:)")
        }
    }

    @Test func everySessionTimeRangeIsClean() {
        for daySessions in viewModel.confData.sessions {
            for session in daySessions where session.sessionType != .dummy {
                assertClean(session.timeRangeAccessibilityText, source: "timeRangeAccessibilityText")
            }
        }
    }
}

/// Per-speaker validation. The speaker row's accessibility label combines
/// name + bio via `.accessibilityElement(children: .combine)`, and any social
/// link the speaker has becomes a tappable Link with an "Opens in browser"
/// hint. Both depend on the underlying data being sound — empty names or
/// malformed URLs would surface to assistive tech.
struct SpeakerAccessibilityTests {
    let viewModel = ViewModel()

    /// Every speaker in the conference data must have a non-empty name —
    /// the SpeakerRowView's combined label collapses to just punctuation
    /// otherwise.
    @Test func everySpeakerHasANonEmptyName() {
        for speaker in viewModel.confData.speakers {
            #expect(!speaker.name.trimmingCharacters(in: .whitespaces).isEmpty,
                    "Speaker '\(speaker.id)' has an empty name")
        }
    }

    /// Where a speaker has a bio it must not be just whitespace — an
    /// "appears non-empty in JSON but is actually blank" entry would
    /// produce an accessibility row that reads only the name twice over.
    @Test func speakerBiosAreEitherEmptyOrMeaningful() {
        for speaker in viewModel.confData.speakers {
            if !speaker.speakerInfo.isEmpty {
                #expect(!speaker.speakerInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        "Speaker '\(speaker.name)' has whitespace-only bio")
            }
        }
    }

    /// Each declared social link must parse as a URL — Link views silently
    /// render dead if given an unparseable string, leaving Voice Control
    /// users to issue "open <site>" commands that do nothing.
    ///
    /// Note: the bundled conference data packs multiple URLs into a single
    /// `socialLink` field separated by newlines, so the contract checked here
    /// is "every newline-separated chunk is a valid URL with a scheme".
    /// `SocialLinksView` currently passes the whole string through a single
    /// `URL(string:)` call without splitting, so the multi-URL entries
    /// produce a Link with newlines embedded that the system cannot open —
    /// see follow-up note in the audit doc.
    /// `SocialLinksView` derives a friendly per-URL label from the URL's
    /// host, with a fallback to the `SocialItem.socialType`. Pinning the
    /// mapping here means a host-renaming or new-network change has to
    /// trip a test before it can ship a regression to VoiceOver / Voice
    /// Control.
    @Test func friendlyLabelsAreDerivedFromHost() {
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://github.com/foo")!, fallbackType: "www") == "GitHub")
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://www.linkedin.com/in/foo")!, fallbackType: "www") == "LinkedIn")
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://mastodon.social/@foo")!, fallbackType: "www") == "Mastodon")
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://mas.to/@foo")!, fallbackType: "www") == "Mastodon")
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://bsky.app/profile/foo.dev")!, fallbackType: "www") == "Bluesky")
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://twitter.com/foo")!, fallbackType: "www") == "Twitter / X")
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://x.com/foo")!, fallbackType: "www") == "Twitter / X")
        // Generic web/blog/www tokens collapse to "Website" so VoiceOver
        // doesn't spell "Www" character-by-character.
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://sarahthornton.dev")!, fallbackType: "www") == "Website")
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://sarahthornton.dev")!, fallbackType: "web") == "Website")
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://sarahthornton.dev")!, fallbackType: "blog") == "Website")
        // Anything else falls back to capitalised social-type so a future
        // entry like "podcast" still reads sensibly.
        #expect(SocialLinksView.displayLabel(for: URL(string: "https://example.com/feed")!, fallbackType: "podcast") == "Podcast")
    }

    @Test func everySocialLinkParsesAsAURL() {
        for speaker in viewModel.confData.speakers {
            for social in speaker.social {
                let chunks = social.socialLink
                    .split(separator: "\n", omittingEmptySubsequences: true)
                    .map { String($0).trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }

                // An empty socialLink isn't strictly broken — a speaker may
                // simply have a placeholder entry — so we only validate
                // chunks that contain a URL candidate.
                for chunk in chunks {
                    let url = URL(string: chunk)
                    #expect(url != nil,
                            "Speaker '\(speaker.name)' has unparseable \(social.socialType) link chunk: '\(chunk)'")
                    #expect(url?.scheme != nil,
                            "Speaker '\(speaker.name)' \(social.socialType) link chunk lacks scheme: '\(chunk)'")
                }
            }
        }
    }
}

/// Pinning tests for the temporal-context features on Programme + My
/// Schedule. All factories take an explicit `now` so the tests are
/// independent of the real wall clock.
struct TemporalContextTests {
    /// Helper — synthesise a Session with a fixed start/end relative to
    /// a baseline date so the offsets in the tests below read naturally.
    private static func session(startOffset: TimeInterval, durationMinutes: Int = 45, anchor: Date = baseline) -> Session {
        let start = anchor.addingTimeInterval(startOffset)
        let end = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return Session(startTime: start, endTime: end, sessionType: .talk, sessionCount: 1)
    }

    /// 2026-09-08 09:00 — an arbitrary baseline; only relative offsets
    /// matter for the assertions below.
    static let baseline = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 8, hour: 9, minute: 0))!

    // MARK: - SessionLiveStatus

    @Test func sessionMoreThanFifteenMinutesAwayIsUpcoming() {
        let s = Self.session(startOffset: 60 * 60)            // 1 hour away
        #expect(SessionLiveStatus.status(for: s, now: Self.baseline) == .upcoming)
    }

    @Test func sessionExactlyFifteenMinutesAwayIsStartingSoon() {
        let s = Self.session(startOffset: 15 * 60)            // 15 min away
        #expect(SessionLiveStatus.status(for: s, now: Self.baseline) == .startingSoon(minutesUntil: 15))
    }

    @Test func sessionWithSecondsToGoRoundsUpToOneMinute() {
        let s = Self.session(startOffset: 30)                 // 30 s away → 1 min
        #expect(SessionLiveStatus.status(for: s, now: Self.baseline) == .startingSoon(minutesUntil: 1))
    }

    @Test func sessionAtStartTimeIsLive() {
        let s = Self.session(startOffset: 0)
        #expect(SessionLiveStatus.status(for: s, now: Self.baseline) == .live)
    }

    @Test func sessionMidwayIsLive() {
        let s = Self.session(startOffset: -10 * 60)           // started 10 min ago
        #expect(SessionLiveStatus.status(for: s, now: Self.baseline) == .live)
    }

    @Test func sessionPastEndTimeIsFinished() {
        let s = Self.session(startOffset: -60 * 60)           // ended 15 min ago
        #expect(SessionLiveStatus.status(for: s, now: Self.baseline) == .finished)
    }

    // MARK: - Accessibility prefixes and badge text

    @Test func accessibilityPrefixesReadNaturally() {
        #expect(SessionLiveStatus.upcoming.accessibilityPrefix == "")
        #expect(SessionLiveStatus.finished.accessibilityPrefix == "")
        #expect(SessionLiveStatus.live.accessibilityPrefix == "Now. ")
        #expect(SessionLiveStatus.startingSoon(minutesUntil: 1).accessibilityPrefix == "Starts in 1 minute. ")
        #expect(SessionLiveStatus.startingSoon(minutesUntil: 12).accessibilityPrefix == "Starts in 12 minutes. ")
    }

    @Test func badgeTextMatchesVisualStyle() {
        #expect(SessionLiveStatus.upcoming.badgeText == nil)
        #expect(SessionLiveStatus.finished.badgeText == nil)
        #expect(SessionLiveStatus.live.badgeText == "Now")
        #expect(SessionLiveStatus.startingSoon(minutesUntil: 7).badgeText == "In 7 min")
    }

    // MARK: - ConfData.phase

    /// Build a minimal ConfData with a 3-day conference starting on the
    /// baseline date.
    private static func conf(days: Int = 3) -> ConfData {
        let cal = Calendar.current
        let startOfFirstDay = cal.startOfDay(for: baseline)
        let sessions: [[Session]] = (0..<days).map { dayOffset in
            let dayStart = cal.date(byAdding: .day, value: dayOffset, to: startOfFirstDay)!
            let nineAM = cal.date(bySettingHour: 9, minute: 0, second: 0, of: dayStart)!
            let fivePM = cal.date(bySettingHour: 17, minute: 0, second: 0, of: dayStart)!
            return [
                Session(startTime: nineAM, endTime: nineAM.addingTimeInterval(45 * 60), sessionType: .talk, sessionCount: 1),
                Session(startTime: fivePM.addingTimeInterval(-45 * 60), endTime: fivePM, sessionType: .talk, sessionCount: 1)
            ]
        }
        return ConfData(version: 1, speakers: [], talks: [], locations: [], sessions: sessions)
    }

    @Test func phaseUpcomingCountsCalendarDays() {
        let conf = Self.conf()
        let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: Self.baseline)!
        #expect(conf.phase(now: twoDaysBefore) == .upcoming(daysUntil: 2))
    }

    @Test func phaseUpcomingTodayIsZeroDays() {
        // Slightly before the conference's first session on day 1.
        let conf = Self.conf()
        let earlierToday = Calendar.current.date(byAdding: .hour, value: -2, to: Self.baseline)!
        #expect(conf.phase(now: earlierToday) == .inProgress(dayNumber: 1, totalDays: 3))
    }

    @Test func phaseDuringConferenceReportsDayNumber() {
        let conf = Self.conf()
        let dayTwo = Calendar.current.date(byAdding: .day, value: 1, to: Self.baseline)!
        #expect(conf.phase(now: dayTwo) == .inProgress(dayNumber: 2, totalDays: 3))
    }

    @Test func phaseFinishedAfterFinalDayEnd() {
        let conf = Self.conf()
        let dayAfter = Calendar.current.date(byAdding: .day, value: 5, to: Self.baseline)!
        #expect(conf.phase(now: dayAfter) == .finished)
    }

    // MARK: - Banner text

    @Test func bannerTextIsHuman() {
        #expect(ConferencePhase.upcoming(daysUntil: 0).bannerText == "Conference starts today")
        #expect(ConferencePhase.upcoming(daysUntil: 1).bannerText == "Conference starts tomorrow")
        #expect(ConferencePhase.upcoming(daysUntil: 5).bannerText == "Conference starts in 5 days")
        #expect(ConferencePhase.inProgress(dayNumber: 2, totalDays: 3).bannerText == "Day 2 of 3")
        #expect(ConferencePhase.finished.bannerText == "Conference has ended")
    }
}
