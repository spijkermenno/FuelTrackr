//
//  AddMaintenanceView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

struct AddMaintenanceView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.modelContext) private var context
    @State private var description = ""
    @State private var cost = 0.0
    @State private var mileage: Int?

    var body: some View {
        NavigationView {
            Form {
                TextField("Description", text: $description)
                TextField("Cost (€)", value: $cost, format: .currency(code: "EUR"))
                    .keyboardType(.decimalPad)
                TextField("Mileage (optional)", value: $mileage, format: .number)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Maintenance")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addMaintenance(details: description, cost: cost, mileage: mileage, context: context)
                    }
                    .disabled(description.isEmpty || cost <= 0)
                }
            }
        }
    }
}
