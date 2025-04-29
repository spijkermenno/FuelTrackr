
import SwiftUI
import SwiftData
import Domain
import Data
import Presentation

struct ContentView: View {
    @Environment(\.modelContext) private var context

    @StateObject private var vehicleViewModel: VehicleViewModel
    @StateObject private var settingsViewModel = SettingsViewModelFactory.make()

    init(context: ModelContext) {
        _vehicleViewModel = StateObject(wrappedValue: VehicleViewModelFactory.make(context: context))
    }

    var body: some View {
        NavigationStack {
            VStack {
                if vehicleViewModel.hasActiveVehicle {
                    ActiveVehicleView(vehicleViewModel: vehicleViewModel, settingsViewModel: settingsViewModel)
                } else {
                    AddVehicleView(vehicleViewModel: vehicleViewModel) {
                        vehicleViewModel.loadActiveVehicle()
                    }
                }
            }
            .onAppear {
                vehicleViewModel.loadActiveVehicle()
            }
        }
    }
}
