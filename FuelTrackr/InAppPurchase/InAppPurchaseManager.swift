//
//  InAppPurchaseManager.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 15/01/2026.
//

import Foundation
import StoreKit
import ScovilleKit

@MainActor
class InAppPurchaseManager: ObservableObject {
    @Published var products: [Product] = []

    func fetchAllProducts() async {
        do {
            let ids = InAppPurchaseItems.allCases.map { $0.getProductId() }
            let productIdentifiers = Set(ids)

            products = try await Product.products(for: productIdentifiers)
            
            print("Products fetched... \(products)")
        } catch {
            print("Failed to load products. \(error)")
            
            Task { @MainActor in
                Scoville.track(FuelTrackrEvents.failedToLoadProducts)
            }
        }
    }
    
    func purchase(product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    print("Purchase successful: \(transaction)")
                    Task { @MainActor in
                        Scoville.track(FuelTrackrEvents.IAPFullPremiumBought)
                    }
                    
                    await transaction.finish()
                }
            case .userCancelled:
                print("Purchase cancelled by user")
                Task { @MainActor in
                    Scoville.track(FuelTrackrEvents.IAPCancelled)
                }
            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
            Task { @MainActor in
                Scoville.track(FuelTrackrEvents.IAPFailed)
            }
        }
    }
}
