//
//  ScovilleEnvironment.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 18/11/2025.
//

import Foundation
import ScovilleKit

enum ScovilleEnvironment {
    
    static func configureFromDefaults() async {
        let defaults = UserDefaults.standard
        
        let env = defaults.string(forKey: "apiEnvironment") ?? "production"
        let host = defaults.string(forKey: "devBaseAddress") ?? ""
        let port = defaults.string(forKey: "devBasePort") ?? ""
        let override = defaults.string(forKey: "apiKeyOverride") ?? ""
        
        let baseURL = resolveBaseURL(env: env, host: host, port: port)
        
        let apiKey = env == "production"
            ? "BkO0IuH69i39DYCrkGfS2TgqRsS8jYt9gU4DqYib"
            : (override.isEmpty
               ? "BkO0IuH69i39DYCrkGfS2TgqRsS8jYt9gU4DqYib"
               : override)
        
        print("🌶️ [ScovilleEnvironment] FuelTrackr configured for \(env.uppercased()) → \(baseURL)")
        
        await MainActor.run {
            Scoville.configure(apiKey: apiKey)
        }
        
        await Scoville.configureAPI(url: baseURL)
        
#if DEBUG
        await Scoville.debugPrintStatus()
#endif
    }
    
    private static func resolveBaseURL(env: String, host: String, port: String) -> String {
        if env == "production" {
            return "https://pixelwonders.nl/api"
        }
        
        let sanitizedHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedPort = port.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !sanitizedHost.isEmpty else {
            return "http://localhost/api"
        }
        
        return sanitizedPort.isEmpty
            ? "http://\(sanitizedHost)/api"
            : "http://\(sanitizedHost):\(sanitizedPort)/api"
    }
}
