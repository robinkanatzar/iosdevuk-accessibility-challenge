//
//  MythConfUITestCase.swift
//  MythConf26UITests
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
class MythConfUITestCase: XCTestCase {
    var app: XCUIApplication!

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

    enum AppTab: String {
        case programme = "Programme"
        case speakers = "Speakers"
        case locations = "Locations"
        case mySchedule = "My Schedule"
    }

    func openInMapsElement() -> XCUIElement {
        app.descendants(matching: .any)["location.openInMaps"]
    }

    func relaunchForTestingDate(_ timestamp: TimeInterval) {
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

    func allowNotificationsIfPrompted(timeout: TimeInterval = 10) {
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

    func openTab(_ tab: AppTab) {
        let button = app.tabBars.buttons[tab.rawValue]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Missing tab: \(tab.rawValue)")
        button.tap()
    }

    @discardableResult
    func openFirstSpeaker() -> String {
        let list = element(identifier: "speakers.list")
        XCTAssertTrue(list.waitForExistence(timeout: 10))

        let firstRow = list.buttons.element(boundBy: 0)
        XCTAssertTrue(firstRow.waitForExistence(timeout: 10))

        // Rows in SpeakersView use SpeakerRowView which combines children.
        // The label will be "Name, Bio excerpt" or just "Name".
        let fullLabel = firstRow.label
        let speakerName = fullLabel.components(separatedBy: ",").first ?? fullLabel

        firstRow.tap()
        return speakerName
    }

    @discardableResult
    func openFirstLocation() -> String {
        let list = element(identifier: "locations.list")
        XCTAssertTrue(list.waitForExistence(timeout: 10))

        let firstRow = list.buttons.element(boundBy: 0)
        XCTAssertTrue(firstRow.waitForExistence(timeout: 10))

        // Rows in LocationsView use a VStack with name and description.
        // accessibilityElement(children: .combine) means the label is "Name, Description".
        let fullLabel = firstRow.label
        let locationName = fullLabel.components(separatedBy: ",").first ?? fullLabel

        firstRow.tap()
        return locationName
    }

    func openSpeaker(named name: String) {
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 10) {
            searchField.tap()
            searchField.typeText(name)
        }

        let speaker = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", name)).firstMatch
        XCTAssertTrue(speaker.waitForExistence(timeout: 10), "Missing speaker: \(name)")
        speaker.tap()
    }

    func openLocation(named name: String) {
        let location = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", name)).firstMatch
        XCTAssertTrue(location.waitForExistence(timeout: 10), "Missing location: \(name)")
        location.tap()
    }

    func firstButton(labelBeginningWith prefix: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    func scrollToButton(label: String, maxSwipes: Int = 4) -> XCUIElement {
        var button = app.buttons[label]
        for _ in 0..<maxSwipes where !button.exists {
            app.swipeUp()
            button = app.buttons[label]
        }
        return button
    }

    func scrollToButton(identifier: String, labels: [String] = [], maxSwipes: Int = 4) -> XCUIElement {
        var button = firstButton(identifier: identifier, labels: labels)
        for _ in 0..<maxSwipes where !button.exists {
            app.swipeUp()
            button = firstButton(identifier: identifier, labels: labels)
        }
        return button
    }

    func firstButton(identifier: String, labels: [String]) -> XCUIElement {
        let identifierMatch = app.descendants(matching: .any)[identifier]
        if identifierMatch.exists {
            return identifierMatch
        }

        for label in labels {
            let labelMatch = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label == %@ AND isHittable == true", label))
                .firstMatch
            if labelMatch.exists {
                return labelMatch
            }
        }

        return identifierMatch
    }

    func scrollToElement(identifier: String, labels: [String] = [], maxSwipes: Int = 6) -> XCUIElement {
        var element = firstElement(identifier: identifier, labels: labels)
        for _ in 0..<maxSwipes where !element.exists {
            app.swipeUp()
            element = firstElement(identifier: identifier, labels: labels)
        }
        return element
    }

    func firstElement(identifier: String, labels: [String]) -> XCUIElement {
        let identifierMatch = app.descendants(matching: .any)[identifier]
        if identifierMatch.exists {
            return identifierMatch
        }

        for label in labels {
            let exactLabelMatch = app.descendants(matching: .any)[label]
            if exactLabelMatch.exists {
                return exactLabelMatch
            }

            let containingLabelMatch = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label CONTAINS %@", label))
                .firstMatch
            if containingLabelMatch.exists {
                return containingLabelMatch
            }
        }

        return identifierMatch
    }

    func firstElement(identifierBeginningWith prefix: String) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", prefix))
            .firstMatch
    }

    func element(identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    func scrollToSwitch(identifier: String, labels: [String] = [], maxSwipes: Int = 4) -> XCUIElement {
        var toggle = firstSwitch(identifier: identifier, labels: labels)
        for _ in 0..<maxSwipes where !toggle.exists {
            app.swipeUp()
            toggle = firstSwitch(identifier: identifier, labels: labels)
        }
        return toggle
    }

    func firstSwitch(identifier: String, labels: [String]) -> XCUIElement {
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

    func assertSwitch(
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

    func isSwitchOn(_ toggle: XCUIElement) -> Bool {
        ["1", "On"].contains(toggle.value as? String ?? "")
    }

    func waitForLabel(
        of element: XCUIElement,
        containing expectedText: String,
        timeout: TimeInterval = 10,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(format: "label CONTAINS %@", expectedText)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(
            result,
            .completed,
            "Expected label to contain \(expectedText), got \(element.label)",
            file: file,
            line: line
        )
    }

    func auditVisibleScreen(
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
//                .dynamicType,
                .textClipped,
                .sufficientElementDescription,
                .elementDetection,
                .hitRegion,
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

    func isKnownFalsePositive(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        // Temporary: print all audit issues to identify the clipped element.
        print("AUDIT ISSUE: \(issue.auditType) | \(issue.compactDescription) | element: \(issue.element?.debugDescription ?? "nil")")

        if issue.auditType == .contrast && issue.compactDescription == "Contrast nearly passed" {
            return true
        }

        // The system UISearchBar "Clear text" button is 20×20pt — below the 44pt
        // minimum. This is a UIKit internal control; the app has no way to resize it.
        // Suppress globally so any screen with an active search field doesn't fail.
        if issue.auditType == .hitRegion && issue.element?.label == "Clear text" {
            return true
        }

                // System UISearchBar search field reports textClipped when focused with
        // text in the field. The app has no control over UISearchBar's internal
        // text layout. Suppress by element type so it covers any screen with
        // an active .searchable modifier, not just Speakers.
        if issue.auditType == .textClipped && issue.element?.elementType == .searchField {
            return true
        }

        return false
    }
}
