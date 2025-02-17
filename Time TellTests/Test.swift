//
//  Test.swift
//  Time TellTests
//
//  Created by Pieter Yoshua Natanael on 15/02/25.
//


import Testing
@testable import Time_Tell // Replace with your app's module name

struct TimeTellTests {
    
    @Test func testTimerStopsAfterOneHour() async throws {
        await MainActor.run {
            // Arrange
            let timerManager = TimerManager()
            timerManager.startTimer()
            
            // Simulate 1 hour passing
            timerManager.updateTime(totalSeconds: 60 * 60)
            
            // Assert
            #expect(timerManager.isTimerRunning == false, "Timer should stop after 1 hour")
        }
    }
    
    
    @Test func testTimerStartsCorrectly() async throws {
        // Arrange
        let timerManager = TimerManager()
        
        // Act
        timerManager.startTimer()
        
        // Assert
        #expect(timerManager.isTimerRunning == true, "Timer should be running after starting")
    }
    
    @Test func testTimerPausesCorrectly() async throws {
        // Arrange
        let timerManager = TimerManager()
        timerManager.startTimer()
        
        // Act
        timerManager.pauseTimer()
        
        // Assert
        #expect(timerManager.isTimerRunning == false, "Timer should be paused")
    }
    
    @Test func testTimerResetsCorrectly() async throws {
        // Arrange
        let timerManager = TimerManager()
        timerManager.startTimer()
        timerManager.updateTime(totalSeconds: 45) // Simulate 45 seconds passing
        
        // Act
        timerManager.resetTimer()
        
        // Assert
        #expect(timerManager.minutes == 0, "Minutes should reset to 0")
        #expect(timerManager.seconds == 0, "Seconds should reset to 0")
        #expect(timerManager.isTimerRunning == false, "Timer should not be running after reset")
    }
}
