//
//  OfferBannerView.swift
//  FuelTrackr
//
//  Banner shown to non-premium users when an IAP offer is available. Uses same styling as paywall.
//

import SwiftUI

struct OfferBannerView: View {
    let onTap: () -> Void
    /// Discount percentage to display (e.g. 40 for "40% off"). 100 shows "Free trial". nil shows no discount badge.
    var discountPercent: Int? = nil
    
    private var discountText: String? {
        guard let p = discountPercent, p > 0 else { return nil }
        if p >= 100 {
            return NSLocalizedString("offer_free_trial", comment: "")
        }
        return String(format: NSLocalizedString("offer_discount_percent", comment: ""), p)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(NSLocalizedString("offer_reason_introductory", comment: ""))
                    .font(.system(size: 14, weight: .heavy))
                    .textCase(.uppercase)
                    .tracking(0.5)
                if let discount = discountText {
                    Text("•")
                        .opacity(0.8)
                    Text(discount)
                        .font(.system(size: 14, weight: .heavy))
                        .textCase(.uppercase)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.9)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 31, style: .continuous)
                    .fill(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .shadow(color: Color.purple.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Offer Banner") {
    VStack(spacing: 16) {
        OfferBannerView(onTap: {}, discountPercent: 40)
        OfferBannerView(onTap: {}, discountPercent: 100)
        OfferBannerView(onTap: {})
    }
    .padding()
}
