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

    private var shouldShowButtons: Bool {
        return Date() >= purchaseDate
    }

    var body: some View {
        if !isPurchased {
            VStack(spacing: 12) {
                if !shouldShowButtons {
                    Text(NSLocalizedString("vehicle_not_purchased_banner", comment: ""))
                        .font(.callout)
                        .foregroundColor(Color.blue.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text(NSLocalizedString("vehicle_purchase_question", comment: ""))
                        .font(.callout)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: onConfirmPurchase) {
                        Text(NSLocalizedString("vehicle_purchase_confirm", comment: ""))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
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
