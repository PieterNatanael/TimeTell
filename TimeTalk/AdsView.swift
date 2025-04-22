//
//  AdsView.swift
//  Time Tell
//
//  Created by Pieter Yoshua Natanael on 04/02/25.
//

import SwiftUI

struct ShowAdsAndAppFunctionalityView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Title
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title3.bold())
                    Spacer()
                }
                CustomDivider()

                // Ads Section
                VStack(spacing: 16) {
                    HStack {
                        Text("Apps for you")
                            .font(.largeTitle.bold())
                        Spacer()
                    }

                    AppCardView(
                        imageName: "takemedication",
                        appName: "Take Medication",
                        appDescription: "Just press any of the 24 buttons, each representing an hour of the day, and you'll get timely reminders to take your medication. It's easy, quick, and ensures you never miss a dose!",
                        appURL: "https://apps.apple.com/id/app/take-medication/id6736924598"
                    )
                    CustomDivider()

                    AppCardView(
                        imageName: "BST",
                        appName: "Blink Screen Time",
                        appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.",
                        appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095"
                    )
                    CustomDivider()

                    AppCardView(
                        imageName: "sos",
                        appName: "SOS light",
                        appDescription: "SOS Light is designed to maximize the chances of getting help in emergency situations.",
                        appURL: "https://apps.apple.com/app/s0s-light/id6504213303"
                    )
                    CustomDivider()
                }

                // App Functionality Section
                VStack(spacing: 16) {
                    HStack {
                        Text("App Functionality")
                            .font(.title.bold())
                        Spacer()
                    }

                    Text("""
                    • Press start to begin the timer, and it will remind you every 30-second interval.
                    • Press pause to stop the timer, and you can continue by pressing start again.
                    • Press reset to reset the timer.
                    """)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .padding()
                }

                // Footer
                HStack {
                    Text("Time Tell is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

                // Close Button
                Button(action: onConfirm) {
                    Text("Close")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical, 10)
            }
            .padding()
        }
        .cornerRadius(15.0)
    }
}

// Reusable App Card View
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
        }
        .onTapGesture {
            if let url = URL(string: appURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// Reusable Divider
struct CustomDivider: View {
    var body: some View {
        Divider()
            .background(Color.gray)
    }
}
