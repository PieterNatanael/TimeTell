//
//  TimeTellTestsV2.swift
//  Time TellTests
//
//  Created by Pieter Yoshua Natanael on 15/02/25.
//

import XCTest
@testable import Time_Tell

final class TimeTellTestsV2: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //GWT pattern
//    
//    1️⃣ Given-When-Then (GWT) – Similar to AAA but More Descriptive
//    This pattern is common in behavior-driven development (BDD) and is useful for writing tests in a human-readable way.
//
//    Given – Set up the initial state.
//    When – Perform the action under test.
//    Then – Check the expected outcome.
//        
        
    func testTimerStopsAfterOneHour() {
        // Given: A timer that has started
        let timerManager = TimerManager()
        timerManager.startTimer()

        // When: 1 hour passes
        timerManager.updateTime(totalSeconds: 60 * 60)

        // Then: The timer should stop
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should stop after 1 hour")
    }

    
    //AAA pattern
//    Arrange-Act-Assert (AAA) pattern is a common structure used to organize test cases clearly and effectively.
//    Why Use AAA?
//    ✅ Keeps tests organized and readable
//    ✅ Makes debugging easier
//    ✅ Helps ensure tests remain focused on one behavior



    func testTimerStartsCorrectly() {
          // Arrange
          let timerManager = TimerManager()
          
          // Act
          timerManager.startTimer()
          
          // Assert
          XCTAssertTrue(timerManager.isTimerRunning, "Timer should be running after starting")
      }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
