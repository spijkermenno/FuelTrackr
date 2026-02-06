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
    @StateObject private var inAppPurchaseManager = InAppPurchaseManager.shared

    var body: some View {
        ZStack {
            // High-contrast background for 2026 clarity
            Color(colorScheme == .light ? UIColor.systemGroupedBackground : .black)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Debug buttons (only in DEBUG builds)
                    #if DEBUG
                    DebugPurchaseButtons(manager: inAppPurchaseManager)
                        .padding(.top, 8)
                    #endif
                    
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
                            Button("Restore Purchase") {
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
    let isLoading: Bool
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
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(product.displayPrice)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
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
                        Text("Processing Purchase...")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(height: 22) // Match approximate height of success title
                    } else if state == .success {
                        VStack(spacing: 8) {
                            Text("Purchase Successful!")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Thank you for upgrading to Pro")
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
                        Text("Continue")
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

// MARK: - Debug Purchase Buttons
#if DEBUG
struct DebugPurchaseButtons: View {
    @ObservedObject var manager: InAppPurchaseManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text("DEBUG MODE")
                .font(.caption2)
                .foregroundColor(.orange)
                .fontWeight(.bold)
            
            HStack(spacing: 8) {
                Button("Success") {
                    manager.setDebugPurchaseState(.success)
                }
                .buttonStyle(DebugButtonStyle(color: .green))
                
                Button("Failed") {
                    manager.setDebugPurchaseState(.failed("Debug: Purchase failed"))
                }
                .buttonStyle(DebugButtonStyle(color: .red))
                
                Button("Cancelled") {
                    manager.setDebugPurchaseState(.cancelled)
                }
                .buttonStyle(DebugButtonStyle(color: .orange))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct DebugButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
#endif

#Preview {
    InAppPurchasePayWall()
}
