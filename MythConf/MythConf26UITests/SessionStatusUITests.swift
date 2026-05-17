//
//  SessionStatusUITests.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
final class SessionStatusUITests: MythConfUITestCase {
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
}
