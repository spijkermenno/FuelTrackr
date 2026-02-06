//
//  InAppPurchaseItems.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 15/01/2026.
//

enum InAppPurchaseItems: CaseIterable {
    case FullPremiumLifeTime
    case PremiumMonthly
    case PremiumYearly
    
    func getProductId() -> String {
        switch self {
        case .FullPremiumLifeTime:
            return "pro_lifetime"
        case .PremiumMonthly:
            return "pro_monthly"
        case .PremiumYearly:
            return "pro_yearly"
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .FullPremiumLifeTime:
            return "Full Premium Unlock" // Replace with L18N
        case .PremiumMonthly:
            return "Montly"
        case .PremiumYearly:
            return "Yearly"
        }
    }
    
    func getDescription() -> String {
        switch self {
        case .FullPremiumLifeTime:
            return "Unlock all features" // Replace with L18N
        case .PremiumMonthly:
            return "Monthly Des"
        case .PremiumYearly:
            return "Yearly Des"
        }
    }
}
