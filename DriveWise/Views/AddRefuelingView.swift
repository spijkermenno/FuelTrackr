//
//  AddRefuelingView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

struct AddRefuelingView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.modelContext) private var context
    @State private var mileage = 0
    @State private var amount = 0.0
    @State private var cost = 0.0

    var body: some View {
        NavigationView {
            Form {
                TextField("Mileage", value: $mileage, format: .number)
                    .keyboardType(.numberPad)
                TextField("Amount (liters)", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Cost (€)", value: $cost, format: .currency(code: "EUR"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Refueling")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addRefueling(mileage: mileage, amount: amount, cost: cost, context: context)
                    }
                    .disabled(mileage <= 0 || amount <= 0 || cost <= 0)
                }
            }
        }
    }
}
