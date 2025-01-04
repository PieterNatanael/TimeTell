//
//  ContentView.swift
//  TimeTalk
//
//  Created by Pieter Yoshua Natanael on 07/03/24.
//

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

// MARK: - Supporting Views
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)

            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title.bold())
                Text(appDescription)
                    .font(.title)
            }
            .frame(alignment: .leading)

            Spacer()
//    
        }
        .onTapGesture {
            if let url = URL(string: appURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}



struct ShowAdsAndAppFunctionalityView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title3.bold())
                    Spacer()
                }
                Divider().background(Color.gray)
                
                // Ads
                VStack {
                    HStack {
                        Text("Apps for you")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    VStack {
                       
                        Divider().background(Color.gray)
                        AppCardView(imageName: "takemedication", appName: "Take Medication", appDescription: "Just press any of the 24 buttons, each representing an hour of the day, and you'll get timely reminders to take your medication. It's easy, quick, and ensures you never miss a dose!", appURL: "https://apps.apple.com/id/app/take-medication/id6736924598")
                        
                        Divider().background(Color.gray)

                        AppCardView(imageName: "BST", appName: "Blink Screen Time", appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        Divider().background(Color.gray)
                        

                        AppCardView(imageName: "sos", appName: "SOS light", appDescription: "SOS Light is designed to maximize the chances of getting help in emergency situations.", appURL: "https://apps.apple.com/app/s0s-light/id6504213303")
                        
                        Divider().background(Color.gray)

                    }
                }

                // App Functionality
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               •Press start to begin the timer, and it will remind you every 30-second interval.
               •Press pause to stop the timer, and you can continue by pressing start again.
               •Press reset to reset the timer.
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("Time Tell is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .frame(maxWidth: .infinity)
               .padding()
               .background(Color.blue)
               .foregroundColor(.white)
               .cornerRadius(10)
               .padding(.vertical, 10)
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}
