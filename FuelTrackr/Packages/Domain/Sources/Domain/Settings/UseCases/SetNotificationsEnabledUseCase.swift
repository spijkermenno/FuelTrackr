// MARK: - Package: Domain

//
//  SetNotificationsEnabledUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct SetNotificationsEnabledUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }
    
    public func callAsFunction(_ enabled: Bool) {
        repository.setNotificationsEnabled(enabled)
    }
}
