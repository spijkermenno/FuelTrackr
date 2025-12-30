//
//  VehicleBrands.swift
//  FuelTrackr
//
//  Common vehicle brands list
//

import Foundation

public struct VehicleBrands {
    public static let brands: [String] = [
        "Acura",
        "Alfa Romeo",
        "Aston Martin",
        "Audi",
        "Bentley",
        "BMW",
        "Buick",
        "Cadillac",
        "Chevrolet",
        "Chrysler",
        "Citroën",
        "Dodge",
        "Ferrari",
        "Fiat",
        "Ford",
        "Genesis",
        "GMC",
        "Honda",
        "Hyundai",
        "Infiniti",
        "Jaguar",
        "Jeep",
        "Kia",
        "Lamborghini",
        "Land Rover",
        "Lexus",
        "Lincoln",
        "Maserati",
        "Mazda",
        "McLaren",
        "Mercedes-Benz",
        "Mini",
        "Mitsubishi",
        "Nissan",
        "Peugeot",
        "Porsche",
        "Ram",
        "Renault",
        "Rolls-Royce",
        "SEAT",
        "Škoda",
        "Subaru",
        "Suzuki",
        "Tesla",
        "Toyota",
        "Volkswagen",
        "Volvo"
    ]
    
    public static func searchBrands(query: String) -> [String] {
        guard !query.isEmpty else { return brands }
        let lowercasedQuery = query.lowercased()
        return brands.filter { $0.lowercased().contains(lowercasedQuery) }
    }
}


