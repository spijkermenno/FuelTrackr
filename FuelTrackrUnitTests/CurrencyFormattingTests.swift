//
//  CurrencyFormattingTests.swift
//  FuelTrackrUnitTests
//

import Testing
@testable import FuelTrackr
import Domain

struct CurrencyFormattingTests {

    @Test func formatsWithEuroSymbol() throws {
        let result = CurrencyFormatting.format(76.50, currency: .euro)
        #expect(result.contains("€"))
        #expect(result.contains("76") || result.contains("76,50") || result.contains("76.50"))
    }

    @Test func formatsWithUSDSymbol() throws {
        let result = CurrencyFormatting.format(76.50, currency: .usd)
        #expect(result.contains("$"))
        #expect(result.contains("76"))
    }

    @Test func formatsWithGBPSymbol() throws {
        let result = CurrencyFormatting.format(50.00, currency: .gbp)
        #expect(result.contains("£"))
    }

    @Test func formatPricePerLiterIncludesUnit() throws {
        let result = CurrencyFormatting.formatPricePerLiter(1.79, currency: .euro)
        #expect(result.contains("/L"))
        #expect(result.contains("€"))
    }
}
