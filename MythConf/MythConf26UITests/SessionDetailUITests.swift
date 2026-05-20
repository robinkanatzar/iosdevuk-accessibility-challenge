//
//  SessionDetailUITests.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 17/05/2026.
//

import XCTest

@MainActor
final class SessionDetailUITests: MythConfUITestCase {
    func testSessionDetailUsesAccessibleDetailSections() throws {
        openTab(.programme)

        let sessionCard = firstElement(identifierBeginningWith: "programme.card.")
        XCTAssertTrue(sessionCard.waitForExistence(timeout: 5))
        sessionCard.tap()

        XCTAssertTrue(app.navigationBars["Session Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.title").waitForExistence(timeout: 5))
        let aboutHeading = element(identifier: "sessionDetail.aboutHeading")
        XCTAssertTrue(aboutHeading.waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.location").waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.about").waitForExistence(timeout: 5))
        XCTAssertTrue(element(identifier: "sessionDetail.favouriteAction").waitForExistence(timeout: 5))
    }
}
