//
//  AppDelegate.swift
//  TimeTalk
//
//  Created by Pieter Yoshua Natanael on 07/03/24.
//


import UIKit
import AVFoundation

/// The `AppDelegate` class is the main entry point for the application lifecycle.
/// It manages background tasks and initializes an audio session for playback.
class AppDelegate: UIResponder, UIApplicationDelegate {
    /// Identifier for the background task to ensure proper handling of background activities.
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    /// Called when the application finishes launching. Sets up the audio session for playback mode.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: A dictionary indicating the reason the app was launched (if any).
    /// - Returns: `true` if the application successfully launched; otherwise, `false`.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initializeAudioSession()
        return true
    }

    /// Called when the application transitions to the background.
    /// - Parameter application: The singleton app object.
    func applicationDidEnterBackground(_ application: UIApplication) {
        startBackgroundTask()
    }

    /// Called when the application transitions from the background to the foreground.
    /// - Parameter application: The singleton app object.
    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTask()
    }

    /// Initializes the audio session for playback mode with a spoken audio category.
    /// This setup ensures the app can play audio even in the background.
    private func initializeAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
    }

    /// Starts a background task to allow the app to run tasks in the background.
    /// Ensures the previous background task is ended before starting a new one.
    private func startBackgroundTask() {
        endBackgroundTask() // Clean up any existing background task
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyAppBackgroundTask") {
            // Task expiration handler: End the task if time expires
            self.endBackgroundTask()
        }
    }

    /// Ends the currently active background task, if any.
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

/*
import UIKit
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category.")
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        startBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTask()
    }

    func startBackgroundTask() {
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyAppBackgroundTask") {
            // End the task if time expires.
            self.endBackgroundTask()
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

*/
