//
//  Typography.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


// Typography.swift
// Handles all font sizes, weights, and reusable text styles

import SwiftUI

struct Typography {
    // MARK: - Font Sizes
    static let caption: CGFloat = 12
    static let footnote: CGFloat = 14
    static let body: CGFloat = 16
    static let subheadline: CGFloat = 18
    static let headline: CGFloat = 20
    static let title: CGFloat = 24
    static let largeTitle: CGFloat = 32
    
    // MARK: - Text Styles
    let captionFont = Font.system(size: caption)
    let footnoteFont = Font.system(size: footnote)
    let bodyFont = Font.system(size: body)
    let subheadlineFont = Font.system(size: subheadline, weight: .medium)
    let headlineFont = Font.system(size: headline, weight: .semibold)
    let titleFont = Font.system(size: title, weight: .bold)
    let largeTitleFont = Font.system(size: largeTitle, weight: .bold)
}
