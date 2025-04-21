//
//  VehicleCarousel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI
    
struct VehicleCarousel: View {
    let viewModel: VehicleViewModel
    let photoData: Data?

    var body: some View {
        TabView {
            VehicleImageView(photoData: photoData)
                .padding(.vertical, 10)

            CurrentMonthRecapView(viewModel: viewModel)
                .padding(.vertical, 10)
                .padding(.leading, 10)
        }
        .frame(height: 260)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
    }
}
