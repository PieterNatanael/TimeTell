//
//  ContentView.swift
//  TimeTalk
//
//  Created by Pieter Yoshua Natanael on 07/03/24.
//


import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var timerManager = TimerManager()
    @State private var showAdsAndAppFunctionality: Bool = false
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                Text(String(format: "%02d:%02d", timerManager.minutes, timerManager.seconds))
                    .font(.system(size: 99))
                    .padding()
                VStack {
                    TimerButton(label: timerManager.isTimerRunning ? "Pause" : "Start", action: timerManager.isTimerRunning ? timerManager.pauseTimer : timerManager.startTimer)
                    TimerButton(label: "Reset", action: timerManager.resetTimer)
                }
                Spacer()
            }
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
        }
    }
}

// MARK: - Reusable Components
@ViewBuilder
private func TimerButton(label: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(label)
            .font(.title)
            .padding()
            .frame(width: 233)
            .foregroundColor(label == "Reset" ? .white : .black)
            .background(label == "Reset" ? Color.blue : Color.white)
            .cornerRadius(25.0)
    }
    .padding()
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
//bagus dan sudah launch namun mau di improve
import SwiftUI
import AVFoundation

/// A speaking timer application that announces time at regular intervals.
/// This view provides a user interface for:
/// - Starting and pausing a timer
/// - Resetting the timer
/// - Voice announcements every 30 seconds
/// - Background task handling for continuous operation
/// - Information about the app's functionality
struct ContentView: View {
    // MARK: - Properties
    
    // Timer State
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    // Audio and Background Task
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier?
    
    // UI State
    @State private var showAdsAndAppFunctionality: Bool = false
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            // Background Gradient Silver or Blue
    
            LinearGradient(colors: [Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                Text(String(format: "%02d:%02d", minutes, seconds))
                    .font(.system(size: 99))
                    .padding()
                VStack {
                    Button(action: {
                        isTimerRunning ? pauseTimer() : startTimer()
                    }) {
                        Text(isTimerRunning ? "Pause" : "Start")
                            .font(.title)
                            .padding()
                            .frame(width: 233)
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                    .padding()

                    Button(action: resetTimer) {
                        Text("Reset")
                            .font(.title)
                            .padding()
                            .frame(width: 233)
                            .foregroundColor(Color.white)
                            .background(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
                            .cornerRadius(25.0)
                    }
                    .padding()
                }
                Spacer()
            }
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            .onAppear {
                setupBackgroundTaskHandling()
            }
        }
    }

    // MARK: - Timer Functions
    
    /// Starts the timer and updates the time every second.
    /// When started, the timer will:
    /// - Update the display every second
    /// - Announce time at 30-second intervals
    /// - Stop automatically after 1 hour
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let totalSeconds = self.minutes * 60 + self.seconds
            self.updateTime(totalSeconds: totalSeconds + 1)
        }
    }
    
    /// Pauses the timer by invalidating the current Timer instance
    /// and updating the running state.
    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }
    
    /// Resets the timer to its initial state (00:00).
    /// This will:
    /// - Stop the timer if running
    /// - Clear the minutes and seconds
    /// - Reset the running state
    private func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        minutes = 0
        seconds = 0
    }
    
    /// Updates the displayed time based on the total elapsed seconds.
    /// - Parameter totalSeconds: The total number of seconds elapsed since timer start
    /// - Note: This method also triggers voice announcements every 30 seconds
    ///         and stops the timer after 1 hour
    private func updateTime(totalSeconds: Int) {
        minutes = totalSeconds / 60
        seconds = totalSeconds % 60

        if totalSeconds > 0 && totalSeconds % 30 == 0 && totalSeconds <= 60 * 60 {
            speakTime()
        }

        if totalSeconds >= 60 * 60 {
            pauseTimer()
        }
    }
    
    /// Announces the current time using text-to-speech.
    /// Speaks minutes and half-minute intervals in a natural language format.
    private func speakTime() {
        var timeToSpeak = ""
        if minutes > 0 {
            timeToSpeak += "\(minutes) minute\(minutes == 1 ? "" : "s")"
        }
        if seconds == 30 {
            timeToSpeak += " and thirty seconds"
        }

        if !timeToSpeak.isEmpty {
            let speechUtterance = AVSpeechUtterance(string: timeToSpeak)
            speechSynthesizer.speak(speechUtterance)
        }
    }
    
    /// Configures background task handling to keep the timer running
    /// when the app is in the background.
    /// - Note: The background task will be ended if the remaining time is less than 30 seconds
    private func setupBackgroundTaskHandling() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main) { _ in
                backgroundTaskID = UIApplication.shared.beginBackgroundTask {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID!)
                }
                if backgroundTaskID != .invalid, UIApplication.shared.backgroundTimeRemaining < 30 {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID!)
                    backgroundTaskID = .invalid
                }
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main) { _ in
                if let backgroundTaskID = backgroundTaskID {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    self.backgroundTaskID = nil
                }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}

*/

/*
import SwiftUI
import AVFoundation
 
 /// A speaking timer application that announces time at regular intervals.
 /// This view provides a user interface for:
 /// - Starting and pausing a timer
 /// - Resetting the timer
 /// - Voice announcements every 30 seconds
 /// - Background task handling for continuous operation
 /// - Information about the app's functionality
 

/// A speaking timer application that announces time at regular intervals.
/// This view provides a user interface for:
/// - Starting and pausing a timer
/// - Resetting the timer
/// - Voice announcements every 30 seconds
/// - Background task handling for continuous operation
/// - Information about the app's functionality
struct ContentView: View {
    // MARK: - Properties
    
    // Timer State
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    // Audio and Background Task
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier?
    
    // UI State
    @State private var showAdsAndAppFunctionality: Bool = false
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            // Background Gradient
    
            LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
                Text(String(format: "%02d:%02d", minutes, seconds))
                    .font(.system(size: 99))
                    .padding()
                VStack {
                    Button(action: {
                        isTimerRunning ? pauseTimer() : startTimer()
                    }) {
                        Text(isTimerRunning ? "Pause" : "Start")
                            .font(.title)
                            .padding()
                            .frame(width: 233)
                            .foregroundColor(Color.black)
                            .background(Color.white)
                            .cornerRadius(25.0)
                    }
                    .padding()

                    Button(action: resetTimer) {
                        Text("Reset")
                            .font(.title)
                            .padding()
                            .frame(width: 233)
                            .foregroundColor(Color.white)
                            .background(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
                            .cornerRadius(25.0)
                    }
                    .padding()
                }
                Spacer()
            }
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            .onAppear {
                setupBackgroundTaskHandling()
            }
        }
    }

    // MARK: - Timer Functions
    
    /// Starts the timer and updates the time every second.
    /// When started, the timer will:
    /// - Update the display every second
    /// - Announce time at 30-second intervals
    /// - Stop automatically after 1 hour
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let totalSeconds = self.minutes * 60 + self.seconds
            self.updateTime(totalSeconds: totalSeconds + 1)
        }
    }
    
    /// Pauses the timer by invalidating the current Timer instance
    /// and updating the running state.
    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }
    
    /// Resets the timer to its initial state (00:00).
    /// This will:
    /// - Stop the timer if running
    /// - Clear the minutes and seconds
    /// - Reset the running state
    private func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        minutes = 0
        seconds = 0
    }
    
    /// Updates the displayed time based on the total elapsed seconds.
    /// - Parameter totalSeconds: The total number of seconds elapsed since timer start
    /// - Note: This method also triggers voice announcements every 30 seconds
    ///         and stops the timer after 1 hour
    private func updateTime(totalSeconds: Int) {
        minutes = totalSeconds / 60
        seconds = totalSeconds % 60

        if totalSeconds > 0 && totalSeconds % 30 == 0 && totalSeconds <= 60 * 60 {
            speakTime()
        }

        if totalSeconds >= 60 * 60 {
            pauseTimer()
        }
    }
    
    /// Announces the current time using text-to-speech.
    /// Speaks minutes and half-minute intervals in a natural language format.
    private func speakTime() {
        var timeToSpeak = ""
        if minutes > 0 {
            timeToSpeak += "\(minutes) minute\(minutes == 1 ? "" : "s")"
        }
        if seconds == 30 {
            timeToSpeak += " and thirty seconds"
        }

        if !timeToSpeak.isEmpty {
            let speechUtterance = AVSpeechUtterance(string: timeToSpeak)
            speechSynthesizer.speak(speechUtterance)
        }
    }
    
    /// Configures background task handling to keep the timer running
    /// when the app is in the background.
    /// - Note: The background task will be ended if the remaining time is less than 30 seconds
    private func setupBackgroundTaskHandling() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main) { _ in
                backgroundTaskID = UIApplication.shared.beginBackgroundTask {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID!)
                }
                if backgroundTaskID != .invalid, UIApplication.shared.backgroundTimeRemaining < 30 {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID!)
                    backgroundTaskID = .invalid
                }
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main) { _ in
                if let backgroundTaskID = backgroundTaskID {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    self.backgroundTaskID = nil
                }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
*/
