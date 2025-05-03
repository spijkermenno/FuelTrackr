//
//  NoActiveVehicleView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI
import Domain


public struct NoActiveVehicleView: View {
    public var body: some View {
        Text(NSLocalizedString("no_active_vehicle_found", comment: "No active vehicle message"))
            .foregroundColor(.primary)
    }
}
