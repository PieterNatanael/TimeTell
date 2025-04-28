//
//  TimerManager.swift
//  Time Tell
//
//  Created by Pieter Yoshua Natanael on 15/02/25.
//


import Foundation
import AVFoundation

class TimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var isTimerRunning: Bool = false
    
    // MARK: - Private Properties
    private var timer: DispatchSourceTimer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Timer Functions
    
    func startTimer() {
        print("Timer Started")
        guard !isTimerRunning else { return }
        isTimerRunning = true
        
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now(), repeating: 1)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.updateTime(totalSeconds: self.minutes * 60 + self.seconds + 1)
        }
        timer?.resume()
    }
    
    func pauseTimer() {
        print("Timer paused")
        isTimerRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func resetTimer() {
        print("Timer reset")
        pauseTimer()
        minutes = 0
        seconds = 0
    }
    
    private func updateTime(totalSeconds: Int) {
        minutes = totalSeconds / 60
        seconds = totalSeconds % 60

        if totalSeconds > 0, totalSeconds % 30 == 0, totalSeconds <= 3600 {
            speakTime()
        }

        if totalSeconds >= 3600 {
            pauseTimer()
        }
    }
    
    //speak function for timer speech
    private func speakTime() {
      
        guard !speechSynthesizer.isSpeaking else { return }
        
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
