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
            ScrollView {
                VStack(spacing: 20) {
                    Text(NSLocalizedString("add_fuel_usage_title", comment: ""))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    Text(NSLocalizedString("add_fuel_usage_description", comment: ""))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    VStack(spacing: 16) {
                        InputField(
                            title: NSLocalizedString("liters_label", comment: ""),
                            placeholder: NSLocalizedString("liters_placeholder", comment: ""),
                            text: $liters,
                            keyboardType: .decimalPad
                        )

                        InputField(
                            title: NSLocalizedString("cost_label", comment: ""),
                            placeholder: NSLocalizedString("cost_placeholder", comment: ""),
                            text: $cost,
                            keyboardType: .decimalPad
                        )

                        let currentMileage = viewModel.activeVehicle?.mileage ?? 10000
                        InputField(
                            title: NSLocalizedString("mileage_label", comment: ""),
                            placeholder: "\(currentMileage) km",
                            text: $mileage,
                            keyboardType: .numberPad
                        )
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        HStack(spacing: 16) {
                            Button(action: { dismiss() }) {
                                Text(NSLocalizedString("cancel", comment: ""))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
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
                                        errorMessage = NSLocalizedString("fuel_usage_saved_error", comment: "")
                                    }
                                }
                            }) {
                                Text(NSLocalizedString("save", comment: ""))
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
                .padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    private func parseInput(_ input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: decimalSeparator, with: ".")
        return Double(normalized)
    }

    private func validateAllFields() -> Bool {
        guard let litersValue = parseInput(liters), litersValue > 0 else {
            errorMessage = NSLocalizedString("invalid_liters_error", comment: "")
            return false
        }

        guard let costValue = parseInput(cost), costValue > 0 else {
            errorMessage = NSLocalizedString("invalid_cost_error", comment: "")
            return false
        }

        guard let mileageValue = Int(mileage), mileageValue > 0 else {
            errorMessage = NSLocalizedString("invalid_mileage_error", comment: "")
            return false
        }

        errorMessage = nil
        return true
    }
}
