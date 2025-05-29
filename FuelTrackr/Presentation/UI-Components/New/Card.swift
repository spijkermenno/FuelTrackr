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
        .background(Color.white)
        .cornerRadius(Theme.dimensions.radiusCard)
        .shadow(color: Color.black.opacity(0.1),radius: 6,x: 0,y: 0)
        .frame(maxWidth: .infinity)
    }
}
