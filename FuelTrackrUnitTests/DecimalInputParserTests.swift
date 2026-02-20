//
//  DecimalInputParserTests.swift
//  FuelTrackrUnitTests
//

import Testing
@testable import FuelTrackr
import Domain

struct DecimalInputParserTests {

    // MARK: - EUR (comma as decimal separator)

    @Test func parsesCommaDecimalWithEuro() throws {
        #expect(DecimalInputParser.parse("76,50", currency: .euro) == 76.50)
        #expect(DecimalInputParser.parse("1,5", currency: .euro) == 1.5)
        #expect(DecimalInputParser.parse("0,99", currency: .euro) == 0.99)
    }

    @Test func parsesDotDecimalWithEuro() throws {
        #expect(DecimalInputParser.parse("76.50", currency: .euro) == 76.50)
        #expect(DecimalInputParser.parse("1.5", currency: .euro) == 1.5)
    }

    @Test func parsesEUThousandsWithEuro() throws {
        #expect(DecimalInputParser.parse("1.234,56", currency: .euro) == 1234.56)
        #expect(DecimalInputParser.parse("10.000", currency: .euro) == 10_000)
    }

    // MARK: - USD (dot as decimal separator)

    @Test func parsesDotDecimalWithUSD() throws {
        #expect(DecimalInputParser.parse("76.50", currency: .usd) == 76.50)
        #expect(DecimalInputParser.parse("1.5", currency: .usd) == 1.5)
    }

    @Test func parsesCommaDecimalWithUSD() throws {
        #expect(DecimalInputParser.parse("76,50", currency: .usd) == 76.50)
        #expect(DecimalInputParser.parse("1,5", currency: .usd) == 1.5)
    }

    @Test func parsesUSThousandsWithUSD() throws {
        #expect(DecimalInputParser.parse("1,234.56", currency: .usd) == 1234.56)
        #expect(DecimalInputParser.parse("1,000", currency: .usd) == 1_000)
    }

    // MARK: - Integer and simple values

    @Test func parsesIntegerValues() throws {
        #expect(DecimalInputParser.parse("100", currency: .euro) == 100)
        #expect(DecimalInputParser.parse("100", currency: .usd) == 100)
    }

    @Test func parsesWhitespaceTrimmed() throws {
        #expect(DecimalInputParser.parse("  76,50  ", currency: .euro) == 76.50)
    }

    // MARK: - Invalid input

    @Test func returnsNilForEmptyInput() throws {
        #expect(DecimalInputParser.parse("", currency: .euro) == nil)
        #expect(DecimalInputParser.parse("   ", currency: .euro) == nil)
    }

    @Test func returnsNilForInvalidInput() throws {
        #expect(DecimalInputParser.parse("abc", currency: .euro) == nil)
        #expect(DecimalInputParser.parse("1.2.3", currency: .usd) == nil)
    }
}
