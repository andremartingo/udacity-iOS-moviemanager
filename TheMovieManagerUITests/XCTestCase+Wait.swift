import XCTest


enum TestConstants {
    
    enum Timeout {
        
        static let short = 5.0
        static let normal = 10.0
        static let long = 20.0
    }
    
    enum Conditions {
        
        static let selected = "selected"
        static let exists = "exists"
    }
}

extension XCTestCase {
    
    func waitForElementsWithValues(_ values: String ... , from query: XCUIElementQuery) {
        
        values.forEach { self.waitFor(element: query[$0]) }
    }
    
    func waitForElements(_ elements: XCUIElement ...) {
        
        elements.forEach { self.waitFor(element: $0) }
    }
    
    /**
     * Based on: https://github.com/joemasilotti/JAMTestHelper
     *
     * Adds a few methods to XCTest geared towards UI Testing in Xcode 7 and iOS 9. Import this extension into your UI Testing tests to wait for elements and
     * activity items to appear or dissappear.
     *
     * @note The default timeout is ten seconds.
     */
    func waitFor(element: XCUIElement,
                 condition: String = TestConstants.Conditions.exists,
                 truth: Bool = true,
                 timeout: Double = TestConstants.Timeout.normal,
                 file: String = #file,
                 line: Int = #line) {
        
        let predicate = NSPredicate(format: condition + " == " + truth.description)
        let expec = expectation(for: predicate, evaluatedWith: element, handler: nil)
        
        let result = XCTWaiter().wait(for: [expec], timeout: timeout)
        
        if result == .timedOut {
            
            XCTFail("Can't find \(element) in \(timeout) seconds. Condition: \(condition).File: \(file). Line: \(line)")
        }
    }
}

