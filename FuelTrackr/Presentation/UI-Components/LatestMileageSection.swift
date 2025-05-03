//
//  LatestMileageSection.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/05/2025.
//

import SwiftUI
import Domain

public struct LatestMileageSection: View {
    let vehicle: Vehicle?
    let isMetric: Bool
    
    public var body: some View {
        let latestMileage = vehicle?.mileages.sorted(by: { $0.date > $1.date }).first
        
        HStack {
            Text(NSLocalizedString("latest_mileage", comment: ""))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let mileage = latestMileage {
                Text(isMetric ? "\(mileage.value) km" : "\(Int(Double(mileage.value) / 1.60934)) mi")
                    .foregroundColor(.primary)
            } else {
                Text(NSLocalizedString("no_mileage_recorded", comment: ""))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}
