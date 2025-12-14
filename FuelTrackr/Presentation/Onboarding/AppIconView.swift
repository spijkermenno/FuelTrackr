//
//  AppIconView.swift
//  FuelTrackr
//
//  Safely displays the app icon in-app, handling iOS 26 compatibility issues
//  Based on: https://www.simplykyra.com/blog/how-to-safely-display-your-app-icon-in-app-ios-macos-pre-26-and-26/
//

import SwiftUI
import UIKit

public struct AppIconView: View {
    public var placeholderIconName: String = "AppIcon" // primary try
    public var placeholderIconBackupName: String = "AppIconBackup" // fallback
    
    public init(setIconName: String? = nil, setBackupName: String? = nil) {
        if let thisName = setIconName, !thisName.isEmpty {
            placeholderIconName = thisName
        }
        if let thisName = setBackupName, !thisName.isEmpty {
            placeholderIconBackupName = thisName
        }
    }
    
    var resolvedImage: UIImage? {
        // Try primary name first
        if let primary = UIImage(named: placeholderIconName) {
            return primary
        }
        // Try Bundle.main.iconFileName as fallback
        if let fallbackName = Bundle.main.iconFileName,
           let fallback = UIImage(named: fallbackName) {
            return fallback
        }
        // Try backup name
        if let backup = UIImage(named: placeholderIconBackupName) {
            return backup
        }
        return nil
    }
    
    public var body: some View {
        Group {
            if let iconImage = resolvedImage {
                Image(uiImage: iconImage)
                    .resizable()
            } else {
                // Fallback: Use a styled placeholder that matches the app theme
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [OnboardingColors.primaryBlue, OnboardingColors.primaryBlue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "fuelpump.fill")
                        .font(.system(size: 50))
                        .foregroundColor(OnboardingColors.white)
                }
            }
        }
    }
}

// Extension to safely get icon file name from bundle
extension Bundle {
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String] else {
            return nil
        }
        return iconFiles.last
    }
}
