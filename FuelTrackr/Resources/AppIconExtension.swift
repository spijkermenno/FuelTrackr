//
//  AppIconExtension.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 16/01/2026.
//

import Foundation
import UIKit
import SwiftUI

extension Bundle {
    var appIcon: UIImage? {
        // Looks into the Info.plist to find the primary icon file name
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }
}

struct ResizableAppIconView: View {
    var size: CGFloat = 100
    
    func getCornerRadius() -> CGFloat {
        return size * 0.225
    }
    
    var body: some View {
        if let uiImage = Bundle.main.appIcon {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: getCornerRadius(), style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: getCornerRadius(), style: .continuous)
                        .stroke(.black.opacity(0.1), lineWidth: 0.5)
                )
        }
    }
}
