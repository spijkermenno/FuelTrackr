//
//  InAppPurchasePayWall.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/01/2026.
//

import SwiftUI
import FirebaseAnalytics
import StoreKit
import ScovilleKit

struct InAppPurchasePayWall: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var inAppPurchaseManager = InAppPurchaseManager.shared

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
                            Text(NSLocalizedString("pro_title", comment: ""))
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .tracking(-0.5)
                            
                            Text(NSLocalizedString("pro_subtitle", comment: ""))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)

                    // 2. Feature Cards Section
                    VStack(spacing: 14) {
                        CleanFeatureCard(title: NSLocalizedString("pro_feature_unlimited_history_title", comment: ""), subtitle: NSLocalizedString("pro_feature_unlimited_history_subtitle", comment: ""), icon: "chart.line.uptrend.xyaxis", accentColor: .purple)
                        CleanFeatureCard(title: NSLocalizedString("pro_feature_smart_maintenance_title", comment: ""), subtitle: NSLocalizedString("pro_feature_smart_maintenance_subtitle", comment: ""), icon: "wrench.and.screwdriver.fill", accentColor: .teal)
                        CleanFeatureCard(title: NSLocalizedString("pro_feature_smart_refill_title", comment: ""), subtitle: NSLocalizedString("pro_feature_smart_refill_subtitle", comment: ""), icon: "brain.fill", accentColor: .orange)
                    }
                    .opacity(inAppPurchaseManager.purchaseState == .purchasing ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: inAppPurchaseManager.purchaseState)
                    
                    // 3. Purchase Section
                    VStack(spacing: 16) {
                        if inAppPurchaseManager.products.isEmpty {
                            // Loading state
                            FakeProPurchaseButton()
                                .redacted(reason: .placeholder)
                        } else {
                            // Sort products: Lifetime -> Yearly -> Monthly
                            ForEach(inAppPurchaseManager.products.sorted(by: { $0.price > $1.price }), id: \.id) { product in
                                ProPurchaseButton(
                                    product: product,
                                    isLoading: inAppPurchaseManager.purchaseState == .purchasing
                                ) {
                                    Task {
                                        await inAppPurchaseManager.purchase(product: product)
                                    }
                                }
                                .disabled(inAppPurchaseManager.purchaseState == .purchasing || inAppPurchaseManager.isRestoring)
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    // 4. Footer Section
                    VStack(spacing: 15) {
                        HStack {
                            if inAppPurchaseManager.isRestoring {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .padding(.trailing, 8)
                            }
                            Button(NSLocalizedString("restore_purchase", comment: "")) {
                                Task {
                                    await inAppPurchaseManager.restorePurchases()
                                }
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.blue)
                            .disabled(inAppPurchaseManager.purchaseState == .purchasing || inAppPurchaseManager.isRestoring)
                        }
                        
                        // Error/Success message
                        if case .failed(let message) = inAppPurchaseManager.purchaseState {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        HStack(spacing: 12) {
                            Button(NSLocalizedString("privacy_policy", comment: "")) {
                                if let url = URL(string: "https://pepper-technologies.nl/privacy-statement/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            Text("•")
                                .foregroundColor(.secondary)
                            Button(NSLocalizedString("terms_of_service", comment: "")) {
                                if let url = URL(string: "https://pepper-technologies.nl/terms-of-use/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 22)
            }
            .blur(radius: inAppPurchaseManager.purchaseState == .purchasing ? 2 : 0)
            .animation(.easeInOut(duration: 0.3), value: inAppPurchaseManager.purchaseState)
            
            // Purchase Overlay (transitions from loading to success)
            if inAppPurchaseManager.purchaseState == .purchasing || inAppPurchaseManager.purchaseState == .success {
                PurchaseOverlay(
                    state: inAppPurchaseManager.purchaseState,
                    onDismiss: {
                        inAppPurchaseManager.resetPurchaseState()
                        dismiss()
                    }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .task {
            // Only fetch if products haven't been preloaded
            if inAppPurchaseManager.products.isEmpty {
                await inAppPurchaseManager.fetchAllProducts()
            }
        }
        .onAppear {
            // Track paywall shown
            Task { @MainActor in
                let params: [String: Any] = [
                    "has_active_subscription": inAppPurchaseManager.hasActiveSubscription ? "true" : "false",
                    "product_count": String(inAppPurchaseManager.products.count)
                ]
                Scoville.track(FuelTrackrEvents.paywallShown, parameters: params)
                Analytics.logEvent(FuelTrackrEvents.paywallShown.rawValue, parameters: params)
            }
        }
        .onDisappear {
            // Track paywall dismissed
            Task { @MainActor in
                Scoville.track(FuelTrackrEvents.paywallDismissed)
                Analytics.logEvent(FuelTrackrEvents.paywallDismissed.rawValue, parameters: nil)
            }
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

// MARK: - Product Display Model (for previews and presentation abstraction)
struct ProductDisplayModel: Identifiable {
    let id: String
    let title: String
    let billingDescription: String
    let displayPrice: String
    let salePrice: String?
    let showOfferReason: Bool
    let isYearly: Bool
    let isLifetime: Bool
}

// MARK: - Premium Purchase Button Content (presentational, usable with mock data)
struct ProPurchaseButtonContent: View {
    let model: ProductDisplayModel
    let isLoading: Bool
    let action: () -> Void
    
    private var buttonColor: Color {
        model.isLifetime ? .purple : .blue
    }
    
    private var buttonGradient: LinearGradient {
        if model.isLifetime {
            return LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.blue.opacity(0.9), .blue], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                if model.showOfferReason {
                    HStack(spacing: 6) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(NSLocalizedString("offer_reason_introductory", comment: ""))
                            .font(.system(size: 13, weight: .heavy))
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.25))
                }
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(model.title)
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                            
                            if model.isYearly {
                                Text(NSLocalizedString("pro_best_value_badge", comment: ""))
                                    .font(.system(size: 10, weight: .heavy))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Text(model.billingDescription)
                            .font(.system(size: 12, weight: .medium))
                            .opacity(0.85)
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        priceView
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(buttonGradient)
                    .opacity(isLoading ? 0.7 : 1.0)
            )
            .shadow(color: buttonColor.opacity(isLoading ? 0.15 : 0.3), radius: 12, y: 6)
        }
        .disabled(isLoading)
    }
    
    @ViewBuilder
    private var priceView: some View {
        if let salePrice = model.salePrice {
            VStack(alignment: .trailing, spacing: 2) {
                Text(model.displayPrice)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .strikethrough(true, color: .white.opacity(0.8))
                Text(salePrice)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
            }
        } else {
            Text(model.displayPrice)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
        }
    }
}

// MARK: - Premium Purchase Button (wraps Product, loads offer async)
struct ProPurchaseButton: View {
    let product: Product
    let isLoading: Bool
    let action: () -> Void
    
    @State private var displayModel: ProductDisplayModel?
    
    var body: some View {
        let model = displayModel ?? ProductDisplayModel(
            id: product.id,
            title: cleanTitle,
            billingDescription: billingDescription,
            displayPrice: product.displayPrice,
            salePrice: nil,
            showOfferReason: false,
            isYearly: product.id.contains("yearly"),
            isLifetime: product.id.contains("lifetime")
        )
        ProPurchaseButtonContent(model: model, isLoading: isLoading, action: action)
            .task {
                let baseModel = ProductDisplayModel(
                    id: product.id,
                    title: cleanTitle,
                    billingDescription: billingDescription,
                    displayPrice: product.displayPrice,
                    salePrice: nil,
                    showOfferReason: false,
                    isYearly: product.id.contains("yearly"),
                    isLifetime: product.id.contains("lifetime")
                )
                guard let subscription = product.subscription,
                      let offer = subscription.introductoryOffer else {
                    displayModel = baseModel
                    return
                }
                if await subscription.isEligibleForIntroOffer {
                    displayModel = ProductDisplayModel(
                        id: product.id,
                        title: cleanTitle,
                        billingDescription: billingDescription,
                        displayPrice: product.displayPrice,
                        salePrice: offer.displayPrice,
                        showOfferReason: true,
                        isYearly: product.id.contains("yearly"),
                        isLifetime: product.id.contains("lifetime")
                    )
                } else {
                    displayModel = baseModel
                }
            }
    }
    
    private var cleanTitle: String {
        if product.id.contains("lifetime") { return NSLocalizedString("pro_lifetime_title", comment: "") }
        if product.id.contains("yearly") { return NSLocalizedString("pro_yearly_title", comment: "") }
        if product.id.contains("monthly") { return NSLocalizedString("pro_monthly_title", comment: "") }
        return product.displayName
    }
    
    private var billingDescription: String {
        if product.type == .nonConsumable { return NSLocalizedString("pro_one_time_payment", comment: "") }
        if product.id.contains("yearly") { return NSLocalizedString("pro_billed_annually", comment: "") }
        return NSLocalizedString("pro_billed_monthly", comment: "")
    }
}

// MARK: - Loading Skeleton
struct FakeProPurchaseButton: View {
    var body: some View {
        HStack {
            Text(NSLocalizedString("pro_unlock_lifetime", comment: ""))
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

// MARK: - Purchase Overlay (Unified Loading/Success)
struct PurchaseOverlay: View {
    let state: PurchaseState
    let onDismiss: () -> Void
    
    @State private var rotation: Double = 0
    @State private var checkmarkScale: CGFloat = 0
    @State private var showSuccessContent = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icon/Spinner Container - same size for both states
                ZStack {
                    // Background circle (always present)
                    Circle()
                        .fill(state == .success ? Color.green.opacity(0.2) : Color.clear)
                        .frame(width: 80, height: 80)
                    
                    // Loading spinner (only when purchasing)
                    if state == .purchasing {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(rotation))
                            .onAppear {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    rotation = 360
                                }
                            }
                    }
                    
                    // Success checkmark (only when success)
                    if state == .success {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                            .scaleEffect(checkmarkScale)
                            .onAppear {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    checkmarkScale = 1.0
                                }
                            }
                    }
                }
                .frame(width: 80, height: 80)
                .animation(.easeInOut(duration: 0.3), value: state)
                
                // Text Content - maintain consistent height
                VStack(spacing: 8) {
                    if state == .purchasing {
                        Text(NSLocalizedString("pro_processing_purchase", comment: ""))
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(height: 22) // Match approximate height of success title
                    } else if state == .success {
                        VStack(spacing: 8) {
                            Text(NSLocalizedString("pro_purchase_successful", comment: ""))
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(NSLocalizedString("pro_thank_you_message", comment: ""))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .frame(minHeight: 50) // Ensure consistent height
                .animation(.easeInOut(duration: 0.3), value: state)
                
                // Continue Button (only for success)
                if state == .success {
                    Button(action: onDismiss) {
                        Text(NSLocalizedString("continue_button", comment: ""))
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.blue)
                            )
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(40)
            .frame(maxWidth: 320) // Constrain width to match processing state
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        }
        .onChange(of: state) { oldValue, newValue in
            if newValue == .success {
                // Reset rotation when transitioning to success
                rotation = 0
            }
        }
    }
}

// MARK: - Preview View (uses mock data, no StoreKit/network)
struct PaywallPreviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var purchaseState: PurchaseState = .idle
    @State private var isRestoring = false
    
    let products: [ProductDisplayModel]
    
    var body: some View {
        ZStack {
            Color(colorScheme == .light ? UIColor.systemGroupedBackground : .black)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        ResizableAppIconView(size: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: .blue.opacity(0.15), radius: 20, y: 10)
                        
                        VStack(spacing: 6) {
                            Text(NSLocalizedString("pro_title", comment: ""))
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .tracking(-0.5)
                            Text(NSLocalizedString("pro_subtitle", comment: ""))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)

                    VStack(spacing: 14) {
                        CleanFeatureCard(title: NSLocalizedString("pro_feature_unlimited_history_title", comment: ""), subtitle: NSLocalizedString("pro_feature_unlimited_history_subtitle", comment: ""), icon: "chart.line.uptrend.xyaxis", accentColor: .purple)
                        CleanFeatureCard(title: NSLocalizedString("pro_feature_smart_maintenance_title", comment: ""), subtitle: NSLocalizedString("pro_feature_smart_maintenance_subtitle", comment: ""), icon: "wrench.and.screwdriver.fill", accentColor: .teal)
                        CleanFeatureCard(title: NSLocalizedString("pro_feature_smart_refill_title", comment: ""), subtitle: NSLocalizedString("pro_feature_smart_refill_subtitle", comment: ""), icon: "brain.fill", accentColor: .orange)
                    }
                    .opacity(purchaseState == .purchasing ? 0.5 : 1.0)

                    VStack(spacing: 16) {
                        if products.isEmpty {
                            FakeProPurchaseButton()
                                .redacted(reason: .placeholder)
                        } else {
                            ForEach(products) { product in
                                ProPurchaseButtonContent(
                                model: product,
                                isLoading: purchaseState == .purchasing
                            ) {
                                purchaseState = .purchasing
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    purchaseState = .success
                                }
                            }
                            .disabled(purchaseState == .purchasing || isRestoring)
                            }
                        }
                    }
                    .padding(.top, 8)

                    VStack(spacing: 15) {
                        HStack {
                            if isRestoring {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .padding(.trailing, 8)
                            }
                            Button(NSLocalizedString("restore_purchase", comment: "")) {
                                isRestoring = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isRestoring = false
                                }
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.blue)
                            .disabled(purchaseState == .purchasing || isRestoring)
                        }
                        HStack(spacing: 12) {
                            Button(NSLocalizedString("privacy_policy", comment: "")) { }
                            Text("•").foregroundColor(.secondary)
                            Button(NSLocalizedString("terms_of_service", comment: "")) { }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 22)
            }
            .blur(radius: purchaseState == .purchasing ? 2 : 0)

            if purchaseState == .purchasing || purchaseState == .success {
                PurchaseOverlay(
                    state: purchaseState,
                    onDismiss: { purchaseState = .idle }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

#Preview("Paywall - Standard") {
    PaywallPreviewView(products: [
        ProductDisplayModel(id: "pro_lifetime", title: NSLocalizedString("pro_lifetime_title", comment: ""), billingDescription: NSLocalizedString("pro_one_time_payment", comment: ""), displayPrice: "€49.99", salePrice: nil, showOfferReason: false, isYearly: false, isLifetime: true),
        ProductDisplayModel(id: "pro_yearly", title: NSLocalizedString("pro_yearly_title", comment: ""), billingDescription: NSLocalizedString("pro_billed_annually", comment: ""), displayPrice: "€29.99", salePrice: nil, showOfferReason: false, isYearly: true, isLifetime: false),
        ProductDisplayModel(id: "pro_monthly", title: NSLocalizedString("pro_monthly_title", comment: ""), billingDescription: NSLocalizedString("pro_billed_monthly", comment: ""), displayPrice: "€4.99", salePrice: nil, showOfferReason: false, isYearly: false, isLifetime: false),
    ])
}

#Preview("Paywall - With Offers") {
    PaywallPreviewView(products: [
        ProductDisplayModel(id: "pro_lifetime", title: NSLocalizedString("pro_lifetime_title", comment: ""), billingDescription: NSLocalizedString("pro_one_time_payment", comment: ""), displayPrice: "€49.99", salePrice: "€29.99", showOfferReason: true, isYearly: false, isLifetime: true),
        ProductDisplayModel(id: "pro_yearly", title: NSLocalizedString("pro_yearly_title", comment: ""), billingDescription: NSLocalizedString("pro_billed_annually", comment: ""), displayPrice: "€29.99", salePrice: "€19.99", showOfferReason: true, isYearly: true, isLifetime: false),
        ProductDisplayModel(id: "pro_monthly", title: NSLocalizedString("pro_monthly_title", comment: ""), billingDescription: NSLocalizedString("pro_billed_monthly", comment: ""), displayPrice: "€4.99", salePrice: "€1.99", showOfferReason: true, isYearly: false, isLifetime: false),
    ])
}

#Preview("Paywall - Loading") {
    PaywallPreviewView(products: [])
}
