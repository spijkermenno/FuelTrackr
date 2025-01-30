//
//  VehiclePurchaseBanner.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/01/2025.
//

import SwiftUI

struct VehiclePurchaseBanner: View {
    var isPurchased: Bool
    var purchaseDate: Date
    var onConfirmPurchase: () -> Void
    var onDeleteVehicle: () -> Void

    private var shouldShowButtons: Bool {
        return Date() >= purchaseDate // Only show buttons if today is on or after purchase date
    }

    var body: some View {
        if !isPurchased {
            VStack(spacing: 12) {
                if !shouldShowButtons {
                    Text(NSLocalizedString("vehicle_not_purchased_banner", comment: "Informative banner for unpurchased vehicle"))
                        .font(.callout)
                        .foregroundColor(Color.blue.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text(NSLocalizedString("vehicle_purchase_question", comment: "Informative banner for unpurchased vehicle"))
                        .font(.callout)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        Button(action: onConfirmPurchase) {
                            Text(NSLocalizedString("vehicle_purchase_confirm", comment: "Confirm Purchase Button"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.8)) // More neutral color for information
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        Button(action: onDeleteVehicle) {
                            Text(NSLocalizedString("vehicle_purchase_cancel", comment: "Delete Vehicle Button"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3)) // Neutral color for less urgency
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)

            .background(Color.blue.opacity(0.15))
            .cornerRadius(10)
        }
    }
}
