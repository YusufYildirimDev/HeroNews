//
//  HeroNewsUITests.swift
//  HeroNewsUITests
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import XCTest

final class HeroNewsUITests: XCTestCase {

    func testAppLaunchAndTitleVisible() throws {
        let app = XCUIApplication()
        app.launch()
        
        let navBarTitle = app.navigationBars["Startup Heroes News"]
        
        let exists = navBarTitle.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "Uygulama açıldığında ana başlık görünmelidir.")
    }
}
