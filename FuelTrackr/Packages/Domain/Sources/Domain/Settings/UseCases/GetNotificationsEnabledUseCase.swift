// MARK: - Package: Domain

//
//  GetNotificationsEnabledUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct GetNotificationsEnabledUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }
    
    public func callAsFunction() -> Bool {
        repository.isNotificationsEnabled()
    }
}
