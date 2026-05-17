//
//  SemanticsUITests.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
final class SemanticsUITests: MythConfUITestCase {
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
}
