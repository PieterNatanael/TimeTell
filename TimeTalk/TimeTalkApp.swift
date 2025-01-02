//
//  TimeTalkApp.swift
//  TimeTalk
//
//  Created by Pieter Yoshua Natanael on 07/03/24.
//

import SwiftUI

@main
struct TimeTalkApp: App {
    // Register the AppDelegate for UIKit lifecycle events.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
    }
}

/*

import SwiftUI

@main
struct TimeTalkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
