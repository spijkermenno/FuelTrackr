//
//  VehicleModels.swift
//  FuelTrackr
//
//  Vehicle models organized by brand
//

import Foundation

public struct VehicleModels {
    // Popular models by brand - this is a simplified list
    // In a production app, you might want to use an API or more comprehensive data
    public static let modelsByBrand: [String: [String]] = [
        "Audi": ["A3", "A4", "A5", "A6", "A7", "A8", "Q3", "Q5", "Q7", "Q8", "e-tron", "TT", "R8"],
        "BMW": ["1 Series", "2 Series", "3 Series", "4 Series", "5 Series", "6 Series", "7 Series", "X1", "X3", "X5", "X7", "i3", "i4", "iX"],
        "Mercedes-Benz": ["A-Class", "B-Class", "C-Class", "E-Class", "S-Class", "GLA", "GLB", "GLC", "GLE", "GLS", "EQC", "EQS"],
        "Toyota": ["Camry", "Corolla", "RAV4", "Highlander", "Prius", "Sienna", "Tacoma", "Tundra", "4Runner", "Land Cruiser", "Yaris", "C-HR"],
        "Honda": ["Civic", "Accord", "CR-V", "Pilot", "HR-V", "Passport", "Ridgeline", "Odyssey", "Insight", "Fit"],
        "Ford": ["F-150", "Mustang", "Explorer", "Escape", "Edge", "Expedition", "Ranger", "Bronco", "Focus", "Fusion"],
        "Volkswagen": ["Golf", "Jetta", "Passat", "Tiguan", "Atlas", "Arteon", "ID.4", "Polo", "T-Cross", "Touareg"],
        "Nissan": ["Altima", "Sentra", "Rogue", "Pathfinder", "Murano", "Frontier", "Titan", "Leaf", "Maxima", "Versa"],
        "Hyundai": ["Elantra", "Sonata", "Tucson", "Santa Fe", "Palisade", "Kona", "Venue", "Ioniq", "IONIQ 5", "IONIQ 6"],
        "Kia": ["Forte", "Optima", "Sorento", "Telluride", "Sportage", "Seltos", "Soul", "Rio", "EV6", "Niro"],
        "Chevrolet": ["Silverado", "Equinox", "Tahoe", "Suburban", "Traverse", "Malibu", "Cruze", "Camaro", "Corvette", "Bolt"],
        "Mazda": ["Mazda3", "Mazda6", "CX-5", "CX-9", "CX-30", "MX-5 Miata", "CX-3"],
        "Subaru": ["Outback", "Forester", "Crosstrek", "Ascent", "Legacy", "Impreza", "WRX", "BRZ"],
        "Volvo": ["XC40", "XC60", "XC90", "S60", "S90", "V60", "V90", "C40"],
        "Tesla": ["Model S", "Model 3", "Model X", "Model Y", "Cybertruck"],
        "Jeep": ["Wrangler", "Grand Cherokee", "Cherokee", "Compass", "Renegade", "Gladiator", "Wagoneer"],
        "Dodge": ["Challenger", "Charger", "Durango", "Journey", "Ram 1500"],
        "Lexus": ["ES", "IS", "GS", "LS", "RX", "NX", "GX", "LX", "UX"],
        "Acura": ["ILX", "TLX", "RLX", "RDX", "MDX", "NSX"],
        "Infiniti": ["Q50", "Q60", "Q70", "QX50", "QX60", "QX80"],
        "Cadillac": ["CT4", "CT5", "CT6", "XT4", "XT5", "XT6", "Escalade"],
        "Lincoln": ["Corsair", "Nautilus", "Aviator", "Navigator", "Continental"],
        "GMC": ["Sierra", "Yukon", "Acadia", "Terrain", "Canyon"],
        "Buick": ["Encore", "Envision", "Enclave", "Regal"],
        "Chrysler": ["300", "Pacifica", "Voyager"],
        "Ram": ["1500", "2500", "3500", "ProMaster"],
        "Mitsubishi": ["Outlander", "Eclipse Cross", "Mirage", "Outlander Sport"],
        "Suzuki": ["Swift", "Vitara", "S-Cross", "Jimny"],
        "Peugeot": ["208", "308", "508", "2008", "3008", "5008"],
        "Renault": ["Clio", "Megane", "Captur", "Kadjar", "Koleos"],
        "Citroën": ["C3", "C4", "C5", "Berlingo"],
        "SEAT": ["Ibiza", "Leon", "Ateca", "Tarraco"],
        "Škoda": ["Fabia", "Octavia", "Superb", "Kodiaq", "Kamiq"],
        "Fiat": ["500", "Panda", "Tipo", "500X", "500L"],
        "Alfa Romeo": ["Giulia", "Stelvio", "Tonale"],
        "Porsche": ["911", "Cayenne", "Macan", "Panamera", "Taycan", "Boxster", "Cayman"],
        "Jaguar": ["XE", "XF", "XJ", "F-Pace", "E-Pace", "I-Pace"],
        "Land Rover": ["Range Rover", "Range Rover Sport", "Range Rover Evoque", "Discovery", "Defender"],
        "Maserati": ["Ghibli", "Quattroporte", "Levante", "MC20"],
        "Ferrari": ["F8", "SF90", "Roma", "Portofino", "812"],
        "Lamborghini": ["Huracán", "Aventador", "Urus"],
        "Bentley": ["Continental", "Bentayga", "Flying Spur"],
        "Rolls-Royce": ["Ghost", "Phantom", "Cullinan", "Wraith"],
        "Aston Martin": ["DB11", "Vantage", "DBX", "DBS"],
        "McLaren": ["720S", "765LT", "Artura", "GT"],
        "Genesis": ["G70", "G80", "G90", "GV70", "GV80"],
        "Mini": ["Cooper", "Countryman", "Clubman", "Paceman"]
    ]
    
    public static func getModels(for brand: String) -> [String] {
        return modelsByBrand[brand] ?? []
    }
    
    public static func searchModels(for brand: String, query: String) -> [String] {
        let models = getModels(for: brand)
        guard !query.isEmpty else { return models }
        let lowercasedQuery = query.lowercased()
        return models.filter { $0.lowercased().contains(lowercasedQuery) }
    }
}



