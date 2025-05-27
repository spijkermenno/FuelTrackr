// MARK: - Package: Presentation

//
//  GenericCarousel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 22/04/2025.
//

import SwiftUI
import Domain

public struct GenericCarousel<Content: View>: View {
    public let height: CGFloat
    public let content: () -> Content

    public init(height: CGFloat = 270, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.content = content
    }

    public var body: some View {
        TabView {
            content()
                .padding(.vertical, 10)
                .padding(.horizontal)
        }
        .frame(height: height)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
