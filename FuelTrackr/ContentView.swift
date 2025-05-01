import SwiftUI
import SwiftData
import Domain
import Data
import Presentation
import Factory

struct ContentView: View {
    @Environment(\.modelContext) private var context

    @InjectedObject(\.vehicleViewModel) private var vehicleViewModel: VehicleViewModel
    @InjectedObject(\.settingsViewModel) private var settingsViewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if vehicleViewModel.hasActiveVehicle {
                    ActiveVehicleView(vehicleViewModel: vehicleViewModel, settingsViewModel: settingsViewModel)
                } else {
                    AddVehicleView() {
                        vehicleViewModel.loadActiveVehicle()
                    }
                }
            }
            .onAppear {
                Container.shared.modelContext.register { context }
                vehicleViewModel.loadActiveVehicle()
            }
        }
    }
}
