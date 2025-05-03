//
//  VehiclePurchaseBanner.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//


//
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

    private var shouldShowButtons: Bool {
        Date() >= purchaseDate
    }

    public var body: some View {
        if !isPurchased {
            VStack(spacing: 12) {
                if shouldShowButtons {
                    Text(NSLocalizedString("vehicle_purchase_question", comment: ""))
                        .font(.callout)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: onConfirmPurchase) {
                        Text(NSLocalizedString("vehicle_purchase_confirm", comment: ""))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                } else {
                    Text(NSLocalizedString("vehicle_not_purchased_banner", comment: ""))
                        .font(.callout)
                        .foregroundColor(Color.orange.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.15))
            .cornerRadius(25)
        }
    }
}
