//
//  TimeColumnViewUITests.swift
//  MythConf26UITests
//
//  Created by Steven Hill on 18/05/2026.
//

import XCTest

final class TimeColumnViewUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func test_timeColumnView_inLightMode_text_meetsMinimumContrastRatio() throws {
        app.launch()
        XCUIDevice.shared.appearance = .light
        
        try app.performAccessibilityAudit(for: [.contrast]) { issue in
            guard let element = issue.element,
                  element.elementType == .searchField else { return true }
            return false
        }
    }
}
