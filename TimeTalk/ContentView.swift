//
//  ContentView.swift
//  TimeTalk
//
//  Created by Pieter Yoshua Natanael on 07/03/24.
//

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
                Text("Ads.")
                                    .font(.title)
                                    .padding()
                                    .foregroundColor(.white)

                                // Your ad content here...

                                Text("Buying our apps with a one-time fee helps us keep up the good work.")
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
                    .italic()
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
                                 .italic()
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
                                 .italic()
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
                                 .italic()
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
                                 .italic()
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
                                 .italic()
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
