// MARK: - Package: Presentation

//
//  Typography.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//
//  Handles all font sizes, weights, and reusable text styles

import SwiftUI

public struct Typography: Sendable {
    // MARK: - Font Sizes
    public static let caption: CGFloat = 12
    public static let footnote: CGFloat = 14
    public static let body: CGFloat = 16
    public static let subheadline: CGFloat = 18
    public static let headline: CGFloat = 20
    public static let title: CGFloat = 24
    public static let largeTitle: CGFloat = 32

    // MARK: - Text Styles
    public let captionFont = Font.system(size: caption)
    public let footnoteFont = Font.system(size: footnote)
    public let bodyFont = Font.system(size: body)
    public let subheadlineFont = Font.system(size: subheadline, weight: .medium)
    public let headlineFont = Font.system(size: headline, weight: .semibold)
    public let titleFont = Font.system(size: title, weight: .bold)
    public let largeTitleFont = Font.system(size: largeTitle, weight: .bold)
}
