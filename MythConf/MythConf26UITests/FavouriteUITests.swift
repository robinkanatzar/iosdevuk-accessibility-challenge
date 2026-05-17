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
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        XCTAssertTrue(addButton.label.contains("to favourites"))

        addButton.tap()

        let removeButton = firstButton(labelBeginningWith: "Remove ")
        XCTAssertTrue(removeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(removeButton.label.contains("from favourites"))
    }
}
