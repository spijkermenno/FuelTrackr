//
//  Card.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 29/05/2025.
//

import SwiftUI

struct Card<Header: View, Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let header: () -> Header
    let content: () -> Content
    
    init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.content = content
    }
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header()
            content()
        }
        .padding()
        .background(colors.surface)
        .cornerRadius(Theme.dimensions.radiusCard)
        .frame(maxWidth: .infinity)
    }
}
