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
    @State private var keyboardHeight: CGFloat = 0

    // Create a repository to check the unit system.
    private let repository = SettingsRepository()
    
    // A computed property for whether we are in metric mode.
    private var isMetric: Bool {
        repository.isUsingMetric()
    }
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    // Compute the placeholder for the mileage field based on the active vehicle and unit system.
    private var mileagePlaceholder: String {
        // Get the current mileage from the active vehicle (assumed to be in kilometers)
        let currentMileageKm = viewModel.activeVehicle?.mileages.last?.value ?? 10000
        if isMetric {
            return "\(currentMileageKm) km"
        } else {
            // Convert km to miles for display (rounded down)
            let displayMileage = Int(Double(currentMileageKm) / 1.60934)
            return "\(displayMileage) mi"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("add_fuel_usage_title", comment: ""))
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.leading)

                    Text(NSLocalizedString("add_fuel_usage_description", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.leading)

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
                        
                        InputField(
                            title: NSLocalizedString("mileage_label", comment: ""),
                            placeholder: mileagePlaceholder,
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
                                    
                                    // If in imperial, convert entered mileage (in miles) to kilometers.
                                    let adjustedMileage = isMetric ? mileageValue : convertMilesToKm(miles: mileageValue)
                                    
                                    if viewModel.saveFuelUsage(context: context, liters: litersValue, cost: costValue, mileageValue: adjustedMileage) {
                                        dismiss()
                                    } else {
                                        errorMessage = NSLocalizedString("fuel_usage_saved_error", comment: "")
                                    }
                                }
                            }) {
                                Text(NSLocalizedString("save", comment: ""))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, keyboardHeight)
                .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            }
            .background(Color(.systemBackground))
            .edgesIgnoringSafeArea(.bottom)
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear {
                startKeyboardObserver()
            }
            .onDisappear {
                stopKeyboardObserver()
            }
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

    // Conversion function: Convert miles to kilometers, rounding up.
    private func convertMilesToKm(miles: Int) -> Int {
        let kmValue = Double(miles) * 1.60934
        return Int(ceil(kmValue))
    }

    private func startKeyboardObserver() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                let newHeight = keyboardFrame.height - safeAreaBottom
                
                if keyboardHeight != newHeight {
                    withAnimation {
                        keyboardHeight = newHeight
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardHeight = 0
            }
        }
    }

    private func stopKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
