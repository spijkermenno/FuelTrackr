//
//  FuelTrackrApp.swift
//  FuelTrackr
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseCrashlytics

import Domain
import Data

@main
struct FuelTrackrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    private let container: ModelContainer?
    @State private var initializationError: Error?

    init() {
        do {
            container = try ModelContainer(for: Vehicle.self, FuelUsage.self, Maintenance.self, Mileage.self)
            initializationError = nil
        } catch {
            container = nil
            initializationError = error
            
            // Log error to Crashlytics for monitoring
            #if !DEBUG
            Crashlytics.crashlytics().record(error: error)
            #endif
            
            print("❌ Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container = container {
                ContentView()
                    .modelContainer(container)
                    .onAppear {
                        // Preload IAP products early
                        Task {
                            await InAppPurchaseManager.shared.fetchAllProducts()
                        }
                    }
            } else {
                DataInitializationErrorView(error: initializationError)
            }
        }
    }
}

// MARK: - Error View
struct DataInitializationErrorView: View {
    let error: Error?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Unable to Initialize App")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("We encountered an issue while setting up the app. Please try restarting the app or contact support if the problem persists.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let error = error {
                    Text("Error: \(error.localizedDescription)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            
            VStack(spacing: 12) {
                Text("Please close and reopen the app to try again.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if let supportEmail = URL(string: "mailto:support@pepper-technologies.nl") {
                    Link("Contact Support", destination: supportEmail)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}
