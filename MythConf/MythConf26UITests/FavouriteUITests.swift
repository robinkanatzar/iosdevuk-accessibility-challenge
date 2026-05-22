//
//  FavouriteUITests.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
final class FavouriteUITests: MythConfUITestCase {
    func testFavouriteButtonLabelChangesAfterToggle() throws {
        openTab(.programme)

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 10))
        XCTAssertTrue(addButton.label.contains("to favourites"))

        addButton.tap()

        let removeButton = firstButton(labelBeginningWith: "Remove ")
        XCTAssertTrue(removeButton.waitForExistence(timeout: 10))
        XCTAssertTrue(removeButton.label.contains("from favourites"))
    }

    func testFavouriteToggleWorksWhenSoundAndHapticsAreDisabled() throws {
        openTab(.programme)

        app.buttons["settings.open"].tap()

        let hapticsToggle = scrollToSwitch(identifier: "settings.favouriteHapticsToggle", labels: ["Favourite haptic feedback", "Haptic Feedback"])
        XCTAssertTrue(hapticsToggle.exists)
        if isSwitchOn(hapticsToggle) {
            hapticsToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        }

        let soundsToggle = scrollToSwitch(identifier: "settings.favouriteSoundsToggle", labels: ["Favourite sound feedback", "Sound Feedback"])
        XCTAssertTrue(soundsToggle.exists)
        if isSwitchOn(soundsToggle) {
            soundsToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        }

        app.buttons["settings.done"].tap()

        let addButton = firstButton(labelBeginningWith: "Add ")
        XCTAssertTrue(addButton.waitForExistence(timeout: 10))
        addButton.tap()

        let removeButton = firstButton(labelBeginningWith: "Remove ")
        XCTAssertTrue(removeButton.waitForExistence(timeout: 10))
    }
}
