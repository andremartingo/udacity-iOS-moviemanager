//
//  TheMovieManagerUITests.swift
//  TheMovieManagerUITests
//
//  Created by André Martingo on 09/06/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import XCTest

class TheMovieManagerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnsureAuthenticateButtonIsHittable() {
        let app = XCUIApplication()
        
        XCTAssert(app.buttons["Authenticate with TheMovieDB"].isHittable)
    }
    
    func testEnsureAllowButtonIsHittable() {
        let app = XCUIApplication()

        app.buttons["Authenticate with TheMovieDB"].tap()

        XCTestCase().waitFor(element: app.webViews/*@START_MENU_TOKEN@*/.buttons["Allow"]/*[[".otherElements[\"Authenticate Udacity? — The Movie Database (TMDb)\"]",".otherElements[\"main\"].buttons[\"Allow\"]",".buttons[\"Allow\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/)
    }
    
}
