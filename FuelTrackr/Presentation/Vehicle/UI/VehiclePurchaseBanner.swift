//  VehiclePurchaseBanner.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/01/2025.
//

import SwiftUI
import Domain

public struct VehiclePurchaseBanner: View {
    var isPurchased: Bool
    var purchaseDate: Date
    var onConfirmPurchase: () -> Void

    private var shouldShowButtons: Bool { Date() >= purchaseDate }

    public var body: some View {
        if !isPurchased {
            Card(
                header: {
                    HStack {
                        Spacer()
                        Text(NSLocalizedString("vehicle_purchase_question", comment: ""))
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                },
                content: {
                    VStack(spacing: 12) {
                        if shouldShowButtons {
                            Button(action: onConfirmPurchase) {
                                Text(NSLocalizedString("vehicle_purchase_confirm", comment: ""))
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.colors.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        } else {
                            Text(NSLocalizedString("vehicle_not_purchased_banner", comment: ""))
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Theme.colors.primary)
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            )
        }
    }
}
