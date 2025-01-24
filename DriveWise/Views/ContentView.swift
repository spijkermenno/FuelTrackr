//
//  ContentView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

enum NavigationState: Hashable {
    case home
    case addVehicle
    case showDetails(vehicle: Vehicle)
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = VehicleViewModel()
    @State private var navigationPath = NavigationPath() // Manage the navigation stack

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if let vehicle = viewModel.activeVehicle {
                    // Show Active Vehicle Details
                    ActiveVehicleView(vehicle: vehicle) {
                        resetToHome()
                    }
                } else {
                    // Show Add Vehicle Prompt
                    VStack {
                        Text("DriveWise")
                            .font(.largeTitle)
                            .bold()

                        Text("No active vehicle found.")
                            .padding(.bottom, 16)

                        Button("Add Vehicle") {
                            navigateTo(.addVehicle)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                    .padding()
                }
            }
            .onAppear {
                checkForActiveVehicles()
            }
            .navigationDestination(for: NavigationState.self) { destination in
                switch destination {
                case .home:
                    EmptyView() // Home is already handled in the main view
                case .addVehicle:
                    AddVehicleView {
                        handleVehicleSaved() // Navigate to home and reset stack
                    }
                case .showDetails(let vehicle):
                    ActiveVehicleView(vehicle: vehicle) {
                        resetToHome() // Navigate back to home
                    }
                }
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

    private func navigateTo(_ destination: NavigationState) {
        navigationPath.append(destination)
    }

    private func resetToHome() {
        navigationPath = NavigationPath() // Clear the navigation stack
    }

    private func handleVehicleSaved() {
        resetToHome() // Reset stack to home after saving
        checkForActiveVehicles() // Refresh state to reflect new vehicle
    }
}
