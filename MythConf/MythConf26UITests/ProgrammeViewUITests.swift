//
//  ProgrammeViewUITests.swift
//  MythConf26UITests
//
//  Created by Steven Hill on 18/05/2026.
//

import XCTest

final class ProgrammeViewUITests: XCTestCase {
        
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
    }
    
    func test_programmeView_text_meetsMinimumContrastRatio() throws {
        let lightModeApp = XCUIApplication()
        lightModeApp.launch()
        try lightModeApp.performAccessibilityAudit(for: .contrast)
            
        let darkModeApp = XCUIApplication()
        darkModeApp.launchArguments = [LaunchArguments.darkModeUITests]
        darkModeApp.launch()
        try darkModeApp.performAccessibilityAudit(for: .contrast)
    }
}
