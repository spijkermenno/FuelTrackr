//
//  GenericCarousel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 22/04/2025.
//


import SwiftUI

struct GenericCarousel<Content: View>: View {
    let height: CGFloat
    let content: () -> Content

    init(height: CGFloat = 270, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.content = content
    }

    var body: some View {
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