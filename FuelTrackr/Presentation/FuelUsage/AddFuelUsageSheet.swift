//
//  AddFuelUsageSheet.swift
//  FuelTrackr
//

import SwiftUI
import Domain
import SwiftData

struct AddFuelUsageSheet: View {
    @StateObject var vehicleViewModel: VehicleViewModel
    @StateObject var viewModel: AddFuelUsageViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    private var mileagePlaceholder: String {
        let currentMileage = vehicleViewModel.activeVehicle?.mileages.last?.value ?? 0
        return viewModel.displayMileagePlaceholder(currentMileage: currentMileage)
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.dimensions.spacingL) {
                    HeaderSection()
                    InputSection(
                        liters: $viewModel.liters,
                        cost: $viewModel.cost,
                        mileage: $viewModel.mileage,
                        mileagePlaceholder: mileagePlaceholder,
                        errorMessage: viewModel.errorMessage,
                        onCancel: { dismiss() },
                        onSave: saveFuelUsage
                    )
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, Theme.dimensions.spacingSection)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { hideKeyboard() }
        }
    }

    private func saveFuelUsage() {
        if viewModel.saveFuelUsage(activeVehicle: vehicleViewModel.activeVehicle, context: context) {
            dismiss()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct HeaderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("add_fuel_usage_title", comment: ""))
                .font(Theme.typography.titleFont)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.top, Theme.dimensions.spacingSection)

            Text(NSLocalizedString("add_fuel_usage_description", comment: ""))
                .font(Theme.typography.captionFont)
                .foregroundColor(Theme.colors.onSurface)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
    }
}

struct InputSection: View {
    @Binding var liters: String
    @Binding var cost: String
    @Binding var mileage: String

    let mileagePlaceholder: String
    let errorMessage: String?

    var onCancel: () -> Void
    var onSave: () -> Void

    var body: some View {
        VStack(spacing: Theme.dimensions.spacingM) {
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

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(Theme.colors.error)
                    .font(Theme.typography.footnoteFont)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            ActionButtons(onCancel: onCancel, onSave: onSave)
                .padding(.top, Theme.dimensions.spacingM)
        }
    }
}

struct ActionButtons: View {
    var onCancel: () -> Void
    var onSave: () -> Void

    var body: some View {
        HStack(spacing: Theme.dimensions.spacingM) {
            Button(NSLocalizedString("cancel", comment: ""), action: onCancel)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.colors.surface)
                .foregroundColor(Theme.colors.onBackground)
                .cornerRadius(Theme.dimensions.radiusButton)

            Button(NSLocalizedString("save", comment: ""), action: onSave)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.colors.primary)
                .foregroundColor(Theme.colors.onPrimary)
                .cornerRadius(Theme.dimensions.radiusButton)
        }
        .padding(.bottom, Theme.dimensions.spacingXL)
    }
}

#Preview {
    AddFuelUsageSheet(
        vehicleViewModel: VehicleViewModel(),
        viewModel: AddFuelUsageViewModel()
    )
}
