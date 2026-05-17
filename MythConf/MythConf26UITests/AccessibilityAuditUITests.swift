//
//  AccessibilityAuditUITests.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
final class AccessibilityAuditUITests: MythConfUITestCase {
    func testProgrammeAccessibilityAudit() throws {
        openTab(.programme)
        XCTAssertTrue(app.navigationBars["MythConf 2026"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.segmentedControls["programme.dayPicker"].waitForExistence(timeout: 5))

        try auditVisibleScreen("Programme initial day", includesContrast: false)

        app.swipeUp()
        try auditVisibleScreen("Programme after first scroll", includesContrast: false)

        let friday = app.buttons["Fri"]
        if friday.exists {
            friday.tap()
            try auditVisibleScreen("Programme Friday", includesContrast: false)
        }
    }

    func testSpeakersAccessibilityAudit() throws {
        openTab(.speakers)
        XCTAssertTrue(app.navigationBars["Speakers"].waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "speakers.list").waitForExistence(timeout: 5))

        try auditVisibleScreen("Speakers list", includesContrast: false)

        let speakerName = openFirstSpeaker()

        XCTAssertTrue(app.navigationBars["Speaker Details"].waitForExistence(timeout: 5))
        let sessionsHeading = app.staticTexts["speakerDetail.sessionsHeading"]
        XCTAssertTrue(sessionsHeading.waitForExistence(timeout: 2))
        XCTAssertEqual(sessionsHeading.label, "Sessions by \(speakerName)")
        try auditVisibleScreen("Speaker detail", includesContrast: false)
    }

    func testLocationsAccessibilityAudit() throws {
        openTab(.locations)
        XCTAssertTrue(app.navigationBars["Locations"].waitForExistence(timeout: 5))

        try auditVisibleScreen("Locations list")

        openFirstLocation()

        XCTAssertTrue(app.navigationBars["Location Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(openInMapsElement().waitForExistence(timeout: 5))
        try auditVisibleScreen("Location detail")
    }

    func testMyScheduleAccessibilityAudit() throws {
        openTab(.mySchedule)
        XCTAssertTrue(app.navigationBars["My Schedule"].waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "mySchedule.empty").waitForExistence(timeout: 10))
        try auditVisibleScreen("My Schedule empty", includesDynamicType: false)
    }

    func testMyScheduleWithFavouriteAccessibilityAudit() throws {
        openTab(.programme)

        let favouriteButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(favouriteButton.waitForExistence(timeout: 5))
        favouriteButton.tap()

        openTab(.mySchedule)
        XCTAssertTrue(app.navigationBars["My Schedule"].waitForExistence(timeout: 5))
        XCTAssertFalse(element(identifier: "mySchedule.empty").exists)

        XCTAssertTrue(element(identifier: "mySchedule.schedule").waitForExistence(timeout: 5))
        try auditVisibleScreen("My Schedule populated", includesContrast: false)
    }

    func testSettingsAccessibilityAudit() throws {
        openTab(.programme)

        let settingsButton = app.buttons["settings.open"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["settings.openDyslexicToggle"].waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToSwitch(identifier: "settings.favouriteHapticsToggle", labels: ["Favourite haptic feedback", "Haptic Feedback"]).exists)
        XCTAssertTrue(scrollToSwitch(identifier: "settings.favouriteSoundsToggle", labels: ["Favourite sound feedback", "Sound Feedback"]).exists)

        try auditVisibleScreen("Settings", includesDynamicType: false)
    }
}
