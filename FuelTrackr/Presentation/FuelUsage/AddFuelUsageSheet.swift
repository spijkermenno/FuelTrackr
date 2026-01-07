//
//  AddFuelUsageSheet.swift
//  FuelTrackr
//

import SwiftUI
import Domain
import SwiftData

struct AddFuelUsageSheet: View {
    @StateObject var vehicleViewModel: VehicleViewModel
    @StateObject private var viewModel = AddFuelUsageViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var resolvedVehicle: Vehicle?
    
    private var mileagePlaceholder: String {
        let currentMileage = resolvedVehicle?.mileages.last?.value ?? 0
        return viewModel.displayMileagePlaceholder(currentMileage: currentMileage)
    }
    
    var body: some View {
        NavigationStack {
            //ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Theme.dimensions.spacingL) {
                HeaderSection()
                InputSection(
                    liters: $viewModel.liters,
                    cost: $viewModel.cost,
                    mileage: $viewModel.mileage,
                    mileagePlaceholder: mileagePlaceholder,
                    errorMessage: viewModel.errorMessage,
                    mileageWarning: viewModel.mileageWarning,
                    litersError: viewModel.litersError,
                    costError: viewModel.costError,
                    mileageError: viewModel.mileageError,
                    onCancel: { dismiss() },
                    onSave: saveFuelUsage
                )
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.horizontal, Theme.dimensions.spacingSection)
            .onTapGesture { hideKeyboard() }
            .onAppear {
                resolvedVehicle = vehicleViewModel.resolvedVehicle(context: context)
            }
        }
    }
    
    private func saveFuelUsage() {
        if viewModel.saveFuelUsage(activeVehicle: resolvedVehicle, context: context) {
            // Reset the form after successful save
            viewModel.liters = ""
            viewModel.cost = ""
            viewModel.mileage = ""
            viewModel.errorMessage = nil
            viewModel.mileageWarning = nil
            viewModel.litersError = false
            viewModel.costError = false
            viewModel.mileageError = false
            dismiss()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct HeaderSection: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("add_fuel_usage_title", comment: ""))
                .font(Theme.typography.titleFont)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Theme.dimensions.spacingSection)
            
            Text(NSLocalizedString("add_fuel_usage_description", comment: ""))
                .font(Theme.typography.captionFont)
                .foregroundColor(colors.onSurface)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct InputSection: View {
    @Binding var liters: String
    @Binding var cost: String
    @Binding var mileage: String
    
    let mileagePlaceholder: String
    let errorMessage: String?
    let mileageWarning: String?
    let litersError: Bool
    let costError: Bool
    let mileageError: Bool
    
    var onCancel: () -> Void
    var onSave: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingM) {
            InputField(
                title: NSLocalizedString("liters_label", comment: ""),
                placeholder: NSLocalizedString("liters_placeholder", comment: ""),
                text: $liters,
                keyboardType: .decimalPad,
                hasError: litersError
            )
            .accessibilityLabel(NSLocalizedString("liters_label", comment: ""))
            
            InputField(
                title: NSLocalizedString("cost_label", comment: ""),
                placeholder: NSLocalizedString("cost_placeholder", comment: ""),
                text: $cost,
                keyboardType: .decimalPad,
                hasError: costError
            )
            .accessibilityLabel(NSLocalizedString("cost_label", comment: ""))
            
            VStack(alignment: .leading, spacing: 4) {
                InputField(
                    title: NSLocalizedString("mileage_label", comment: ""),
                    placeholder: mileagePlaceholder,
                    text: $mileage,
                    keyboardType: .numberPad,
                    hasError: mileageError,
                    hasWarning: mileageWarning != nil
                )
                .accessibilityLabel(NSLocalizedString("mileage_label", comment: ""))
                
                if let warning = mileageWarning {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(warning)
                            .foregroundColor(.orange)
                            .font(Theme.typography.footnoteFont)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(warning)
                }
            }
            
            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(colors.error)
                        .font(.caption)
                    Text(error)
                        .foregroundColor(colors.error)
                        .font(Theme.typography.footnoteFont)
                }
                .multilineTextAlignment(.leading)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(error)
            }
            
            ActionButtons(onCancel: onCancel, onSave: onSave)
                .padding(.top, Theme.dimensions.spacingM)
        }
    }
}

struct ActionButtons: View {
    var onCancel: () -> Void
    var onSave: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        HStack(spacing: Theme.dimensions.spacingM) {
            Button(NSLocalizedString("cancel", comment: ""), action: onCancel)
                .frame(maxWidth: .infinity)
                .padding()
                .background(colors.surface)
                .foregroundColor(colors.onBackground)
                .cornerRadius(Theme.dimensions.radiusButton)
            
            Button(NSLocalizedString("save", comment: ""), action: onSave)
                .frame(maxWidth: .infinity)
                .padding()
                .background(colors.primary)
                .foregroundColor(colors.onPrimary)
                .cornerRadius(Theme.dimensions.radiusButton)
        }
        .padding(.bottom, Theme.dimensions.spacingXL)
    }
}
