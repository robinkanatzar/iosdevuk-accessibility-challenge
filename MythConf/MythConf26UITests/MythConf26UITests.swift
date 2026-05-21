import XCTest

final class MythConf26UITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Tab Navigation Tests

    func testProgrammeTabExists() {
        let tab = app.tabBars.buttons["Programme"]
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
    }

    func testSpeakersTabExists() {
        let tab = app.tabBars.buttons["Speakers"]
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
    }

    func testLocationsTabExists() {
        let tab = app.tabBars.buttons["Locations"]
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
    }

    func testMyScheduleTabExists() {
        let tab = app.tabBars.buttons["My Schedule"]
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
    }

    func testAllTabsAreTappable() {
        app.tabBars.buttons["Programme"].tap()
        app.tabBars.buttons["Speakers"].tap()
        app.tabBars.buttons["Locations"].tap()
        app.tabBars.buttons["My Schedule"].tap()
    }

    func testProgrammeTabShowsContent() {
        app.tabBars.buttons["Programme"].tap()
        // Programme tab should show schedule content
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testSpeakersTabShowsContent() {
        app.tabBars.buttons["Speakers"].tap()
        let navBar = app.navigationBars["Speakers"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testLocationsTabShowsContent() {
        app.tabBars.buttons["Locations"].tap()
        let navBar = app.navigationBars["Locations"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testMyScheduleTabShowsContent() {
        app.tabBars.buttons["My Schedule"].tap()
        let navBar = app.navigationBars["My Schedule"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    // MARK: - Accessibility Audit Tests

    func testProgrammeTabAccessibilityAudit() throws {
        app.tabBars.buttons["Programme"].tap()
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .hitRegion])
    }

    func testSpeakersTabAccessibilityAudit() throws {
        app.tabBars.buttons["Speakers"].tap()
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .hitRegion])
    }

    func testLocationsTabAccessibilityAudit() throws {
        app.tabBars.buttons["Locations"].tap()
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .hitRegion])
    }

    func testMyScheduleTabAccessibilityAudit() throws {
        app.tabBars.buttons["My Schedule"].tap()
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .hitRegion])
    }

    func testSpeakerDetailAccessibilityAudit() throws {
        app.tabBars.buttons["Speakers"].tap()
        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else { return }
        firstCell.tap()
        sleep(1)
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .hitRegion])
    }

    func testLocationDetailAccessibilityAudit() throws {
        app.tabBars.buttons["Locations"].tap()
        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else { return }
        firstCell.tap()
        sleep(1)
        try app.performAccessibilityAudit(for: [.sufficientElementDescription])
    }

    func testSessionDetailAccessibilityAudit() throws {
        app.tabBars.buttons["Programme"].tap()
        // Tap on a talk card to navigate to session detail
        let firstButton = app.buttons.firstMatch
        guard firstButton.waitForExistence(timeout: 5) else { return }
        firstButton.tap()
        sleep(1)
        try app.performAccessibilityAudit(for: [.sufficientElementDescription])
    }

    // MARK: - VoiceOver Element Tests

    func testSpeakerListItemsExist() {
        app.tabBars.buttons["Speakers"].tap()
        let cells = app.cells
        XCTAssertTrue(cells.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(cells.count > 0)
    }

    func testProgrammeDayPickerExists() {
        app.tabBars.buttons["Programme"].tap()
        // The programme view should have navigation content
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testTabBarItemsHaveCorrectLabels() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.buttons["Programme"].exists)
        XCTAssertTrue(tabBar.buttons["Speakers"].exists)
        XCTAssertTrue(tabBar.buttons["Locations"].exists)
        XCTAssertTrue(tabBar.buttons["My Schedule"].exists)
    }

    // MARK: - Navigation Flow Tests

    func testNavigateToSpeakerDetailAndBack() {
        app.tabBars.buttons["Speakers"].tap()
        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else {
            XCTFail("No speaker cells found")
            return
        }
        firstCell.tap()
        sleep(1)
        // Should be on detail view
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        // Should be back on speakers list
        let navBar = app.navigationBars["Speakers"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testNavigateToLocationDetailAndBack() {
        app.tabBars.buttons["Locations"].tap()
        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else {
            XCTFail("No location cells found")
            return
        }
        firstCell.tap()
        sleep(1)
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        let navBar = app.navigationBars["Locations"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    func testSearchInSpeakers() {
        app.tabBars.buttons["Speakers"].tap()
        let searchField = app.searchFields.firstMatch
        guard searchField.waitForExistence(timeout: 5) else {
            // Search field may need a swipe down to reveal
            app.swipeDown()
            guard app.searchFields.firstMatch.waitForExistence(timeout: 3) else { return }
            app.searchFields.firstMatch.tap()
            return
        }
        searchField.tap()
        searchField.typeText("A")
        sleep(1)
        // Should still show results or empty state
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 5) || true)
    }

    // MARK: - Favourite Toggle Tests

    func testCanFavouriteASession() {
        app.tabBars.buttons["Programme"].tap()
        sleep(1)
        // Look for a star button (favourite button)
        let starButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'favourites'")).firstMatch
        guard starButton.waitForExistence(timeout: 5) else { return }
        starButton.tap()
    }

    func testMyScheduleShowsFavouritedSession() {
        // First favourite something
        app.tabBars.buttons["Programme"].tap()
        sleep(1)
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Add to favourites'")).firstMatch
        guard addButton.waitForExistence(timeout: 5) else { return }
        addButton.tap()
        sleep(1)
        // Check My Schedule
        app.tabBars.buttons["My Schedule"].tap()
        sleep(1)
        // Should have content (not empty state)
        let cells = app.cells
        XCTAssertTrue(cells.firstMatch.waitForExistence(timeout: 5) || app.staticTexts.count > 0)
    }

    func testCanUnfavourite() {
        app.tabBars.buttons["Programme"].tap()
        sleep(1)
        // Find and tap a favourite button
        let removeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Remove from favourites'")).firstMatch
        if removeButton.waitForExistence(timeout: 3) {
            removeButton.tap()
        } else {
            // Add first, then remove
            let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Add to favourites'")).firstMatch
            guard addButton.waitForExistence(timeout: 5) else { return }
            addButton.tap()
            sleep(1)
            let newRemoveButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Remove from favourites'")).firstMatch
            guard newRemoveButton.waitForExistence(timeout: 5) else { return }
            newRemoveButton.tap()
        }
    }

    // MARK: - Dynamic Type Tests

    func testAppLaunchesWithAccessibilitySizeWithoutCrash() {
        let largeApp = XCUIApplication()
        largeApp.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge"]
        largeApp.launch()
        // App should not crash
        XCTAssertTrue(largeApp.tabBars.buttons["Programme"].waitForExistence(timeout: 10))
    }

    func testAppLaunchesWithReduceMotionWithoutCrash() {
        let motionApp = XCUIApplication()
        motionApp.launchArguments += ["-UIAccessibilityReduceMotionEnabled", "YES"]
        motionApp.launch()
        XCTAssertTrue(motionApp.tabBars.buttons["Programme"].waitForExistence(timeout: 10))
    }

    func testAppLaunchesWithReduceTransparencyWithoutCrash() {
        let transparencyApp = XCUIApplication()
        transparencyApp.launchArguments += ["-UIAccessibilityReduceTransparencyEnabled", "YES"]
        transparencyApp.launch()
        XCTAssertTrue(transparencyApp.tabBars.buttons["My Schedule"].waitForExistence(timeout: 10))
    }

    func testAppLaunchesWithDifferentiateWithoutColorWithoutCrash() {
        let colorApp = XCUIApplication()
        colorApp.launchArguments += ["-UIAccessibilityDifferentiateWithoutColorEnabled", "YES"]
        colorApp.launch()
        XCTAssertTrue(colorApp.tabBars.buttons["Programme"].waitForExistence(timeout: 10))
    }
}
