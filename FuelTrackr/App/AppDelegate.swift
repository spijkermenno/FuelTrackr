//
//  AppDelegate.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//


import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
      if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
          FirebaseApp.configure()
      }
      
    return true
  }
}
