import SwiftUI
import SwiftData
import Domain
import Data

struct ContentView: View {
    @Environment(\.modelContext) private var context

    @StateObject private var vehicleViewModel = VehicleViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if vehicleViewModel.hasActiveVehicle {
                    ActiveVehicleView(vehicleViewModel: vehicleViewModel, settingsViewModel: settingsViewModel)
                } else {
                    AddVehicleView() {
                        vehicleViewModel.loadActiveVehicle(context: context)
                    }
                }
            }
            .onAppear {
                vehicleViewModel.loadActiveVehicle(context: context)
            }
        }
    }
}
