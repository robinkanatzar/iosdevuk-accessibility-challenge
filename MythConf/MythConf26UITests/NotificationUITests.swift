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
}
