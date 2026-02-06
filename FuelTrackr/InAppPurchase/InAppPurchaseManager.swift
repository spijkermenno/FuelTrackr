//
//  InAppPurchaseManager.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 15/01/2026.
//

import Foundation
import StoreKit
import ScovilleKit

enum PurchaseState: Equatable {
    case idle
    case purchasing
    case success
    case failed(String)
    case cancelled
    
    static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.purchasing, .purchasing), (.success, .success), (.cancelled, .cancelled):
            return true
        case (.failed(let lhsMessage), .failed(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

enum PurchaseType: Equatable {
    case lifetime
    case monthly
    case yearly
    case none
}

struct PurchaseInfo: Equatable {
    let type: PurchaseType
    let productID: String
    let transactionID: UInt64?
    let purchaseDate: Date?
    let expirationDate: Date?
    
    var displayName: String {
        switch type {
        case .lifetime:
            return "Lifetime Pro"
        case .monthly:
            return "Monthly Subscription"
        case .yearly:
            return "Yearly Subscription"
        case .none:
            return "No Active Purchase"
        }
    }
}

@MainActor
class InAppPurchaseManager: ObservableObject {
    static let shared = InAppPurchaseManager()
    
    @Published var products: [Product] = []
    @Published var purchaseState: PurchaseState = .idle
    @Published var isRestoring: Bool = false
    @Published var hasActiveSubscription: Bool = false
    @Published var currentPurchaseInfo: PurchaseInfo = PurchaseInfo(type: .none, productID: "", transactionID: nil, purchaseDate: nil, expirationDate: nil)
    
    private var hasPreloadedProducts = false
    
    init() {
        Task {
            await checkPurchaseStatus()
            // Preload products on initialization
            await fetchAllProducts()
            hasPreloadedProducts = true
        }
        
        // Listen for transaction updates
        Task {
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    // Check if this is one of our products
                    let productIds = InAppPurchaseItems.allCases.map { $0.getProductId() }
                    if productIds.contains(transaction.productID) {
                        // Refresh purchase status
                        await checkPurchaseStatus()
                        // Finish the transaction
                        await transaction.finish()
                    }
                }
            }
        }
    }

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
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    print("Purchase successful: \(transaction)")
                    
                    // Update purchase status
                    await checkPurchaseStatus()
                    
                    // Finish the transaction
                    await transaction.finish()
                    
                    // Set success state
                    purchaseState = .success
                    
                    Task { @MainActor in
                        Scoville.track(FuelTrackrEvents.IAPFullPremiumBought)
                    }
                    
                    // Don't auto-reset - let user dismiss the success overlay
                } else {
                    purchaseState = .failed("Purchase verification failed")
                    Task { @MainActor in
                        Scoville.track(FuelTrackrEvents.IAPFailed)
                    }
                }
            case .userCancelled:
                print("Purchase cancelled by user")
                purchaseState = .cancelled
                Task { @MainActor in
                    Scoville.track(FuelTrackrEvents.IAPCancelled)
                }
                // Reset to idle after a short delay
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                purchaseState = .idle
            case .pending:
                purchaseState = .failed("Purchase is pending approval")
                Task { @MainActor in
                    Scoville.track(FuelTrackrEvents.IAPFailed)
                }
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                purchaseState = .idle
            @unknown default:
                purchaseState = .failed("Unknown purchase result")
                Task { @MainActor in
                    Scoville.track(FuelTrackrEvents.IAPFailed)
                }
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                purchaseState = .idle
            }
        } catch {
            print("Purchase failed: \(error)")
            purchaseState = .failed(error.localizedDescription)
            Task { @MainActor in
                Scoville.track(FuelTrackrEvents.IAPFailed)
            }
            // Reset to idle after a delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            purchaseState = .idle
        }
    }
    
    func restorePurchases() async {
        isRestoring = true
        
        do {
            // Check for current entitlements
            try await AppStore.sync()
            
            // Verify current entitlements
            var foundActivePurchase = false
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    // Check if this is one of our premium products
                    let productIds = InAppPurchaseItems.allCases.map { $0.getProductId() }
                    if productIds.contains(transaction.productID) {
                        foundActivePurchase = true
                        print("Found active purchase: \(transaction.productID)")
                    }
                }
            }
            
            // Update purchase status
            await checkPurchaseStatus()
            
            if foundActivePurchase {
                purchaseState = .success
                // Don't auto-reset - let user dismiss the success overlay
            } else {
                purchaseState = .failed("No previous purchases found")
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                purchaseState = .idle
            }
        } catch {
            print("Restore purchases failed: \(error)")
            purchaseState = .failed("Failed to restore purchases: \(error.localizedDescription)")
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            purchaseState = .idle
        }
        
        isRestoring = false
    }
    
    func checkPurchaseStatus() async {
        var hasActive = false
        var purchaseType: PurchaseType = .none
        var productID: String = ""
        var transactionID: UInt64?
        var purchaseDate: Date?
        var expirationDate: Date?
        
        // Get the most recent active entitlement
        var latestTransaction: Transaction?
        var latestTransactionDate: Date?
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                let productIds = InAppPurchaseItems.allCases.map { $0.getProductId() }
                if productIds.contains(transaction.productID) {
                    // Check if this is revoked or expired
                    if transaction.revocationDate != nil {
                        continue // Skip revoked transactions
                    }
                    
                    // Check if subscription is expired
                    if let expirationDate = transaction.expirationDate,
                       expirationDate < Date() {
                        continue // Skip expired subscriptions
                    }
                    
                    hasActive = true
                    
                    // Keep track of the most recent transaction
                    let txDate = transaction.purchaseDate
                    if latestTransactionDate == nil || txDate > latestTransactionDate! {
                        latestTransaction = transaction
                        latestTransactionDate = txDate
                    }
                }
            }
        }
        
        // Use the most recent transaction for purchase info
        if let transaction = latestTransaction {
            // Determine purchase type
            if transaction.productID.contains("lifetime") {
                purchaseType = .lifetime
            } else if transaction.productID.contains("yearly") {
                purchaseType = .yearly
            } else if transaction.productID.contains("monthly") {
                purchaseType = .monthly
            }
            
            productID = transaction.productID
            transactionID = transaction.id
            purchaseDate = transaction.purchaseDate
            expirationDate = transaction.expirationDate
        }
        
        hasActiveSubscription = hasActive
        currentPurchaseInfo = PurchaseInfo(
            type: purchaseType,
            productID: productID,
            transactionID: transactionID,
            purchaseDate: purchaseDate,
            expirationDate: expirationDate
        )
    }
    
    func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
    
    #if DEBUG
    func removeProStatus() {
        hasActiveSubscription = false
        currentPurchaseInfo = PurchaseInfo(type: .none, productID: "", transactionID: nil, purchaseDate: nil, expirationDate: nil)
    }
    #endif
    
    func resetPurchaseState() {
        purchaseState = .idle
    }
    
    #if DEBUG
    func setDebugPurchaseState(_ state: PurchaseState) {
        purchaseState = state
    }
    #endif
}
