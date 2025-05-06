//
//  RefreshingView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI
import Domain


public struct RefreshingView: View {
    public var body: some View {
        VStack {
            ProgressView(NSLocalizedString("refreshing", comment: "Refreshing message"))
                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                .padding()
                .cornerRadius(12)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
