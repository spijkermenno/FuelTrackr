//
//  Card.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 29/05/2025.
//

import SwiftUI

struct Card<Header: View, Content: View>: View {
    let header: () -> Header
    let content: () -> Content
    
    init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header()
            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Theme.dimensions.radiusCard)
        .frame(maxWidth: .infinity)
    }
}
