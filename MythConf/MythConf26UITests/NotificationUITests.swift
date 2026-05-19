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
        // First workshop starts at 841582800. The 10-minute reminder trigger is 841582200.
        // Start 10 minutes before the trigger so slow launches do not miss the scheduling window.
        relaunchForTestingDate(841581600)
        openTab(.programme)

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        allowNotificationsIfPrompted()

        let removeButton = firstButton(labelBeginningWith: "Remove ")
        XCTAssertTrue(removeButton.waitForExistence(timeout: 10))
    }

    func testFavouritingSchedulesTenMinuteLocalNotification() throws {
        // First workshop starts at 841582800. The 10-minute reminder trigger is 841582200.
        // Start 10 minutes before the trigger so slow launches do not miss the scheduling window.
        relaunchForTestingDate(841581600)
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
        relaunchForTestingDate(841581600)
        openTab(.programme)

        app.buttons["settings.open"].tap()
        selectReminderTiming("Off")
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
        // First workshop starts at 841582800. The 5-minute reminder trigger is 841582500.
        // Start 5 minutes before the trigger so slow launches do not miss the scheduling window.
        relaunchForTestingDate(841582200)
        openTab(.programme)

        app.buttons["settings.open"].tap()
        selectReminderTiming("5 minutes")
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

    private func selectReminderTiming(_ label: String) {
        let reminderMenu = scrollToElement(
            identifier: "settings.favouriteReminderTimingPicker",
            labels: ["Favourite reminder timing", "Reminder Timing"]
        )
        XCTAssertTrue(reminderMenu.waitForExistence(timeout: 5))
        reminderMenu.tap()

        let option = app.buttons[label]
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
    }
}
