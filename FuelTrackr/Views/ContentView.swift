//
//  ContentView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = VehicleViewModel()
    @StateObject private var settingsViewModel = SettingsViewModelFactory.make()

    private let settingsRepository = SettingsRepository()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.activeVehicle != nil {
                    ActiveVehicleView(viewModel: viewModel, settingsViewModel: settingsViewModel)
                } else {
                    AddVehicleView(viewModel: viewModel) {
                        checkForActiveVehicles()
                    }
                }
            }
            .onAppear {
                checkForActiveVehicles()
            }
        }
    }

    private func checkForActiveVehicles() {
        viewModel.loadActiveVehicle(context: context)
        if let vehicle = viewModel.activeVehicle {
            print("Active vehicle found: \(vehicle.name)")
        } else {
            print("No active vehicle found.")
        }
    }
}
