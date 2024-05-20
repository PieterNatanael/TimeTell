//
//  ContentView.swift
//  TimeTalk
//
//  Created by Pieter Yoshua Natanael on 07/03/24.
//

import SwiftUI
import AVFoundation

/// Main content view that displays the timer and controls.
struct ContentView: View {
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier?
    @State private var showAdsAndAppFunctionality: Bool = false

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

    /// Starts the timer.
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let totalSeconds = self.minutes * 60 + self.seconds
            self.updateTime(totalSeconds: totalSeconds + 1)
        }
    }

    /// Pauses the timer.
    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }

    /// Resets the timer.
    private func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        minutes = 0
        seconds = 0
    }

    /// Updates the timer's time.
    /// - Parameter totalSeconds: The total number of seconds elapsed.
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

    /// Speaks the current time using text-to-speech.
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

    /// Sets up background task handling for the timer.
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
        ContentView()
    }
}

// MARK: - Ads App Card View

/// A view to display an individual ads app card.
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
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)

            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Ads and App Functionality View

/// A view to display ads and app functionality.
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
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    ZStack {
                        Image("threedollar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(25)
                            .clipped()
                            .onTapGesture {
                                if let url = URL(string: "https://b33.biz/three-dollar/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    // Ads App Cards
                    VStack {
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "angry", appName: "AngryKid", appDescription: "Guide for parents. Empower your child's emotions. Journal anger, export for parent understanding.", appURL: "https://apps.apple.com/id/app/angry-kid/id6499461061")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, and set goals.", appURL: "https://apps.apple.com/id/app/temptation-track/id6449725104")
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
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}


/*
//great but need improvement

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier?
    @State private var showAd: Bool = false
    @State private var showAdsAndAppFunctionality: Bool = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)),.clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                HStack{
//                    Button(action: {
//                       showAd = true
//                    }) {
//                        Image(systemName: "")
//                            .font(.system(size: 30))
//                            .foregroundColor(.white)
//                        .padding()}
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
                Text(String(format: "%02d.%02d", minutes, seconds))
                    .font(.system(size: 99))
                    .padding()
                VStack {
                    

                    Button(action: {
                        if isTimerRunning {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
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
            .sheet(isPresented: $showAd) {
                ShowAdView(onConfirm: {
                    showAd = false
                })
            }
            
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                showAdsAndAppFunctionalityView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            
            .onAppear {
                // Background Task Handling
                NotificationCenter.default.addObserver(
                    forName: UIApplication.willResignActiveNotification,
                    object: nil,
                    queue: .main) { _ in
                    backgroundTaskID = UIApplication.shared.beginBackgroundTask {
                        UIApplication.shared.endBackgroundTask(backgroundTaskID!)
                    }
                    // Check the remaining time before starting the background task
                    if backgroundTaskID != .invalid, UIApplication.shared.backgroundTimeRemaining < 30 {
                        // Less than 30 seconds remaining, end the task
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
    }

    // MARK: - Timer Functions
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let totalSeconds = self.minutes * 60 + self.seconds
            self.updateTime(totalSeconds: totalSeconds + 1)
        }
    }

    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }

    private func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        minutes = 0
        seconds = 0
    }

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
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Ad View
struct ShowAdView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                ZStack {
                    Image("threedollar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(25)
                        .clipped()
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
                // App Cards
                VStack {
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    // Add more AppCardViews here if needed
                    // App Data
                 
                    
                    AppCardView(imageName: "SingLoop", appName: "SingLOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                    Divider().background(Color.gray)
                
                }
                Spacer()

                // Close Button
                Button("Close") {
                    // Perform confirmation action
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}


// MARK: - App Card View
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
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct showAdsAndAppFunctionalityView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title3.bold())
                   Spacer()
               }
                Divider().background(Color.gray)
              
                //ads
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    ZStack {
                        Image("threedollar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(25)
                            .clipped()
                            .onTapGesture {
                                if let url = URL(string: "https://b33.biz/three-dollar/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    // App Cards
                    VStack {
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        // Add more AppCardViews here if needed
                        // App Data
                     
                        
                        AppCardView(imageName: "angry", appName: "AngryKid", appDescription: "Guide for parents. Empower your child's emotions. Journal anger, export for parent understanding.", appURL: "https://apps.apple.com/id/app/angry-kid/id6499461061")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                        Divider().background(Color.gray)
                    
                    }
                    Spacer()

                   
                   
                }
//                .padding()
//                .cornerRadius(15.0)
//                .padding()
                
                //ads end
                
                
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
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

*/
    

/*
//good with little adjusement

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier?
    @State private var showAd: Bool = false
    @State private var showExplain: Bool = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)),.clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                HStack{
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Button(action: {
                            showExplain = true
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
                Spacer()
                Text(String(format: "%02d.%02d", minutes, seconds))
                    .font(.system(size: 99))
                    .padding()
                VStack {
                    

                    Button(action: {
                        if isTimerRunning {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
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
            .sheet(isPresented: $showAd) {
                ShowAdView(onConfirm: {
                    showAd = false
                })
            }
            
            .sheet(isPresented: $showExplain) {
                ShowExplainView(onConfirm: {
                    showExplain = false
                })
            }
            
            .onAppear {
                // Background Task Handling
                NotificationCenter.default.addObserver(
                    forName: UIApplication.willResignActiveNotification,
                    object: nil,
                    queue: .main) { _ in
                    backgroundTaskID = UIApplication.shared.beginBackgroundTask {
                        UIApplication.shared.endBackgroundTask(backgroundTaskID!)
                    }
                    // Check the remaining time before starting the background task
                    if backgroundTaskID != .invalid, UIApplication.shared.backgroundTimeRemaining < 30 {
                        // Less than 30 seconds remaining, end the task
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
    }

    // MARK: - Timer Functions
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let totalSeconds = self.minutes * 60 + self.seconds
            self.updateTime(totalSeconds: totalSeconds + 1)
        }
    }

    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }

    private func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        minutes = 0
        seconds = 0
    }

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
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Ad View
struct ShowAdView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                ZStack {
                    Image("threedollar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(25)
                        .clipped()
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
                // App Cards
                VStack {
                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                    Divider().background(Color.gray)
                    // Add more AppCardViews here if needed
                    // App Data
                 
                    
                    AppCardView(imageName: "SingLoop", appName: "SingLOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    Divider().background(Color.gray)
                    
                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                    Divider().background(Color.gray)
                
                }
                Spacer()

                // Close Button
                Button("Close") {
                    // Perform confirmation action
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}

// MARK: - App Card View
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
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Get")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}
    


// MARK: - Explanation View

struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        // Explanation content...
        ScrollView {
            VStack {
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
                Text("""
    • Press start to begin the timer, and it will remind you every 30-second interval.
    •Press pause to stop the timer, and you can continue by pressing start again.
    •Press reset to reset the timer.
    """)
                    .font(.title)
                    .multilineTextAlignment(.leading)
     //                       .monospaced()
                    .padding()
                    .foregroundColor(.white)



                Spacer()

                Button("Close") {
                    // Perform confirmation action
                    onConfirm()
                }
                .font(.title)
                .padding()
             
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            
            .cornerRadius(15.0)
        .padding()
        }
    }
 }
    
*/



/*
 // work well, but need to clean up and leave notes
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier?
    @State private var showAd: Bool = false
    @State private var showExplain: Bool = false

    var body: some View {
        ZStack {
            //BG
            LinearGradient(colors: [Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)),.white], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
           
            
            
            VStack {
                HStack{
                    Button(action: {
                        showAd = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Button(action: {
                            showExplain = true
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
                Spacer()
                Text(String(format: "%02d.%02d", minutes, seconds))
                    .font(.system(size: 99))
                    .padding()
                HStack {
                    Button(action: resetTimer) {
                        Text("Reset")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color.red)
                            .cornerRadius(25.0)
                    }
                    .padding()

    //                Spacer()

                    Button(action: {
                        if isTimerRunning {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(isTimerRunning ? "Pause" : "Start")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(25.0)
                    }
                    .padding()
                }
                Spacer()
            }
            .sheet(isPresented: $showAd) {
                ShowAdView(onConfirm: {
                    showAd = false
                })
            }
            
            .sheet(isPresented: $showExplain) {
                ShowExplainView(onConfirm: {
                    showExplain = false
                })
            }
            
            .onAppear {
                NotificationCenter.default.addObserver(
                    forName: UIApplication.willResignActiveNotification,
                    object: nil,
                    queue: .main) { _ in
                    backgroundTaskID = UIApplication.shared.beginBackgroundTask {
                        UIApplication.shared.endBackgroundTask(backgroundTaskID!)
                    }
                    // Check the remaining time before starting the background task
                    if backgroundTaskID != .invalid, UIApplication.shared.backgroundTimeRemaining < 30 {
                        // Less than 30 seconds remaining, end the task
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
    }

    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let totalSeconds = self.minutes * 60 + self.seconds
            self.updateTime(totalSeconds: totalSeconds + 1)
        }
    }

    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }

    private func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        minutes = 0
        seconds = 0
    }

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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ShowAdView: View {
   var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                Text("Behind the Scenes.")
                                    .font(.title)
                                    .padding()
                                    .foregroundColor(.white)

                                // Your ad content here...

                                Text("Thank you for buying our app with a one-time fee, it helps us keep up the good work. Explore these helpful apps as well. ")
                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                
                
                
             
             Text("SingLOOP.")
                 .font(.title)
 //                           .monospaced()
                 .padding()
                 .foregroundColor(.white)
                 .onTapGesture {
                     if let url = URL(string: "https://apps.apple.com/id/app/sing-l00p/id6480459464") {
                         UIApplication.shared.open(url)
                     }
                 }
 Text("Record your voice effortlessly, and play it back in a loop.") // Add your 30 character description here
                    .font(.title3)
//                    .italic()
                   .multilineTextAlignment(.center)
                   .padding(.horizontal)
                   .foregroundColor(.white)
             
                
                Text("Insomnia Sheep.")
                    .font(.title)
     //                           .monospaced()
                    .padding()
                    .foregroundColor(.white)
                    .onTapGesture {
                        if let url = URL(string: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431") {
                            UIApplication.shared.open(url)
                        }
                    }
             Text("Design to ease your mind and help you relax leading up to sleep.") // Add your 30 character description here
                                 .font(.title3)
//                                 .italic()
                                 .padding(.horizontal)
                                 .multilineTextAlignment(.center)
                                 .foregroundColor(.white)
                           
                           Text("Dry Eye Read.")
                               .font(.title)
     //                           .monospaced()
                               .padding()
                               .foregroundColor(.white)
                               .onTapGesture {
                                   if let url = URL(string: "https://apps.apple.com/id/app/dry-eye-read/id6474282023") {
                                       UIApplication.shared.open(url)
                                   }
                               }
             Text("Go-to solution for a comfortable reading experience, by adjusting font size to suit your preference.") // Add your 30 character description here
                                 .font(.title3)
//                                 .italic()
                                 .multilineTextAlignment(.center)
                                 .padding(.horizontal)
                                 .foregroundColor(.white)
                           
                           Text("iProgramMe.")
                               .font(.title)
     //                           .monospaced()
                               .padding()
                               .foregroundColor(.white)
                               .onTapGesture {
                                   if let url = URL(string: "https://apps.apple.com/id/app/iprogramme/id6470770935") {
                                       UIApplication.shared.open(url)
                                   }
                               }
             Text("Custom affirmations, schedule notifications, stay inspired daily.") // Add your 30 character description here
                                 .font(.title3)
//                                 .italic()
                                 .multilineTextAlignment(.center)
                                 .padding(.horizontal)
                                 .foregroundColor(.white)
                           
                           Text("LoopSpeak.")
                               .font(.title)
     //                           .monospaced()
                               .padding()
                               .foregroundColor(.white)
                               .onTapGesture {
                                   if let url = URL(string: "https://apps.apple.com/id/app/loopspeak/id6473384030") {
                                       UIApplication.shared.open(url)
                                   }
                               }
             Text("Type or paste your text, play in loop, and enjoy hands-free narration.") // Add your 30 character description here
                                 .font(.title3)
//                                 .italic()
                                 .multilineTextAlignment(.center)
                                 .padding(.horizontal)
                                 .foregroundColor(.white)
                           
                      
                           Text("TemptationTrack.")
                               .font(.title)
     //                           .monospaced()
                               .padding()
                               .foregroundColor(.white)
                               .onTapGesture {
                                   if let url = URL(string: "https://apps.apple.com/id/app/temptationtrack/id6471236988") {
                                       UIApplication.shared.open(url)
                                   }
                               }
             Text("One button to track milestones, monitor progress, stay motivated.") // Add your 30 character description here
                                 .font(.title3)
//                                 .italic()
                                 .multilineTextAlignment(.center)
                                 .padding(.horizontal)
                                 .foregroundColor(.white)


               Spacer()

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .foregroundColor(.black)
               .background(Color.white)
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .background(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
           .cornerRadius(15.0)
       .padding()
        }
   }
}

struct ShowExplainView: View {
   var onConfirm: () -> Void

    var body: some View {
       VStack {
           Text("Press start to begin the timer, and it will remind you every 30 seconds interval.")
               .font(.title)
               .multilineTextAlignment(.center)
//                       .monospaced()
               .padding()
               .foregroundColor(.white)



           Spacer()

           Button("Close") {
               // Perform confirmation action
               onConfirm()
           }
           .font(.title)
           .padding()
           .foregroundColor(.black)
           .background(Color.white)
           .cornerRadius(25.0)
           .padding()
       }
       .padding()
       .background(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
       .cornerRadius(15.0)
       .padding()
   }
}


*/

/*

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            Text(String(format: "%02d.%02d", minutes, seconds))
                .font(.system(size: 60))
                .padding()
            HStack {
                Button(action: resetTimer) {
                    Text("Reset")
                        .font(.title)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(25.0)
                        
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    if isTimerRunning {
                        pauseTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(isTimerRunning ? "Pause" : "Start")
                        .font(.title)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(25.0)
                }
                .padding()
            }
            
           
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let totalSeconds = self.minutes * 60 + self.seconds
            self.updateTime(totalSeconds: totalSeconds + 1)
        }
    }
    
    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
    }
    
    private func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        minutes = 0
        seconds = 0
    }
    
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
