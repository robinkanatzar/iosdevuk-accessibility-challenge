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
        app.launchArguments = ["-UITestingResetFavourites"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testProgrammeAccessibilityAudit() throws {
        openTab(.programme)
        XCTAssertTrue(app.navigationBars["MythConf 2026"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.segmentedControls["programme.dayPicker"].waitForExistence(timeout: 5))

        try auditVisibleScreen("Programme initial day")

        app.swipeUp()
        try auditVisibleScreen("Programme after first scroll")

        let friday = app.buttons["Fri"]
        if friday.exists {
            friday.tap()
            try auditVisibleScreen("Programme Friday")
        }
    }

    func testSpeakersAccessibilityAudit() throws {
        openTab(.speakers)
        XCTAssertTrue(app.navigationBars["Speakers"].waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "speakers.list").waitForExistence(timeout: 5))

        try auditVisibleScreen("Speakers list", includesContrast: false)

        let speakerName = openFirstSpeaker()

        XCTAssertTrue(app.navigationBars[speakerName].waitForExistence(timeout: 5))
        let sessionsHeading = app.staticTexts["speakerDetail.sessionsHeading"]
        XCTAssertTrue(sessionsHeading.waitForExistence(timeout: 2))
        XCTAssertEqual(sessionsHeading.label, "Sessions by \(speakerName)")
        try auditVisibleScreen("Speaker detail", includesContrast: false)
    }

    func testLocationsAccessibilityAudit() throws {
        openTab(.locations)
        XCTAssertTrue(app.navigationBars["Locations"].waitForExistence(timeout: 5))

        try auditVisibleScreen("Locations list")

        let locationName = openFirstLocation()

        XCTAssertTrue(app.navigationBars[locationName].waitForExistence(timeout: 5))
        XCTAssertTrue(openInMapsElement(for: locationName).waitForExistence(timeout: 5))
        try auditVisibleScreen("Location detail")
    }

    func testMyScheduleAccessibilityAudit() throws {
        openTab(.mySchedule)
        XCTAssertTrue(app.navigationBars["My Schedule"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["No Favourites Yet"].waitForExistence(timeout: 10))
        try auditVisibleScreen("My Schedule empty")
    }

    func testMyScheduleWithFavouriteAccessibilityAudit() throws {
        openTab(.programme)

        let favouriteButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(favouriteButton.waitForExistence(timeout: 5))
        favouriteButton.tap()

        openTab(.mySchedule)
        XCTAssertTrue(app.navigationBars["My Schedule"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["No Favourites Yet"].exists)
        XCTAssertTrue(element(identifier: "mySchedule.schedule").waitForExistence(timeout: 5))
        try auditVisibleScreen("My Schedule populated")
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

    private enum AppTab: String {
        case programme = "Programme"
        case speakers = "Speakers"
        case locations = "Locations"
        case mySchedule = "My Schedule"
    }

    private func openInMapsElement(for locationName: String) -> XCUIElement {
        let label = "Open \(locationName) in Maps"
        let link = app.links[label]
        if link.exists { return link }
        return app.buttons[label]
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

    private func element(identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func auditVisibleScreen(
        _ name: String,
        includesContrast: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        XCTContext.runActivity(named: "Accessibility audit: \(name)") { _ in
            guard #available(iOS 17.0, *) else { return }
            var auditTypes: XCUIAccessibilityAuditType = [
                .elementDetection,
                .hitRegion,
                .sufficientElementDescription,
                .trait
            ]
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
        if issue.auditType == .contrast && issue.compactDescription == "Contrast nearly passed" {
            return true
        }

        return false
    }
}
