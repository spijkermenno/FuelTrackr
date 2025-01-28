//
//  AddFuelUsageSheet.swift
//  FuelTrackr
//

import SwiftUI

struct AddFuelUsageSheet: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var liters = ""
    @State private var cost = ""
    @State private var mileage = ""
    @State private var errorMessage: String?

    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    var body: some View {
        NavigationView {
            ScrollView { // Ensures usability on smaller screens
                VStack(spacing: 20) {
                    // Title Section
                    Text(NSLocalizedString("add_fuel_usage_title", comment: "Add Fuel Usage Title"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    // Description Section
                    Text(NSLocalizedString("add_fuel_usage_description", comment: "Description for adding fuel usage"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    // Form Section
                    VStack(spacing: 16) {
                        // Liters Input
                        InputField(
                            title: NSLocalizedString("liters_label", comment: "Label for liters"),
                            placeholder: NSLocalizedString("liters_placeholder", comment: "Placeholder for liters"),
                            text: $liters,
                            keyboardType: .decimalPad
                        )

                        // Cost Input
                        InputField(
                            title: NSLocalizedString("cost_label", comment: "Label for cost"),
                            placeholder: NSLocalizedString("cost_placeholder", comment: "Placeholder for cost"),
                            text: $cost,
                            keyboardType: .decimalPad
                        )

                        // Mileage Input
                        let currentMileage = viewModel.activeVehicle?.mileage ?? 10000
                        InputField(
                            title: NSLocalizedString("mileage_label", comment: "Label for mileage"),
                            placeholder: "\(currentMileage) km",
                            text: $mileage,
                            keyboardType: .numberPad
                        )
                        
                        // Error Section
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        // Buttons Section
                        HStack(spacing: 16) {
                            Button(action: {
                                dismiss()
                            }) {
                                Text(NSLocalizedString("cancel", comment: "Cancel button"))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                if validateAllFields() {
                                    guard let litersValue = parseInput(liters),
                                          let costValue = parseInput(cost),
                                          let mileageValue = Int(mileage) else { return }

                                    if viewModel.saveFuelUsage(context: context, liters: litersValue, cost: costValue, mileage: mileageValue) {
                                        dismiss()
                                    } else {
                                        errorMessage = NSLocalizedString("fuel_usage_saved_error", comment: "Error saving fuel usage")
                                    }
                                }
                            }) {
                                Text(NSLocalizedString("save", comment: "Save button"))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    
                }
                .padding(.bottom) // Ensures buttons are not cut off
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    // MARK: - Helper Methods

    private func parseInput(_ input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: decimalSeparator, with: ".")
        return Double(normalized)
    }

    private func validateAllFields() -> Bool {
        guard let litersValue = parseInput(liters), litersValue > 0 else {
            errorMessage = NSLocalizedString("invalid_liters_error", comment: "Error for invalid liters")
            return false
        }

        guard let costValue = parseInput(cost), costValue > 0 else {
            errorMessage = NSLocalizedString("invalid_cost_error", comment: "Error for invalid cost")
            return false
        }

        guard let mileageValue = Int(mileage), mileageValue > 0 else {
            errorMessage = NSLocalizedString("invalid_mileage_error", comment: "Error for invalid mileage")
            return false
        }

        errorMessage = nil
        return true
    }
}
