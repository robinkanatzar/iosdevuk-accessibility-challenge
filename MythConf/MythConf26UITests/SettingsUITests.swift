//
//  SettingsUITests.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
final class SettingsUITests: MythConfUITestCase {
    func testSettingsButtonIsAvailableAfterClosingSettings() throws {
        openTab(.programme)

        let settingsButton = app.buttons["settings.open"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let doneButton = app.buttons["settings.done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        XCTAssertTrue(settingsButton.isHittable)
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

    func testFavouriteReminderTimingCanBeChanged() throws {
        openTab(.programme)

        let settingsButton = app.buttons["settings.open"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let offOption = scrollToButton(label: "Off")
        XCTAssertTrue(offOption.waitForExistence(timeout: 5))
        offOption.tap()

        let fiveMinutesOption = scrollToButton(label: "5 minutes")
        XCTAssertTrue(fiveMinutesOption.waitForExistence(timeout: 5))
        fiveMinutesOption.tap()
    }
}
