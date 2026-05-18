//
//  NotificationUITests.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
final class NotificationUITests: MythConfUITestCase {
    func testFavouritingNearReminderTimeRequestsNotificationPermission() throws {
        // First workshop starts at 841582800. The reminder trigger is 10 minutes earlier: 841582200.
        relaunchForTestingDate(841582080)
        openTab(.programme)

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        allowNotificationsIfPrompted()

        let removeButton = firstButton(labelBeginningWith: "Remove ")
        XCTAssertTrue(removeButton.waitForExistence(timeout: 10))
    }

    func testFavouritingSchedulesTenMinuteLocalNotification() throws {
        // First workshop starts at 841582800. The reminder trigger is 10 minutes earlier: 841582200.
        relaunchForTestingDate(841582080)
        openTab(.programme)

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        allowNotificationsIfPrompted()

        let summary = element(identifier: "debug.pendingReminderSummary")
        XCTAssertTrue(summary.waitForExistence(timeout: 10))
        waitForLabel(of: summary, containing: "1 pending reminder")
        XCTAssertTrue(summary.label.contains("Session Starting Soon"), summary.label)
        XCTAssertTrue(summary.label.contains("starting in 10 minutes"), summary.label)
    }

    func testFavouritingPastSessionDoesNotScheduleNotification() throws {
        // Friday 09:35. Thursday workshop and its 10-minute reminder are already in the past.
        relaunchForTestingDate(841646100)
        openTab(.programme)

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        allowNotificationsIfPrompted()

        let summary = element(identifier: "debug.pendingReminderSummary")
        XCTAssertTrue(summary.waitForExistence(timeout: 10))
        waitForLabel(of: summary, containing: "No pending reminders")
    }

    func testReminderTimingOffDoesNotScheduleNotification() throws {
        relaunchForTestingDate(841582080)
        openTab(.programme)

        app.buttons["settings.open"].tap()
        let offOption = scrollToButton(label: "Off")
        XCTAssertTrue(offOption.waitForExistence(timeout: 5))
        offOption.tap()
        app.buttons["settings.done"].tap()

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        allowNotificationsIfPrompted()

        let summary = element(identifier: "debug.pendingReminderSummary")
        XCTAssertTrue(summary.waitForExistence(timeout: 10))
        waitForLabel(of: summary, containing: "No pending reminders")
    }

    func testFavouritingSchedulesFiveMinuteLocalNotification() throws {
        // First workshop starts at 841582800. This sets the app clock 7 minutes before start,
        // so a 5-minute reminder is 2 minutes away and should be scheduled.
        relaunchForTestingDate(841582380)
        openTab(.programme)

        app.buttons["settings.open"].tap()
        let fiveMinutesOption = scrollToButton(label: "5 minutes")
        XCTAssertTrue(fiveMinutesOption.waitForExistence(timeout: 5))
        fiveMinutesOption.tap()
        app.buttons["settings.done"].tap()

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        allowNotificationsIfPrompted()

        let summary = element(identifier: "debug.pendingReminderSummary")
        XCTAssertTrue(summary.waitForExistence(timeout: 10))
        waitForLabel(of: summary, containing: "1 pending reminder")
        XCTAssertTrue(summary.label.contains("starting in 5 minutes"), summary.label)
    }
}
