//
//  EditFuelUsageSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 20/08/2025.
//

import SwiftUI
import Domain
import SwiftData
import ScovilleKit
import FirebaseAnalytics

private struct EditSheetContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct EditFuelUsageSheet: View {
    @StateObject var vehicleViewModel: VehicleViewModel
    @StateObject private var viewModel = EditFuelUsageViewModel()

    let fuelUsageID: PersistentIdentifier

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme

    @State private var resolvedVehicle: Vehicle?
    @State private var existingFuelUsage: FuelUsage?
    @State private var mergedGroup: [FuelUsage] = []
    @State private var contentHeight: CGFloat = 520
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardShowObserver: Any?
    @State private var keyboardHideObserver: Any?

    private var mileagePlaceholder: String {
        let currentMileage = resolvedVehicle?.mileages.last?.value ?? 0
        return viewModel.displayMileagePlaceholder(currentMileage: currentMileage)
    }
    
    private var isPartOfMergedGroup: Bool {
        !mergedGroup.isEmpty && mergedGroup.count > 1
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.dimensions.spacingL) {
                    HeaderSection_Edit()
                    if let vehicle = resolvedVehicle {
                        InputSection(
                            liters: $viewModel.liters,
                            cost: $viewModel.cost,
                            mileage: $viewModel.mileage,
                            entryDate: $viewModel.entryDate,
                            mileagePlaceholder: mileagePlaceholder,
                            errorMessage: viewModel.errorMessage,
                            mileageWarning: nil,
                            litersError: viewModel.litersError,
                            costError: viewModel.costError,
                            mileageError: viewModel.mileageError,
                            fuelType: vehicle.fuelType,
                            isUsingMetric: vehicleViewModel.isUsingMetric,
                            isPartialFill: $viewModel.isPartialFill,
                            showPartialFillToggle: existingFuelUsage != nil,
                            isEditing: true,
                            onSave: saveEdits
                        )
                    } else {
                        InputSection(
                            liters: $viewModel.liters,
                            cost: $viewModel.cost,
                            mileage: $viewModel.mileage,
                            entryDate: $viewModel.entryDate,
                            mileagePlaceholder: mileagePlaceholder,
                            errorMessage: viewModel.errorMessage,
                            mileageWarning: nil,
                            litersError: viewModel.litersError,
                            costError: viewModel.costError,
                            mileageError: viewModel.mileageError,
                            fuelType: nil,
                            isUsingMetric: vehicleViewModel.isUsingMetric,
                            isPartialFill: $viewModel.isPartialFill,
                            showPartialFillToggle: existingFuelUsage != nil,
                            isEditing: true,
                            onSave: saveEdits
                        )
                    }
                    
                    // Merged Group Section
                    if isPartOfMergedGroup {
                        MergedGroupSection(
                            mergedGroup: mergedGroup,
                            currentFuelUsageID: fuelUsageID,
                            viewModel: vehicleViewModel,
                            onUpdate: {
                                loadMergedGroup()
                                if let fu = vehicleViewModel.fuelUsage(id: fuelUsageID, context: context) {
                                    existingFuelUsage = fu
                                    self.viewModel.load(from: fu, usingMetric: vehicleViewModel.isUsingMetric)
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, Theme.dimensions.spacingSection)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: EditSheetContentHeightKey.self, value: geo.size.height)
                    }
                )
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { hideKeyboard() }
            .padding(.bottom, keyboardHeight)
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("edit_fuel_usage_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.colors(for: colorScheme).onBackground)
                    }
                }
            }
            .onAppear {
                resolvedVehicle = vehicleViewModel.resolvedVehicle(context: context)
                if existingFuelUsage == nil, let fu = vehicleViewModel.fuelUsage(id: fuelUsageID, context: context) {
                    existingFuelUsage = fu
                    viewModel.load(from: fu, usingMetric: vehicleViewModel.isUsingMetric)
                }
                loadMergedGroup()
                startKeyboardObserver()
            }
            .onDisappear {
                stopKeyboardObserver()
            }
            .onPreferenceChange(EditSheetContentHeightKey.self) { height in
                guard height > 0 else { return }
                let bottomPadding: CGFloat = Theme.dimensions.spacingXL
                let maxHeight = UIScreen.main.bounds.height * 0.65
                contentHeight = min(height + bottomPadding, maxHeight)
            }
        }
        .presentationDetents([.height(contentHeight)])
        .presentationBackground(Color(UIColor.systemGroupedBackground))
    }
    
    private func startKeyboardObserver() {
        keyboardShowObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                Task { @MainActor in
                    keyboardHeight = frame.height
                }
            }
        }
        keyboardHideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                keyboardHeight = 0
            }
        }
    }
    
    private func stopKeyboardObserver() {
        if let ob = keyboardShowObserver {
            NotificationCenter.default.removeObserver(ob)
        }
        if let ob = keyboardHideObserver {
            NotificationCenter.default.removeObserver(ob)
        }
    }

    private func saveEdits() {
        guard let validated = viewModel.validate(vehicle: resolvedVehicle, currentFuelUsageID: fuelUsageID) else { return }
        vehicleViewModel.updateFuelUsage(
            id: fuelUsageID,
            liters: validated.liters,
            cost: validated.cost,
            mileageValue: validated.mileageValue,
            date: viewModel.entryDate,
            context: context
        )
        // Update partial fill status
        vehicleViewModel.updateFuelUsagePartialFillStatus(
            id: fuelUsageID,
            isPartialFill: viewModel.isPartialFill,
            context: context
        )
        
        // Track fuel usage edited
        Task { @MainActor in
            let params: [String: Any] = [
                "is_partial_fill": viewModel.isPartialFill ? "true" : "false"
            ]
            Scoville.track(FuelTrackrEvents.fuelUsageEdited, parameters: params)
            Analytics.logEvent(FuelTrackrEvents.fuelUsageEdited.rawValue, parameters: params)
        }
        
        dismiss()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func loadMergedGroup() {
        guard let vehicle = resolvedVehicle else { return }
        let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
        
        // Find the group that contains the fuelUsageID
        if let group = groups.first(where: { group in
            group.contains { $0.persistentModelID == fuelUsageID }
        }) {
            mergedGroup = group
        } else {
            mergedGroup = []
        }
    }
}

// MARK: - Merged Group Section

struct MergedGroupSection: View {
    let mergedGroup: [FuelUsage]
    let currentFuelUsageID: PersistentIdentifier
    let viewModel: VehicleViewModel
    
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    
    var onUpdate: () -> Void
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var totalFuel: Double {
        mergedGroup.reduce(0.0) { $0 + $1.liters }
    }
    
    private var totalCost: Double {
        mergedGroup.reduce(0.0) { $0 + $1.cost }
    }
    
    private var sortedGroup: [FuelUsage] {
        mergedGroup.sorted { $0.date < $1.date }
    }
    
    private var vehicle: Vehicle? {
        try? context.fetch(FetchDescriptor<Vehicle>()).first
    }
    
    private var fuelType: FuelType? {
        vehicle?.fuelType
    }
    
    private var isUsingMetric: Bool {
        viewModel.isUsingMetric
    }
    
    private func formatFuelAmount(_ amount: Double) -> String {
        let fuelTypeToUse = fuelType ?? .liquid
        return fuelTypeToUse.formatFuelAmount(amount, isUsingMetric: isUsingMetric)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingM) {
            headerSection
            infoSection
            summarySection
            entriesSection
        }
        .padding(Theme.dimensions.spacingL)
        .background(containerBackground)
    }
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "link")
                .foregroundColor(.orange)
                .font(.system(size: 16, weight: .semibold))
            Text(NSLocalizedString("merged_group_title", comment: ""))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(colors.onBackground)
        }
        .padding(.bottom, Theme.dimensions.spacingXS)
    }
    
    private var infoSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 14))
            Text(NSLocalizedString("merged_group_info", comment: ""))
                .font(.system(size: 14))
                .foregroundColor(colors.onSurface)
        }
        .padding(Theme.dimensions.spacingM)
        .background(Color.orange.opacity(0.15))
        .cornerRadius(12)
    }
    
    private var summarySection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("total_fuel", comment: ""))
                    .font(.system(size: 12))
                    .foregroundColor(colors.onSurface)
                Text(formatFuelAmount(totalFuel))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(colors.onBackground)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(NSLocalizedString("entries_count", comment: ""))
                    .font(.system(size: 12))
                    .foregroundColor(colors.onSurface)
                Text("\(mergedGroup.count)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(colors.onBackground)
            }
        }
        .padding(Theme.dimensions.spacingM)
        .background(colors.surface)
        .overlay(summaryBorder)
        .cornerRadius(12)
    }
    
    private var summaryBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.orange.opacity(0.5), lineWidth: 2)
    }
    
    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("entries_in_group", comment: ""))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.onBackground)
                .padding(.bottom, Theme.dimensions.spacingXS)
            
            entriesList
        }
    }
    
    private var entriesList: some View {
        VStack(spacing: 0) {
            ForEach(Array(sortedGroup.enumerated()), id: \.element.persistentModelID) { index, usage in
                MergedGroupEntryRow(
                    usage: usage,
                    isCurrentEntry: usage.persistentModelID == currentFuelUsageID,
                    viewModel: viewModel,
                    onUpdate: onUpdate
                )
                
                if index < sortedGroup.count - 1 {
                    connectingLine
                }
            }
        }
        .padding(Theme.dimensions.spacingM)
        .background(entriesContainerBackground)
    }
    
    private var connectingLine: some View {
        HStack {
            Circle()
                .fill(Color.orange.opacity(0.6))
                .frame(width: 4, height: 4)
            Rectangle()
                .fill(Color.orange.opacity(0.3))
                .frame(height: 1)
            Spacer()
        }
        .padding(.leading, Theme.dimensions.spacingM + 4)
        .padding(.vertical, 4)
    }
    
    private var entriesContainerBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.orange.opacity(0.08))
            .overlay(entriesContainerBorder)
    }
    
    private var entriesContainerBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
    }
    
    private var containerBackground: some View {
        RoundedRectangle(cornerRadius: Theme.dimensions.radiusCard)
            .fill(colors.surface)
            .overlay(containerBorder)
    }
    
    private var containerBorder: some View {
        RoundedRectangle(cornerRadius: Theme.dimensions.radiusCard)
            .stroke(Color.orange.opacity(0.3), lineWidth: 2)
    }
}


private struct HeaderSection_Edit: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("edit_fuel_usage_description", comment: ""))
                .font(Theme.typography.captionFont)
                .foregroundColor(colors.onSurface)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
