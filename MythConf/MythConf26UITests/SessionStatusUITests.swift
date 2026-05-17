//
//  SessionStatusUITests.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
final class SessionStatusUITests: MythConfUITestCase {
    func testLiveSessionStatusUsesLiveLabel() throws {
        // First bundled workshop starts at 841582800. This sets the app clock during that slot.
        relaunchForTestingDate(841582860)
        openTab(.programme)

        XCTAssertTrue(app.staticTexts["Live"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Live Now"].exists)
    }

    func testSessionStatusShowsPreciseCountdownNearStartTime() throws {
        // First bundled workshop starts at 841582800. This sets the app clock to 8 minutes before.
        relaunchForTestingDate(841582320)
        openTab(.programme)

        let countdown = app.staticTexts["Starting in 8 minutes"]
        XCTAssertTrue(countdown.waitForExistence(timeout: 5))
    }

    func testSessionStatusBadgeIsHiddenUntilTwentyMinutesBeforeStart() throws {
        // First bundled workshop starts at 841582800. This sets the app clock to 30 minutes before.
        relaunchForTestingDate(841581000)
        openTab(.programme)

        XCTAssertFalse(app.staticTexts["Starting Soon"].waitForExistence(timeout: 2))
    }

    func testSessionStatusShowsStartingSoonBeforeCountdownWindow() throws {
        // First bundled workshop starts at 841582800. This sets the app clock to 18 minutes before.
        relaunchForTestingDate(841581720)
        openTab(.programme)

        let startingSoon = app.staticTexts["Starting Soon"]
        XCTAssertTrue(startingSoon.waitForExistence(timeout: 5))
    }

    func testSessionStatusRefreshesAsInjectedTimeAdvances() throws {
        // First bundled workshop starts at 841582800. This starts 2 seconds before the session goes live.
        relaunchForTestingDate(841582798)
        openTab(.programme)

        XCTAssertTrue(app.staticTexts["Live"].waitForExistence(timeout: 10))
    }

    func testProgrammeShowsNowAndNextRowBadges() throws {
        relaunchForTestingDate(841582860)
        openTab(.programme)

        let nowBadge = element(identifier: "schedule.position.now")
        XCTAssertTrue(nowBadge.waitForExistence(timeout: 5))

        let nextBadge = element(identifier: "schedule.position.next")
        XCTAssertTrue(nextBadge.waitForExistence(timeout: 5))

        let nowAccessibilityValue = app.descendants(matching: .any)
            .matching(NSPredicate(format: "value CONTAINS %@", "Now, Live"))
            .firstMatch
        XCTAssertTrue(nowAccessibilityValue.waitForExistence(timeout: 5))

        let nextAccessibilityValue = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", "Next", "Next"))
            .firstMatch
        XCTAssertTrue(nextAccessibilityValue.waitForExistence(timeout: 5))
    }

    func testProgrammeDoesNotShowNextWithoutNow() throws {
        // First bundled workshop starts at 841582800. This sets the app clock to 30 minutes before.
        relaunchForTestingDate(841581000)
        openTab(.programme)

        XCTAssertFalse(element(identifier: "schedule.position.now").waitForExistence(timeout: 2))
        XCTAssertFalse(element(identifier: "schedule.position.next").exists)
    }
}
