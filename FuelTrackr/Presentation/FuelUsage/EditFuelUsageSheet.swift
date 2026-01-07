//
//  EditFuelUsageSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 20/08/2025.
//

import SwiftUI
import Domain
import SwiftData

struct EditFuelUsageSheet: View {
    @StateObject var vehicleViewModel: VehicleViewModel
    @StateObject private var viewModel = EditFuelUsageViewModel()

    let fuelUsageID: PersistentIdentifier

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var resolvedVehicle: Vehicle?
    @State private var existingFuelUsage: FuelUsage?

    private var mileagePlaceholder: String {
        let currentMileage = resolvedVehicle?.mileages.last?.value ?? 0
        return viewModel.displayMileagePlaceholder(currentMileage: currentMileage)
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.dimensions.spacingL) {
                    HeaderSection_Edit()
                    InputSection(
                        liters: $viewModel.liters,
                        cost: $viewModel.cost,
                        mileage: $viewModel.mileage,
                        mileagePlaceholder: mileagePlaceholder,
                        errorMessage: viewModel.errorMessage,
                        mileageWarning: nil,
                        litersError: viewModel.litersError,
                        costError: viewModel.costError,
                        mileageError: viewModel.mileageError,
                        onCancel: { dismiss() },
                        onSave: saveEdits
                    )
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, Theme.dimensions.spacingSection)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { hideKeyboard() }
            .onAppear {
                resolvedVehicle = vehicleViewModel.resolvedVehicle(context: context)
                if existingFuelUsage == nil, let fu = vehicleViewModel.fuelUsage(id: fuelUsageID, context: context) {
                    existingFuelUsage = fu
                    viewModel.load(from: fu, usingMetric: vehicleViewModel.isUsingMetric)
                }
            }
        }
    }

    private func saveEdits() {
        guard let validated = viewModel.validate(vehicle: resolvedVehicle, currentFuelUsageID: fuelUsageID) else { return }
        vehicleViewModel.updateFuelUsage(
            id: fuelUsageID,
            liters: validated.liters,
            cost: validated.cost,
            mileageValue: validated.mileageValue,
            context: context
        )
        dismiss()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private struct HeaderSection_Edit: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("edit_fuel_usage_title", comment: ""))
                .font(Theme.typography.titleFont)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Theme.dimensions.spacingSection)

            Text(NSLocalizedString("edit_fuel_usage_description", comment: ""))
                .font(Theme.typography.captionFont)
                .foregroundColor(colors.onSurface)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
