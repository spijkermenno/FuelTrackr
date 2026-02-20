import SwiftUI
import FirebaseAnalytics
import SwiftData
import Domain
import Data
import ScovilleKit

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    @StateObject private var vehicleViewModel = VehicleViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @ObservedObject private var reviewPrompter = ReviewPrompter.shared
    @State private var reviewDetent: PresentationDetent = .medium
    
    var body: some View {
        NavigationStack {
            if vehicleViewModel.hasActiveVehicle {
                ActiveVehicleView(vehicleViewModel: vehicleViewModel, settingsViewModel: settingsViewModel)
            } else {
                OnboardingFlowView(
                    onComplete: {
                        vehicleViewModel.loadActiveVehicle(context: context)
                    }
                )
            }
        }
        .sheet(isPresented: $reviewPrompter.showCustomReview) {
            CustomReviewView(isPresented: $reviewPrompter.showCustomReview)
                .presentationDetents([.medium, .fraction(0.80)], selection: $reviewDetent)
                .presentationDragIndicator(.visible)
                .onPreferenceChange(ReviewDetentPreferenceKey.self) { newDetent in
                    // Animate the detent change smoothly
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        reviewDetent = newDetent
                    }
                }
        }
        .onAppear {
            vehicleViewModel.loadActiveVehicle(context: context)
            
            // Track app start
            Task { @MainActor in
                let params: [String: Any] = [
                    "has_vehicle": vehicleViewModel.hasActiveVehicle ? "true" : "false"
                ]
                Scoville.track(FuelTrackrEvents.appStarted, parameters: params)
                Analytics.logEvent(FuelTrackrEvents.appStarted.rawValue, parameters: params)
            }
        }
    }
}
