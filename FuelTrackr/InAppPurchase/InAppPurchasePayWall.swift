//
//  InAppPurchasePayWall.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/01/2026.
//

import SwiftUI
import StoreKit

struct InAppPurchasePayWall: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var inAppPurchaseManager = InAppPurchaseManager()

    var body: some View {
        ZStack {
            // High-contrast background for 2026 clarity
            Color(colorScheme == .light ? UIColor.systemGroupedBackground : .black)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // 1. Header Section
                    VStack(spacing: 16) {
                        ResizableAppIconView(size: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: .blue.opacity(0.15), radius: 20, y: 10)
                        
                        VStack(spacing: 6) {
                            Text("FuelTrackr Pro")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .tracking(-0.5)
                            
                            Text("The Future of Vehicle Intelligence")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)

                    // 2. Feature Cards Section
                    VStack(spacing: 14) {
                        CleanFeatureCard(title: "Unlimited History", subtitle: "Total expense transparency", icon: "chart.line.uptrend.xyaxis", accentColor: .purple)
                        CleanFeatureCard(title: "Smart Maintenance", subtitle: "AI-driven service alerts", icon: "wrench.and.screwdriver.fill", accentColor: .teal)
                        CleanFeatureCard(title: "AI Refill Logic", subtitle: "Predictive range & cost insights", icon: "brain.fill", accentColor: .orange)
                    }
                    
                    // 3. Purchase Section
                    VStack(spacing: 16) {
                        if inAppPurchaseManager.products.isEmpty {
                            // Loading state
                            FakeProPurchaseButton()
                                .redacted(reason: .placeholder)
                        } else {
                            // Sort products: Lifetime -> Yearly -> Monthly
                            ForEach(inAppPurchaseManager.products.sorted(by: { $0.price > $1.price }), id: \.id) { product in
                                ProPurchaseButton(product: product) {
                                    Task {
                                        await inAppPurchaseManager.purchase(product: product)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    // 4. Footer Section
                    VStack(spacing: 15) {
                        Button("Restore Purchase") {
                            Task {
                                try? await AppStore.sync()
                            }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.blue)
                        
                        HStack(spacing: 12) {
                            Button("Privacy Policy") {
                                // Action for Privacy Policy
                            }
                            Text("•")
                                .foregroundColor(.secondary)
                            Button("Terms of Service") {
                                // Action for TOS
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 22)
            }
        }
        .task {
            await inAppPurchaseManager.fetchAllProducts()
        }
    }
}

// MARK: - Feature Card View
struct CleanFeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.all, 16)
        .background(colorScheme == .light ? Color.white : Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
    }
}

// MARK: - Premium Purchase Button
struct ProPurchaseButton: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(cleanTitle)
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                        
                        // Yearly Badge
                        if product.id.contains("yearly") {
                            Text("BEST VALUE")
                                .font(.system(size: 10, weight: .heavy))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(billingDescription)
                        .font(.system(size: 12, weight: .medium))
                        .opacity(0.8)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(buttonGradient)
            )
            .shadow(color: buttonColor.opacity(0.3), radius: 12, y: 6)
        }
    }
    
    private var cleanTitle: String {
        if product.id.contains("lifetime") { return "Lifetime Pro" }
        if product.id.contains("yearly") { return "Yearly Access" }
        if product.id.contains("monthly") { return "Monthly Access" }
        return product.displayName
    }
    
    private var billingDescription: String {
        if product.type == .nonConsumable { return "One-time payment" }
        if product.id.contains("yearly") { return "Billed annually" }
        return "Billed monthly"
    }
    
    private var buttonColor: Color {
        product.id.contains("lifetime") ? .purple : .blue
    }
    
    private var buttonGradient: LinearGradient {
        if product.id.contains("lifetime") {
            return LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.blue.opacity(0.9), .blue], startPoint: .leading, endPoint: .trailing)
        }
    }
}

// MARK: - Loading Skeleton
struct FakeProPurchaseButton: View {
    var body: some View {
        HStack {
            Text("Unlock Lifetime Pro")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Spacer()
            Text("$24.99")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .foregroundColor(.white)
        .background(Capsule().fill(Color.gray.opacity(0.3)))
    }
}

#Preview {
    InAppPurchasePayWall()
}
