//
//  ConfirmVehiclePurchaseUseCase.swift
//  Domain
//
//  Created by Menno Spijker on 29/05/2025.
//

import Foundation
import SwiftData

public struct ConfirmVehiclePurchaseUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(context: ModelContext) throws {
        try repository.updateVehiclePurchaseStatus(
            isPurchased: true,
            context: context
        )
    }
}
