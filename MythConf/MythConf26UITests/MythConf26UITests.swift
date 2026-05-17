//
//  MythConf26UITests.swift
//  MythConf26UITests
//
//  Created by Byaruhanga Franklin on 09/05/2026.
//

import XCTest

@MainActor
final class MythConf26UITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [
            "-UITesting",
            "-UITestingResetFavourites",
            "-UITestingResetSettings",
            "-UITestingResetNotifications"
        ]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
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
        try auditVisibleScreen("My Schedule empty")
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

    func testFavouriteButtonLabelChangesAfterToggle() throws {
        openTab(.programme)

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        XCTAssertTrue(addButton.label.contains("to favourites"))

        addButton.tap()

        let removeButton = firstButton(labelBeginningWith: "Remove ")
        XCTAssertTrue(removeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(removeButton.label.contains("from favourites"))
    }

    func testSessionDetailUsesAccessibleDetailSections() throws {
        openTab(.programme)

        let sessionCard = firstElement(identifierBeginningWith: "programme.card.")
        XCTAssertTrue(sessionCard.waitForExistence(timeout: 5))
        sessionCard.tap()

        XCTAssertTrue(app.navigationBars["Session Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.title").waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.time").waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.location").waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.about").waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.favouriteAction").waitForExistence(timeout: 5))
    }

    func testVisibleButtonsDoNotRepeatButtonInLabel() throws {
        openTab(.programme)

        for index in 0..<min(app.buttons.count, 20) {
            let button = app.buttons.element(boundBy: index)
            guard button.exists else { continue }
            XCTAssertFalse(
                button.label.lowercased().contains(" button"),
                "Button label should not include its role: \(button.label)"
            )
        }
    }

    func testSpeakerDetailSessionsHeadingIsContextual() throws {
        openTab(.speakers)
        let speakerName = openFirstSpeaker()

        let sessionsHeading = app.staticTexts["speakerDetail.sessionsHeading"]
        XCTAssertTrue(sessionsHeading.waitForExistence(timeout: 5))
        XCTAssertEqual(sessionsHeading.label, "Sessions by \(speakerName)")
    }

    func testOpenDyslexicSettingCanBeToggled() throws {
        openTab(.programme)

        let settingsButton = app.buttons["settings.open"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let toggle = app.switches["settings.openDyslexicToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        assertSwitch(toggle, isOn: false)

        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        assertSwitch(toggle, isOn: true)

        XCTAssertTrue(element(identifier: "settings.openDyslexicPreview").exists)

        let doneButton = app.buttons["settings.done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()
    }

    func testFavouriteFeedbackSettingsCanBeToggled() throws {
        openTab(.programme)

        let settingsButton = app.buttons["settings.open"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let hapticsToggle = scrollToSwitch(identifier: "settings.favouriteHapticsToggle", labels: ["Favourite haptic feedback", "Haptic Feedback"])
        XCTAssertTrue(hapticsToggle.exists)
        assertSwitch(hapticsToggle, isOn: true)

        hapticsToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        assertSwitch(hapticsToggle, isOn: false)

        let soundsToggle = scrollToSwitch(identifier: "settings.favouriteSoundsToggle", labels: ["Favourite sound feedback", "Sound Feedback"])
        XCTAssertTrue(soundsToggle.exists)
        assertSwitch(soundsToggle, isOn: true)

        soundsToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        assertSwitch(soundsToggle, isOn: false)
    }

    private enum AppTab: String {
        case programme = "Programme"
        case speakers = "Speakers"
        case locations = "Locations"
        case mySchedule = "My Schedule"
    }

    private func openInMapsElement() -> XCUIElement {
        app.descendants(matching: .any)["location.openInMaps"]
    }

    private func relaunchForTestingDate(_ timestamp: TimeInterval) {
        app.terminate()
        app = XCUIApplication()
        app.launchArguments = [
            "-UITesting",
            "-UITestingResetFavourites",
            "-UITestingResetSettings",
            "-UITestingResetNotifications",
            "-TestingDate",
            String(timestamp)
        ]
        app.launch()
    }

    private func allowNotificationsIfPrompted(timeout: TimeInterval = 5) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowLabels = ["Allow", "Allow Notifications"]

        for label in allowLabels {
            let allowButton = springboard.buttons[label]
            if allowButton.waitForExistence(timeout: timeout) {
                allowButton.tap()
                return
            }
        }
    }

    private func openTab(_ tab: AppTab) {
        let button = app.tabBars.buttons[tab.rawValue]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Missing tab: \(tab.rawValue)")
        button.tap()
    }

    @discardableResult
    private func openFirstSpeaker() -> String {
        let list = element(identifier: "speakers.list")
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        
        let firstRow = list.buttons.element(boundBy: 0)
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        
        // Rows in SpeakersView use SpeakerRowView which combines children.
        // The label will be "Name, Bio excerpt" or just "Name".
        let fullLabel = firstRow.label
        let speakerName = fullLabel.components(separatedBy: ",").first ?? fullLabel
        
        firstRow.tap()
        return speakerName
    }

    @discardableResult
    private func openFirstLocation() -> String {
        let list = element(identifier: "locations.list")
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        
        let firstRow = list.buttons.element(boundBy: 0)
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        
        // Rows in LocationsView use a VStack with name and description.
        // accessibilityElement(children: .combine) means the label is "Name, Description".
        let fullLabel = firstRow.label
        let locationName = fullLabel.components(separatedBy: ",").first ?? fullLabel
        
        firstRow.tap()
        return locationName
    }

    private func openSpeaker(named name: String) {
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 5) {
            searchField.tap()
            searchField.typeText(name)
        }

        let speaker = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", name)).firstMatch
        XCTAssertTrue(speaker.waitForExistence(timeout: 5), "Missing speaker: \(name)")
        speaker.tap()
    }

    private func openLocation(named name: String) {
        let location = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", name)).firstMatch
        XCTAssertTrue(location.waitForExistence(timeout: 5), "Missing location: \(name)")
        location.tap()
    }

    private func firstButton(labelBeginningWith prefix: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    private func firstElement(identifierBeginningWith prefix: String) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
            .firstMatch
    }

    private func element(identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func scrollToSwitch(identifier: String, labels: [String] = [], maxSwipes: Int = 4) -> XCUIElement {
        let toggle = firstSwitch(identifier: identifier, labels: labels)
        for _ in 0..<maxSwipes where !toggle.exists {
            app.swipeUp()
        }
        return firstSwitch(identifier: identifier, labels: labels)
    }

    private func firstSwitch(identifier: String, labels: [String]) -> XCUIElement {
        let identifierMatch = app.switches[identifier]
        if identifierMatch.exists {
            return identifierMatch
        }

        for label in labels {
            let labelMatch = app.switches[label]
            if labelMatch.exists {
                return labelMatch
            }
        }

        return identifierMatch
    }

    private func assertSwitch(
        _ toggle: XCUIElement,
        isOn expectedIsOn: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectedValues = expectedIsOn ? ["1", "On"] : ["0", "Off"]
        let actualValue = toggle.value as? String ?? ""
        XCTAssertTrue(
            expectedValues.contains(actualValue),
            "Expected switch to be \(expectedIsOn ? "on" : "off"), got \(String(describing: toggle.value))",
            file: file,
            line: line
        )
    }

    private func waitForLabel(
        of element: XCUIElement,
        containing expectedText: String,
        timeout: TimeInterval = 10,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(format: "label CONTAINS %@", expectedText)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Expected label to contain \(expectedText), got \(element.label)", file: file, line: line)
    }

    private func auditVisibleScreen(
        _ name: String,
        includesContrast: Bool = true,
        includesDynamicType: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        XCTContext.runActivity(named: "Accessibility audit: \(name)") { _ in
            guard #available(iOS 17.0, *) else { return }
            var auditTypes: XCUIAccessibilityAuditType = [
//                .contrast,
                .textClipped,
                .elementDetection,
                .hitRegion,
                .sufficientElementDescription,
                .trait
            ]
            if includesDynamicType {
                auditTypes.insert(.dynamicType)
            }
            if includesContrast {
                auditTypes.insert(.contrast)
            }

            do {
                try self.app.performAccessibilityAudit(for: auditTypes) { issue in
                    self.isKnownFalsePositive(issue)
                }
            } catch {
                XCTFail("Accessibility audit failed for \(name): \(error)", file: file, line: line)
            }
        }
    }

    private func isKnownFalsePositive(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        // Temporary: print all audit issues to identify the clipped element
         print("AUDIT ISSUE: \(issue.auditType) | \(issue.compactDescription) | element: \(issue.element?.debugDescription ?? "nil")")

        if issue.auditType == .contrast && issue.compactDescription == "Contrast nearly passed" {
            return true
        }

        return false
    }
}
