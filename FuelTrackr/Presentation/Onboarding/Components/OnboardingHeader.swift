//
//  OnboardingHeader.swift
//  FuelTrackr
//
//  Header component with title and description for onboarding steps
//

import SwiftUI

public struct OnboardingHeader: View {
    let title: String
    let description: String?
    let titleFontSize: CGFloat
    let descriptionFontSize: CGFloat
    let spacing: CGFloat
    let descriptionHorizontalPadding: CGFloat
    
    public init(
        title: String,
        description: String? = nil,
        titleFontSize: CGFloat = 32,
        descriptionFontSize: CGFloat = 17,
        spacing: CGFloat = 12,
        descriptionHorizontalPadding: CGFloat = 32
    ) {
        self.title = title
        self.description = description
        self.titleFontSize = titleFontSize
        self.descriptionFontSize = descriptionFontSize
        self.spacing = spacing
        self.descriptionHorizontalPadding = descriptionHorizontalPadding
    }
    
    public var body: some View {
        VStack(spacing: spacing) {
            Text(title)
                .font(.system(size: titleFontSize, weight: .bold))
                .foregroundColor(OnboardingColors.primaryText)
                .multilineTextAlignment(.center)
            
            if let description = description {
                Text(description)
                    .font(.system(size: descriptionFontSize, weight: .regular))
                    .foregroundColor(OnboardingColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, descriptionHorizontalPadding)
            }
        }
    }
}
