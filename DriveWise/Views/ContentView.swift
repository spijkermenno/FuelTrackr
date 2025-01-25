//
//  ContentView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = VehicleViewModel()
    @State private var isAddVehicleSheetPresented = false // Control sheet presentation

    var body: some View {
        NavigationView {
            VStack {
                if let vehicle = viewModel.activeVehicle {
                    ActiveVehicleView(vehicle: vehicle) {
                        deleteVehicle(vehicle)
                    }
                } else {
                    AddVehicleView {
                        checkForActiveVehicles() // Refresh state after adding vehicle
                        isAddVehicleSheetPresented = false // Dismiss the sheet
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

    private func deleteVehicle(_ vehicle: Vehicle) {
        context.delete(vehicle) // Delete the vehicle
        do {
            try context.save()
            print("Vehicle deleted successfully.")
            checkForActiveVehicles() // Refresh state after deletion
        } catch {
            print("Error deleting vehicle: \(error.localizedDescription)")
        }
    }
}
