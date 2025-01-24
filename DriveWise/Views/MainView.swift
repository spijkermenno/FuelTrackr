//
//  MainView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    let vehicle: Vehicle
    @ObservedObject var viewModel: VehicleViewModel
    @State private var isRefuelPresented = false
    @State private var isMaintenancePresented = false

    var body: some View {
        VStack {
            Text("Active Vehicle: \(vehicle.name)")
                .font(.title)
            Text("License Plate: \(vehicle.licensePlate)")
                .font(.subheadline)
            Text("Mileage: \(vehicle.mileage) km")
                .font(.subheadline)

            List(vehicle.history, id: \.self) { item in
                VStack(alignment: .leading) {
                    Text(item.type == .refueling ? "Refueling" : "Maintenance")
                        .font(.headline)
                    if let details = item.details {
                        Text(details)
                    }
                    if let cost = item.cost {
                        Text("Cost: €\(cost, specifier: "%.2f")")
                    }
                    if let mileage = item.mileage {
                        Text("Mileage: \(mileage) km")
                    }
                    Text("Date: \(item.dateTime, formatter: DateFormatter.shortDate)")
                }
            }

            HStack {
                Button("Add Refueling") {
                    isRefuelPresented = true
                }
                Button("Add Maintenance") {
                    isMaintenancePresented = true
                }
            }
        }
        .padding()
        .sheet(isPresented: $isRefuelPresented) {
            AddRefuelingView(viewModel: viewModel)
        }
        .sheet(isPresented: $isMaintenancePresented) {
            AddMaintenanceView(viewModel: viewModel)
        }
    }
}
