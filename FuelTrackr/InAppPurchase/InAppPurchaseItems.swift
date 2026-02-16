//
//  InAppPurchaseItems.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 15/01/2026.
//

import Foundation

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
            return NSLocalizedString("pro_lifetime_title", comment: "")
        case .PremiumMonthly:
            return NSLocalizedString("pro_monthly_title", comment: "")
        case .PremiumYearly:
            return NSLocalizedString("pro_yearly_title", comment: "")
        }
    }
    
    func getDescription() -> String {
        switch self {
        case .FullPremiumLifeTime:
            return NSLocalizedString("pro_feature_unlimited_history_subtitle", comment: "")
        case .PremiumMonthly:
            return NSLocalizedString("pro_billed_monthly", comment: "")
        case .PremiumYearly:
            return NSLocalizedString("pro_billed_annually", comment: "")
        }
    }
}
