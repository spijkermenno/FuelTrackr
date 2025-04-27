//
//  AddFuelUsageSheet.swift
//  FuelTrackr
//

import SwiftUI
import SwiftData

struct AddFuelUsageSheet: View {
    @StateObject private var viewModel: AddFuelUsageViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var keyboardHeight: CGFloat = 0

    private var mileagePlaceholder: String {
        let currentMileageKm = vehicleViewModel.activeVehicle?.mileages.last?.value ?? 10000
        return viewModel.displayMileagePlaceholder(currentMileage: currentMileageKm)
    }

    init(context: ModelContext, vehicleViewModel: VehicleViewModel) {
        _viewModel = StateObject(wrappedValue: AddFuelUsageViewModelFactory.make(context: context))
        self.vehicleViewModel = vehicleViewModel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.dimensions.spacingL) {
                    headerSection
                    inputFieldsSection
                }
                .padding(.bottom, keyboardHeight)
                .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            }
            .background(Theme.colors.background)
            .edgesIgnoringSafeArea(.bottom)
            .onTapGesture { hideKeyboard() }
            .onAppear { startKeyboardObserver() }
            .onDisappear { stopKeyboardObserver() }
            .navigationTitle(NSLocalizedString("add_fuel_usage_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("add_fuel_usage_title", comment: ""))
                .font(Theme.typography.titleFont)
                .padding(.top, Theme.dimensions.spacingXL)

            Text(NSLocalizedString("add_fuel_usage_description", comment: ""))
                .font(Theme.typography.captionFont)
                .foregroundColor(Theme.colors.onSurface)
        }
        .padding(.horizontal, Theme.dimensions.spacingL)
    }

    private var inputFieldsSection: some View {
        VStack(spacing: Theme.dimensions.spacingM) {
            InputField(
                title: NSLocalizedString("liters_label", comment: ""),
                placeholder: NSLocalizedString("liters_placeholder", comment: ""),
                text: $viewModel.liters,
                keyboardType: .decimalPad
            )

            InputField(
                title: NSLocalizedString("cost_label", comment: ""),
                placeholder: NSLocalizedString("cost_placeholder", comment: ""),
                text: $viewModel.cost,
                keyboardType: .decimalPad
            )

            InputField(
                title: NSLocalizedString("mileage_label", comment: ""),
                placeholder: mileagePlaceholder,
                text: $viewModel.mileage,
                keyboardType: .numberPad
            )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(Theme.colors.error)
                    .font(Theme.typography.footnoteFont)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            actionButtons
        }
        .padding()
        .background(Theme.colors.surface)
        .cornerRadius(Theme.dimensions.radiusCard)
        .padding(.horizontal)
    }

    private var actionButtons: some View {
        HStack(spacing: Theme.dimensions.spacingM) {
            Button(action: { dismiss() }) {
                Text(NSLocalizedString("cancel", comment: ""))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.colors.surface)
                    .foregroundColor(Theme.colors.onBackground)
                    .cornerRadius(Theme.dimensions.radiusButton)
            }

            Button(action: saveFuelUsage) {
                Text(NSLocalizedString("save", comment: ""))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.colors.primary)
                    .foregroundColor(Theme.colors.onPrimary)
                    .cornerRadius(Theme.dimensions.radiusButton)
            }
        }
        .padding(.bottom, Theme.dimensions.spacingXL)
    }

    private func saveFuelUsage() {
        if viewModel.saveFuelUsage(activeVehicle: vehicleViewModel.activeVehicle) {
            dismiss()
        }
    }

    private func startKeyboardObserver() { /* keep your existing code */ }
    private func stopKeyboardObserver() { /* keep your existing code */ }
    private func hideKeyboard() { /* keep your existing code */ }
}
