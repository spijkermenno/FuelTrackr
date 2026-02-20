//
//  InAppPurchaseManager.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 15/01/2026.
//

import Foundation
import StoreKit
import ScovilleKit
import FirebaseAnalytics

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
            return NSLocalizedString("purchase_display_lifetime", comment: "")
        case .monthly:
            return NSLocalizedString("purchase_display_monthly", comment: "")
        case .yearly:
            return NSLocalizedString("purchase_display_yearly", comment: "")
        case .none:
            return NSLocalizedString("purchase_display_none", comment: "")
        }
    }
}

// MARK: - Scoville IAP Type Mapping
private func scovilleIAPType(for productId: String) -> InAppPurchaseType {
    if productId.contains("lifetime") || productId.contains("debug") {
        return .permanent
    }
    if productId.contains("yearly") || productId.contains("monthly") {
        return .subscription
    }
    return .permanent
}

@MainActor
class InAppPurchaseManager: ObservableObject {
    static let shared = InAppPurchaseManager()
    
    @Published var products: [Product] = []
    @Published var purchaseState: PurchaseState = .idle
    @Published var isRestoring: Bool = false
    @Published var hasActiveSubscription: Bool = false
    @Published var hasEligibleOffer: Bool = false
    @Published var eligibleOfferDiscountPercent: Int? = nil
    @Published var eligibleOfferDurationText: String? = nil
    @Published var currentPurchaseInfo: PurchaseInfo = PurchaseInfo(type: .none, productID: "", transactionID: nil, purchaseDate: nil, expirationDate: nil)
    
    private var hasPreloadedProducts = false
    
    init() {
        Task {
            await checkPurchaseStatus()
            // Preload products on initialization
            await fetchAllProducts()
            hasPreloadedProducts = true
        }
        
        // Listen for transaction updates (e.g. purchases completed in background, from other devices)
        Task {
            for await update in StoreKit.Transaction.updates {
                if case .verified(let transaction) = update {
                    // Check if this is one of our products
                    let productIds = InAppPurchaseItems.allCases.map { $0.getProductId() }
                    if productIds.contains(transaction.productID) {
                        // Refresh purchase status
                        await checkPurchaseStatus()
                        // Finish the transaction
                        await transaction.finish()
                        
                        if transaction.environment == .production {
                            // Report IAP to ScovilleKit
                            Task { @MainActor in
                                Scoville.reportInAppPurchase(
                                    productId: transaction.productID,
                                    type: scovilleIAPType(for: transaction.productID)
                                ) { result in
                                    if case .failure(let error) = result {
                                        print("IAP report failed:", error)
                                    }
                                }
                            }
                        }
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
            await checkOfferEligibility()
        } catch {
            Task { @MainActor in
                Scoville.track(FuelTrackrEvents.failedToLoadProducts)
                Analytics.logEvent(FuelTrackrEvents.failedToLoadProducts.rawValue, parameters: nil)
            }
        }
    }
    
    private func checkOfferEligibility() async {
        guard !hasActiveSubscription else {
            hasEligibleOffer = false
            eligibleOfferDiscountPercent = nil
            eligibleOfferDurationText = nil
            return
        }
        var bestDiscount: Int = 0
        var foundEligible = false
        var bestDurationText: String? = nil
        for product in products {
            guard let subscription = product.subscription,
                  let offer = subscription.introductoryOffer else { continue }
            if await subscription.isEligibleForIntroOffer {
                foundEligible = true
                let discount: Int
                switch offer.paymentMode {
                case .freeTrial:
                    discount = 100
                case .payAsYouGo, .payUpFront:
                    let productPrice = NSDecimalNumber(decimal: product.price).doubleValue
                    let offerPrice = NSDecimalNumber(decimal: offer.price).doubleValue
                    if productPrice > 0, offerPrice < productPrice {
                        discount = min(99, Int(round((1 - offerPrice / productPrice) * 100)))
                    } else {
                        discount = 0
                    }
                default:
                    discount = 0
                }
                if discount > bestDiscount {
                    bestDiscount = discount
                    bestDurationText = Self.formatOfferDuration(period: offer.period, periodCount: offer.periodCount, paymentMode: offer.paymentMode)
                } else if bestDurationText == nil, discount > 0 || offer.paymentMode == .freeTrial {
                    bestDurationText = Self.formatOfferDuration(period: offer.period, periodCount: offer.periodCount, paymentMode: offer.paymentMode)
                }
            }
        }
        hasEligibleOffer = foundEligible
        eligibleOfferDiscountPercent = foundEligible && bestDiscount > 0 ? bestDiscount : nil
        eligibleOfferDurationText = foundEligible ? bestDurationText : nil
    }
    
    func purchase(product: Product) async {
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    // Update purchase status
                    await checkPurchaseStatus()
                    
                    // Finish the transaction
                    await transaction.finish()
                    
                    // Set success state
                    purchaseState = .success
                    
                    if transaction.environment == .production {
                        
                        Task { @MainActor in
                            Scoville.reportInAppPurchase(
                                productId: transaction.productID,
                                type: scovilleIAPType(for: transaction.productID)
                            ) { result in
                                if case .failure(let error) = result {
                                    print("IAP report failed:", error)
                                }
                            }
                            // Trigger review prompt after purchase
                            ReviewPrompter.shared.maybeRequestReview(reason: .purchaseDone)
                        }
                    }
                    
                    // Don't auto-reset - let user dismiss the success overlay
                } else {
                    purchaseState = .failed("Purchase verification failed")
                }
            case .userCancelled:
                purchaseState = .cancelled
                // Reset to idle after a short delay
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                purchaseState = .idle
            case .pending:
                purchaseState = .failed("Purchase is pending approval")
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                purchaseState = .idle
            @unknown default:
                purchaseState = .failed("Unknown purchase result")
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
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
            for await result in StoreKit.Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    // Check if this is one of our premium products
                    let productIds = InAppPurchaseItems.allCases.map { $0.getProductId() }
                    if productIds.contains(transaction.productID) {
                        foundActivePurchase = true
                    }
                }
            }
            
            // Update purchase status
            await checkPurchaseStatus()
            
            if foundActivePurchase {
                purchaseState = .success
                // Report restored purchase to ScovilleKit
                let productId = currentPurchaseInfo.productID
                if !productId.isEmpty {
                    Task { @MainActor in
                        Scoville.track(FuelTrackrEvents.IAPRestored)
                        Analytics.logEvent(FuelTrackrEvents.IAPRestored.rawValue, parameters: nil)
                    }
                }
                // Don't auto-reset - let user dismiss the success overlay
            } else {
                purchaseState = .failed("No previous purchases found")
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                purchaseState = .idle
            }
        } catch {
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
        var latestTransaction: StoreKit.Transaction?
        var latestTransactionDate: Date?
        
        for await result in StoreKit.Transaction.currentEntitlements {
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
        await checkOfferEligibility()
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
    
    func grantProStatus() {
        let debugProductId = "debug_lifetime_pro"
        hasActiveSubscription = true
        currentPurchaseInfo = PurchaseInfo(
            type: .lifetime,
            productID: debugProductId,
            transactionID: nil,
            purchaseDate: Date(),
            expirationDate: nil
        )
    }
    #endif
    
    func resetPurchaseState() {
        purchaseState = .idle
    }
    
    /// Formats the offer duration for display (e.g. "Valid for 7 days", "3 months at this price").
    static func formatOfferDuration(period: Product.SubscriptionPeriod, periodCount: Int, paymentMode: Product.SubscriptionOffer.PaymentMode) -> String? {
        let totalValue = periodCount * period.value
        guard totalValue > 0 else { return nil }
        
        let durationPhrase: String
        switch period.unit {
        case .day:
            durationPhrase = totalValue == 1
                ? NSLocalizedString("offer_duration_1_day", comment: "")
                : String(format: NSLocalizedString("offer_duration_n_days", comment: ""), totalValue)
        case .week:
            durationPhrase = totalValue == 1
                ? NSLocalizedString("offer_duration_1_week", comment: "")
                : String(format: NSLocalizedString("offer_duration_n_weeks", comment: ""), totalValue)
        case .month:
            durationPhrase = totalValue == 1
                ? NSLocalizedString("offer_duration_1_month", comment: "")
                : String(format: NSLocalizedString("offer_duration_n_months", comment: ""), totalValue)
        case .year:
            durationPhrase = totalValue == 1
                ? NSLocalizedString("offer_duration_1_year", comment: "")
                : String(format: NSLocalizedString("offer_duration_n_years", comment: ""), totalValue)
        @unknown default:
            return nil
        }
        
        switch paymentMode {
        case .freeTrial:
            return String(format: NSLocalizedString("offer_valid_for", comment: ""), durationPhrase)
        case .payAsYouGo, .payUpFront:
            return String(format: NSLocalizedString("offer_valid_for", comment: ""), durationPhrase)
        default:
            return String(format: NSLocalizedString("offer_valid_for", comment: ""), durationPhrase)
        }
    }
    
    #if DEBUG
    func setDebugPurchaseState(_ state: PurchaseState) {
        purchaseState = state
    }
    #endif
}
