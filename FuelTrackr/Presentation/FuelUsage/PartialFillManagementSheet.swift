//
//  PartialFillManagementSheet.swift
//  FuelTrackr
//
//  Created on 2025.
//

import SwiftUI
import Domain
import SwiftData

struct PartialFillManagementSheet: View {
    let fuelUsage: FuelUsage
    let viewModel: VehicleViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var resolvedVehicle: Vehicle?
    
    var onDismiss: () -> Void
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var averageRefillAmount: Double? {
        guard let vehicle = resolvedVehicle else { return nil }
        return PartialFillDetector.averageRefillAmount(vehicle: vehicle)
    }
    
    private var canDetect: Bool {
        guard let vehicle = resolvedVehicle else { return false }
        return PartialFillDetector.canDetectPartialFills(vehicle: vehicle)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.dimensions.spacingL) {
                    // Current Status Card
                    VStack(alignment: .leading, spacing: Theme.dimensions.spacingM) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocalizedString("liters_label", comment: ""))
                                    .font(.system(size: 14))
                                    .foregroundColor(colors.onSurface)
                                Text(String(format: "%.2f L", fuelUsage.liters))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(colors.onBackground)
                            }
                            
                            Spacer()
                            
                            // Status badge
                            HStack(spacing: 4) {
                                Image(systemName: fuelUsage.isPartialFill ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                Text(fuelUsage.isPartialFill ? NSLocalizedString("partial_fill_badge", comment: "") : NSLocalizedString("full_fill", comment: ""))
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(fuelUsage.isPartialFill ? .orange : colors.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(fuelUsage.isPartialFill ? Color.orange.opacity(0.15) : colors.primary.opacity(0.15))
                            .cornerRadius(8)
                        }
                        
                        if let average = averageRefillAmount {
                            Divider()
                            
                            HStack {
                                Text(NSLocalizedString("average_refill_amount", comment: ""))
                                    .font(.system(size: 14))
                                    .foregroundColor(colors.onSurface)
                                Spacer()
                                Text(String(format: "%.2f L", average))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(colors.onBackground)
                            }
                        }
                    }
                    .padding(Theme.dimensions.spacingL)
                    .background(colors.surface)
                    .cornerRadius(Theme.dimensions.radiusCard)
                    
                    // Info Section
                    if canDetect {
                        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(colors.primary)
                                Text(NSLocalizedString("partial_fill_info", comment: ""))
                                    .font(.system(size: 14))
                                    .foregroundColor(colors.onSurface)
                            }
                        }
                        .padding(Theme.dimensions.spacingM)
                        .background(colors.primary.opacity(0.1))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(String(format: NSLocalizedString("not_enough_data_for_detection", comment: ""), PartialFillDetector.minimumRefillsForDetection))
                                    .font(.system(size: 14))
                                    .foregroundColor(colors.onSurface)
                            }
                        }
                        .padding(Theme.dimensions.spacingM)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Action Buttons
                    VStack(spacing: Theme.dimensions.spacingM) {
                        if fuelUsage.isPartialFill {
                            Button(action: {
                                viewModel.updateFuelUsagePartialFillStatus(
                                    id: fuelUsage.persistentModelID,
                                    isPartialFill: false,
                                    context: context
                                )
                                onDismiss()
                            }) {
                                Text(NSLocalizedString("mark_as_full_fill", comment: ""))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(colors.primary)
                                    .cornerRadius(12)
                            }
                        } else {
                            Button(action: {
                                viewModel.updateFuelUsagePartialFillStatus(
                                    id: fuelUsage.persistentModelID,
                                    isPartialFill: true,
                                    context: context
                                )
                                onDismiss()
                            }) {
                                Text(NSLocalizedString("mark_as_partial_fill", comment: ""))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(.orange)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, Theme.dimensions.spacingSection)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(colors.background)
            .navigationTitle(NSLocalizedString("partial_fill", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { onDismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(colors.onBackground)
                    }
                }
            }
            .onAppear {
                resolvedVehicle = viewModel.resolvedVehicle(context: context)
            }
        }
    }
}

