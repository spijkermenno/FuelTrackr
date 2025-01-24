//
//  EmptyStateView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Text("No vehicles found")
                .font(.title)
                .padding(.bottom)
            Text("Please add a vehicle to get started.")
                .font(.subheadline)
        }
        .padding()
    }
}
