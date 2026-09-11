import Foundation
import XCTest
@testable import Stock_Crashes_and_Manias

class MarketExhaustionEngineCellularTests: XCTestCase  {

    func testCellularAutomatonOutputsVary() {
        let historicalEngine = HistoricalMarketEngine()
        let engine = MarketExhaustionEngine()

        let periods = historicalEngine.periods.sorted {
            $0.crashYear < $1.crashYear
        }

        XCTAssertTrue(periods.count > 3, "Must have at least 4 periods to test variation.")

        var energies: [Double] = []
        var momenta: [Double] = []
        var exhaustions: [Double] = []
        var stresses: [Double] = []

        for period in periods.prefix(5) {
            let result = historicalEngine.caAnalysis(
                for: period,
                using: engine
            )

            energies.append(result.meanEnergy)
            momenta.append(result.meanMomentum)
            exhaustions.append(result.meanExhaustion)
            stresses.append(result.meanStress)
        }

        XCTAssertTrue(hasVariation(energies), "meanEnergy should vary across historical periods.")
        XCTAssertTrue(hasVariation(momenta), "meanMomentum should vary across historical periods.")
        XCTAssertTrue(hasVariation(exhaustions), "meanExhaustion should vary across historical periods.")
        XCTAssertTrue(hasVariation(stresses), "meanStress should vary across historical periods.")
    }

    private func hasVariation(
        _ values: [Double],
        tolerance: Double = 0.0001
    ) -> Bool {
        guard let first = values.first else {
            return false
        }

        return values.dropFirst().contains {
            abs($0 - first) > tolerance
        }
    }
}
