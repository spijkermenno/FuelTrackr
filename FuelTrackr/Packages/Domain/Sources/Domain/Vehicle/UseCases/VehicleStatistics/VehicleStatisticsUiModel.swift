//
//  VehicleStatisticsUiModel.swift
//  Domain
//
//  Created by Menno Spijker on 29/05/2025.
//

import Foundation

public struct VehicleStatisticsUiModel: Identifiable {
    public var id: UUID = UUID()
    public var period: VehicleStatisticsPeriod
    public var distanceDriven: Double
    public var fuelUsed: Double
    public var totalCost: Double
    
    // public member-wise init
    public init(
        id: UUID = UUID(),
        period: VehicleStatisticsPeriod,
        distanceDriven: Double,
        fuelUsed: Double,
        totalCost: Double
    ) {
        self.id = id
        self.period = period
        self.distanceDriven = distanceDriven
        self.fuelUsed = fuelUsed
        self.totalCost = totalCost
    }
}
