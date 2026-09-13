//
//  File2.swift
//  Stock Crashes and Manias
//
//  Created by David Nishimoto on 9/10/26.
//

import Foundation
import SwiftUI
import Combine



struct CrashRecord: Identifiable {

    /// The crash year is the stable identifier.
    var id: Int {
        year
    }

    /// Calendar year associated with the historical crash.
    let year: Int

    /// Historical market volume associated with the crash record,
    /// expressed in millions of shares/contracts as supplied by
    /// the historical dataset.
    let volumeMillions: Double
}

struct MarketScenario:
    Codable,
    Equatable
{
    // --------------------------------------------------------
    // Money / monetary policy
    // --------------------------------------------------------

    var moneySupplyChangePercent: Double = 0.0
    var moneyPolicyChangeImpact: Double = 0.0

    // --------------------------------------------------------
    // Inflation / taxation
    // --------------------------------------------------------

    var inflationPercent: Double = 0.0

    /// Annual tax-revenue growth.
    ///
    /// This is NOT a tax rate.
    ///
    /// Historical JSON source field:
    /// taxGrowthPercent
    var taxationGrowthPercent: Double = 0.0

    // --------------------------------------------------------
    // Economic growth
    // --------------------------------------------------------

    var economicGrowthPercent: Double = 0.0

    // --------------------------------------------------------
    // Equity market
    // --------------------------------------------------------

    var stockGrowthPercent: Double = 0.0

    var previousStockGrowthPercent: Double = 0.0

    // --------------------------------------------------------
    // Bond market
    // --------------------------------------------------------

    var bondYieldAvgPercent: Double = 0.0

    // --------------------------------------------------------
    // Banking / credit
    // --------------------------------------------------------

    /// Historical source scale is approximately 0...10.
    ///
    /// The CA normalizes this value before using it.
    var bankingCreditStressRating: Double = 0.0

    // --------------------------------------------------------
    // External disturbance
    // --------------------------------------------------------

    /// Shock magnitude expressed as a percentage-like source
    /// value.
    ///
    /// The CA interprets this as magnitude rather than
    /// directional economic impact.
    var externalShockMagnitudePercent: Double = 0.0

    // --------------------------------------------------------
    // Neutral scenario
    // --------------------------------------------------------

    static let neutral = MarketScenario()

    // --------------------------------------------------------
    // Initializer
    // --------------------------------------------------------

    init(
        moneySupplyChangePercent: Double = 0.0,
        inflationPercent: Double = 0.0,
        taxationGrowthPercent: Double = 0.0,
        economicGrowthPercent: Double = 0.0,
        stockGrowthPercent: Double = 0.0,
        previousStockGrowthPercent: Double = 0.0,
        bondYieldAvgPercent: Double = 0.0,
        bankingCreditStressRating: Double = 0.0,
        moneyPolicyChangeImpact: Double = 0.0,
        externalShockMagnitudePercent: Double = 0.0
    ) {
        self.moneySupplyChangePercent =
            moneySupplyChangePercent

        self.inflationPercent =
            inflationPercent

        self.taxationGrowthPercent =
            taxationGrowthPercent

        self.economicGrowthPercent =
            economicGrowthPercent

        self.stockGrowthPercent =
            stockGrowthPercent

        self.previousStockGrowthPercent =
            previousStockGrowthPercent

        self.bondYieldAvgPercent =
            bondYieldAvgPercent

        self.bankingCreditStressRating =
            bankingCreditStressRating

        self.moneyPolicyChangeImpact =
            moneyPolicyChangeImpact

        self.externalShockMagnitudePercent =
            externalShockMagnitudePercent
    }
}


// ============================================================
// MARK: - Historical CA Row
// ============================================================
//
// This is a presentation/result wrapper.
//
// It is NOT a second parameter system and NOT a second
// historical-input pipeline.
//
// Historical data flows:
//
// HistoricalYear
//       ↓
// MarketScenario
//       ↓
// MarketExhaustionEngine
//       ↓
// MarketRiskResult + MarketCell[]
//       ↓
// HistoricalCARow
// ============================================================

struct HistoricalCARow: Identifiable {

    let id: Int

    let period: HistoricalCrashPeriod

    let analysis: HistoricalAnalysis

    let result: MarketRiskResult

    let cells: [MarketCell]

    init(
        period: HistoricalCrashPeriod,
        analysis: HistoricalAnalysis,
        result: MarketRiskResult,
        cells: [MarketCell]
    ) {
        self.id = period.id
        self.period = period
        self.analysis = analysis
        self.result = result
        self.cells = cells
    }
}


struct SplitMix64 {

    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15

        var z = state

        z = (z ^ (z >> 30))
            &* 0xBF58476D1CE4E5B9

        z = (z ^ (z >> 27))
            &* 0x94D049BB133111EB

        return z ^ (z >> 31)
    }

    mutating func nextUnit() -> Double {
        let value = next()

        let normalized =
            Double(value >> 11)
            * (1.0 / 9007199254740992.0)

        return min(
            max(normalized, 0.0),
            0.9999999999999999
        )
    }

    mutating func centeredUnit() -> Double {
        nextUnit() * 2.0 - 1.0
    }
}


// ============================================================
// MARK: - Canonical Market State
// ============================================================

enum MarketState: String, CaseIterable, Codable {

    case stable
    case rising
    case stressed
    case critical
    case crashed

    var displayName: String {
        switch self {
        case .stable:
            return "Stable"

        case .rising:
            return "Rising"

        case .stressed:
            return "Stressed"

        case .critical:
            return "Critical"

        case .crashed:
            return "Crashed"
        }
    }
}





// ============================================================
// MARK: - Current Market Volume Point
// ============================================================

struct MarketVolumePoint:
    Identifiable,
    Codable,
    Equatable
{

    var id: Int {
        year
    }

    let year: Int
    let volumeMillions: Double
}


// ============================================================
// MARK: - Market Cell
// ============================================================

struct MarketCell:
    Identifiable
{

    let id: Int

    var energy: Double
    var liquidity: Double
    var capital: Double

    var momentum: Double
    var financialPotential: Double
    var potentialGradient: Double

    var exhaustion: Double
    var contagion: Double
    var stress: Double

    var state: MarketState
}


// ============================================================
// MARK: - Canonical Market Parameters
// ============================================================
//
// This is the ONLY parameter system.
//
// CAParameters has been removed.
// All cellular and macroeconomic coefficients live here.
//

struct MarketParameters:
    Codable,
    Equatable
{

    // --------------------------------------------------------
    // Simulation
    // --------------------------------------------------------

    var gridWidth: Int = 32
    var gridHeight: Int = 32

    var generationsPerYear: Int = 1

    var randomSeed: UInt64 = 42


    // --------------------------------------------------------
    // Initial state
    // --------------------------------------------------------

    var initialEnergy: Double = 0.50
    var initialLiquidity: Double = 1.00
    var initialCapital: Double = 1.00


    // --------------------------------------------------------
    // External forcing
    // --------------------------------------------------------

    var equilibriumWeight: Double = 0.50
    var volumeWeight: Double = 0.50

    var energyInjectionRate: Double = 0.20

    /// Fraction of injected model energy converted into
    /// usable cellular energy.
    var energyConversion: Double = 0.30

    var energyRetention: Double = 0.90


    // --------------------------------------------------------
    // Macro energy
    // --------------------------------------------------------

    var energyTransferRate: Double = 0.15

    var moneySupplyEnergyWeight: Double = 0.30
    var economicGrowthEnergyWeight: Double = 0.20
    var externalShockEnergyWeight: Double = 0.20

    var macroEnergyInjectionRate: Double = 0.25


    // --------------------------------------------------------
    // Momentum
    // --------------------------------------------------------

    var momentumRetention: Double = 0.85
    var momentumResponse: Double = 0.25

    var macroMomentumResponse: Double = 0.20

    var potentialGradientResponse: Double = 0.20

    var momentumTransferRate: Double = 0.15


    // --------------------------------------------------------
    // Financial potential
    // --------------------------------------------------------

    var potentialGain: Double = 0.75

    var potentialEnergyWeight: Double = 0.60
    var potentialMomentumWeight: Double = 0.40


    // --------------------------------------------------------
    // Liquidity / capital depletion
    // --------------------------------------------------------

    var liquidityDepletionRate: Double = 0.08
    var capitalDepletionRate: Double = 0.06

    var inflationLiquidityRate: Double = 0.10
    var bondYieldLiquidityRate: Double = 0.10
    var bankingLiquidityRate: Double = 0.15
    var taxLiquidityRate: Double = 0.05

    var taxCapitalRate: Double = 0.10
    var bankingCapitalRate: Double = 0.15
    var externalShockCapitalRate: Double = 0.20


    // --------------------------------------------------------
    // Exhaustion
    // --------------------------------------------------------

    var exhaustionRecoveryRate: Double = 0.02
    var exhaustionAccumulationRate: Double = 0.35

    var macroExhaustionRate: Double = 0.15


    // --------------------------------------------------------
    // Contagion
    // --------------------------------------------------------

    var contagionRate: Double = 0.20
    var diagonalNeighbors: Bool = true


    // --------------------------------------------------------
    // Dissipation
    // --------------------------------------------------------

    var dissipationRate: Double = 0.08


    // --------------------------------------------------------
    // Cellular stress weights
    // --------------------------------------------------------

    var energyWeight: Double = 0.20
    var momentumWeight: Double = 0.15
    var potentialWeight: Double = 0.20
    var exhaustionWeight: Double = 0.25
    var contagionWeight: Double = 0.20

    var macroStressWeight: Double = 0.20
    var energyDepletionStressWeight: Double = 0.25
    var energyDissipationWeight: Double = 0.25


    // --------------------------------------------------------
    // State thresholds
    // --------------------------------------------------------

    var risingThreshold: Double = 0.25
    var stressedThreshold: Double = 0.50
    var criticalThreshold: Double = 0.75
    var crashedThreshold: Double = 0.95

    var severeEnergyDepletionThreshold: Double = 0.05


    // --------------------------------------------------------
    // Systemic-risk weights
    // --------------------------------------------------------

    var systemicEquilibriumWeight: Double = 0.20
    var systemicVolumeWeight: Double = 0.15
    var systemicStressWeight: Double = 0.30
    var systemicCriticalWeight: Double = 0.20
    var systemicCrashWeight: Double = 0.15
}




// ============================================================
// MARK: - Yearly Risk Snapshot
// ============================================================

struct YearlyRiskSnapshot:
    Identifiable,
    Codable,
    Equatable
{

    var id: Int {
        year
    }

    let year: Int

    let equilibriumPressure: Double
    let volumePressure: Double

    let systemicRisk: Double

    let meanEnergy: Double
    let meanMomentum: Double
    let meanExhaustion: Double
    let meanStress: Double
    let meanFinancialPotential: Double

    let criticalFraction: Double
    let crashFraction: Double
}


// ============================================================
// MARK: - Market Risk Result
// ============================================================

struct MarketRiskResult:
    Identifiable,
    Codable,
    Equatable
{

    var id: Int {
        year
    }

    let year: Int

    let equilibriumPressure: Double
    let volumePressure: Double

    let meanEnergy: Double
    let meanMomentum: Double
    let meanExhaustion: Double
    let meanStress: Double
    let meanFinancialPotential: Double

    let criticalFraction: Double
    let crashFraction: Double

    let systemicRisk: Double
    let riskLevel: MarketState
}


// ============================================================
// MARK: - Historical JSON
// ============================================================

struct HistoricalJSONRoot: Codable {

    let crashPeriods: [HistoricalCrashPeriod]
}


struct HistoricalCrashPeriod:
    Codable,
    Identifiable
{

    var id: Int {
        crashYear
    }

    let crashYear: Int
    let priorYears: [HistoricalYear]
}


struct HistoricalYear: Codable, Identifiable {

    var id: Int {
        year
    }

    let year: Int

    let bankingCreditStressRating: Double?

    let m2Billions: Double?
    let m2GrowthPercent: Double?

    let moneyPolicyChangeImpact: Double?

    let inflationPercent: Double?

    let bondYieldAvgPercent: Double?

    let taxRevenueBillions: Double?
    let taxGrowthPercent: Double?

    let economicGrowthPercent: Double?

    let stockGrowthPercent: Double?

    let stockVolumeMillions: Double?
}


// ============================================================
// MARK: - Historical Analysis Types
// ============================================================

struct HistoricalAnalysis:
    Identifiable,
    Codable,
    Equatable
{

    var id: Int {
        crashYear
    }

    let crashYear: Int

    let priorYearsUsed: [Int]

    let m2Growth: Double
    let inflation: Double
    let bondYield: Double
    let taxGrowth: Double
    let economicGrowth: Double
    let stockGrowth: Double
    let stockVolumeGrowth: Double

    let moneyPolicyChangeImpact: Double

    let crashInterval: Int

    let optimism: Double
    let momentum: Double
    let momentumTurn: Double
    let equilibrium: Double
    let powerLaw: Double

    let cellularRisk: Double

    let bankingCreditStressRating: Double
}


struct HistoricalCrashAnalysis:
    Identifiable
{

    var id: Int {
        year
    }

    let year: Int
    let intervalYears: Int

    let result: MarketRiskResult
    let cells: [MarketCell]
}


// ============================================================
// MARK: - Historical CA Frame
// ============================================================

struct HistoricalCAFrame:
    Identifiable
{

    var id: Int {
        year
    }

    let year: Int
    let isCrashYear: Bool

    let moneyEnergyChange: Double
    let volumePressure: Double

    let cells: [MarketCell]
}


// ============================================================
// MARK: - Historical CA Result
// ============================================================

struct HistoricalCAResult:
    Identifiable
{

    var id: Int {
        crashYear
    }

    let crashYear: Int

    let meanEnergy: Double
    let meanMomentum: Double
    let meanExhaustion: Double
    let meanStress: Double
    let meanFinancialPotential: Double

    let criticalFraction: Double
    let releaseFraction: Double

    let energyDepletion: Double
    let stockSlowdown: Double
    let inflationPressure: Double
    let shockPressure: Double
    let bankingStress: Double
    let bankingPolicyInteraction: Double

    let equilibriumPressure: Double
    let equilibriumInflection: Double

    let usefulFuel: Double
    let overdrivePressure: Double

    let systemicRisk: Double

    let finalEnergy: Double
    let finalMomentum: Double

    let financialPotential: Double
    let potentialGradient: Double

    let localExhaustion: Double
    let totalExhaustion: Double

    let effectiveFinancialMass: Double
    let financialPathForce: Double

    let contagion: Double

    let nonlinearFinancialAttractor: Double

    let cells: [MarketCell]
}

// ============================================================
// MARK: - Historical Input
// ============================================================

struct HistoricalCAInput {

    let year: Int

    let growthM2: Double
    let inflationPercent: Double

    let taxGrowthPercent: Double
    let economicGrowthPercent: Double

    let stockGrowthPercent: Double
    let previousStockGrowthPercent: Double

    let growthBondPercent: Double
    let growthVolumePercent: Double

    let cyclePressurePercent: Double
    let shockPressurePercent: Double

    let moneyPolicyChangeImpact: Double

    let bankingCreditStressRating: Double
    
    //let localExhaustion: Double
    //let totalExhaustion: Double
}
let historicalMarketJSON = """

{
  "crashPeriods": [
    {
      "crashYear": 1907,
      "priorYears": [
        {
          "year": 1903,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 9.6,
          "m2GrowthPercent": 7.9,
          "moneyPolicyChangeImpact": 4,
          "inflationPercent": 2.3,
          "bondYieldAvgPercent": 3.42,
          "taxRevenueBillions": 0.233,
          "taxGrowthPercent": 14.8,
          "economicGrowthPercent": 4.4,
          "stockGrowthPercent": -1.6,
          "stockVolumeMillions": 137.8
        },
        {
          "year": 1904,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 9.4,
          "m2GrowthPercent": -2.1,
          "moneyPolicyChangeImpact": -6,
          "inflationPercent": 1.0,
          "bondYieldAvgPercent": 3.55,
          "taxRevenueBillions": 0.262,
          "taxGrowthPercent": 12.4,
          "economicGrowthPercent": -2.8,
          "stockGrowthPercent": 23.2,
          "stockVolumeMillions": 157.7
        },
        {
          "year": 1905,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 10.5,
          "m2GrowthPercent": 11.7,
          "moneyPolicyChangeImpact": 5,
          "inflationPercent": 0.0,
          "bondYieldAvgPercent": 3.47,
          "taxRevenueBillions": 0.262,
          "taxGrowthPercent": 0.0,
          "economicGrowthPercent": 5.2,
          "stockGrowthPercent": 24.2,
          "stockVolumeMillions": 210.0
        },
        {
          "year": 1906,
          "bankingCreditStressRating": 6.0,
          "m2Billions": 11.0,
          "m2GrowthPercent": 4.8,
          "moneyPolicyChangeImpact": -7,
          "inflationPercent": 1.0,
          "bondYieldAvgPercent": 3.52,
          "taxRevenueBillions": 0.300,
          "taxGrowthPercent": 14.5,
          "economicGrowthPercent": 5.1,
          "stockGrowthPercent": 11.6,
          "stockVolumeMillions": 230.4
        }
      ]
    },

    {
      "crashYear": 1929,
      "priorYears": [
        {
          "year": 1925,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 45.8,
          "m2GrowthPercent": 4.1,
          "moneyPolicyChangeImpact": 3,
          "inflationPercent": 2.4,
          "bondYieldAvgPercent": 3.61,
          "taxRevenueBillions": 3.780,
          "taxGrowthPercent": 5.1,
          "economicGrowthPercent": 4.7,
          "stockGrowthPercent": 37.2,
          "stockVolumeMillions": 935.0
        },
        {
          "year": 1926,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 48.5,
          "m2GrowthPercent": 5.9,
          "moneyPolicyChangeImpact": 4,
          "inflationPercent": 1.0,
          "bondYieldAvgPercent": 3.67,
          "taxRevenueBillions": 3.962,
          "taxGrowthPercent": 4.8,
          "economicGrowthPercent": 0.8,
          "stockGrowthPercent": 8.4,
          "stockVolumeMillions": 1178.0
        },
        {
          "year": 1927,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 51.5,
          "m2GrowthPercent": 6.2,
          "moneyPolicyChangeImpact": 5,
          "inflationPercent": -1.9,
          "bondYieldAvgPercent": 3.51,
          "taxRevenueBillions": 3.992,
          "taxGrowthPercent": 0.8,
          "economicGrowthPercent": 1.9,
          "stockGrowthPercent": 19.9,
          "stockVolumeMillions": 1408.0
        },
        {
          "year": 1928,
          "bankingCreditStressRating": 5.0,
          "m2Billions": 53.0,
          "m2GrowthPercent": 2.9,
          "moneyPolicyChangeImpact": -6,
          "inflationPercent": -1.2,
          "bondYieldAvgPercent": 3.66,
          "taxRevenueBillions": 3.872,
          "taxGrowthPercent": -3.0,
          "economicGrowthPercent": 4.9,
          "stockGrowthPercent": 43.6,
          "stockVolumeMillions": 1693.0
        }
      ]
    },

    {
      "crashYear": 1937,
      "priorYears": [
        {
          "year": 1933,
          "bankingCreditStressRating": 7.0,
          "m2Billions": 32.2,
          "m2GrowthPercent": 3.2,
          "moneyPolicyChangeImpact": 8,
          "inflationPercent": -5.1,
          "bondYieldAvgPercent": 3.53,
          "taxRevenueBillions": 2.080,
          "taxGrowthPercent": -25.1,
          "economicGrowthPercent": -1.2,
          "stockGrowthPercent": 53.9,
          "stockVolumeMillions": 476.0
        },
        {
          "year": 1934,
          "bankingCreditStressRating": 6.0,
          "m2Billions": 35.8,
          "m2GrowthPercent": 11.2,
          "moneyPolicyChangeImpact": 7,
          "inflationPercent": 3.5,
          "bondYieldAvgPercent": 3.29,
          "taxRevenueBillions": 3.116,
          "taxGrowthPercent": 49.8,
          "economicGrowthPercent": 10.8,
          "stockGrowthPercent": -1.4,
          "stockVolumeMillions": 461.0
        },
        {
          "year": 1935,
          "bankingCreditStressRating": 4.0,
          "m2Billions": 39.5,
          "m2GrowthPercent": 10.3,
          "moneyPolicyChangeImpact": 6,
          "inflationPercent": 2.6,
          "bondYieldAvgPercent": 2.84,
          "taxRevenueBillions": 3.800,
          "taxGrowthPercent": 21.9,
          "economicGrowthPercent": 8.9,
          "stockGrowthPercent": 47.7,
          "stockVolumeMillions": 519.0
        },
        {
          "year": 1936,
          "bankingCreditStressRating": 6.0,
          "m2Billions": 43.1,
          "m2GrowthPercent": 9.1,
          "moneyPolicyChangeImpact": -6,
          "inflationPercent": 1.0,
          "bondYieldAvgPercent": 2.65,
          "taxRevenueBillions": 4.116,
          "taxGrowthPercent": 8.3,
          "economicGrowthPercent": 12.9,
          "stockGrowthPercent": 33.9,
          "stockVolumeMillions": 789.0
        }
      ]
    },

    {
      "crashYear": 1968,
      "priorYears": [
        {
          "year": 1964,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 168.1,
          "m2GrowthPercent": 4.7,
          "moneyPolicyChangeImpact": 3,
          "inflationPercent": 1.3,
          "bondYieldAvgPercent": 4.19,
          "taxRevenueBillions": 91.8,
          "taxGrowthPercent": 6.8,
          "economicGrowthPercent": 5.8,
          "stockGrowthPercent": 16.5,
          "stockVolumeMillions": 1470.0
        },
        {
          "year": 1965,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 180.2,
          "m2GrowthPercent": 7.2,
          "moneyPolicyChangeImpact": 4,
          "inflationPercent": 1.6,
          "bondYieldAvgPercent": 4.21,
          "taxRevenueBillions": 98.1,
          "taxGrowthPercent": 6.9,
          "economicGrowthPercent": 6.4,
          "stockGrowthPercent": 12.5,
          "stockVolumeMillions": 1680.0
        },
        {
          "year": 1966,
          "bankingCreditStressRating": 5.0,
          "m2Billions": 188.7,
          "m2GrowthPercent": 4.7,
          "moneyPolicyChangeImpact": -7,
          "inflationPercent": 2.9,
          "bondYieldAvgPercent": 4.65,
          "taxRevenueBillions": 111.3,
          "taxGrowthPercent": 13.5,
          "economicGrowthPercent": 6.5,
          "stockGrowthPercent": -10.1,
          "stockVolumeMillions": 1770.0
        },
        {
          "year": 1967,
          "bankingCreditStressRating": 6.0,
          "m2Billions": 203.1,
          "m2GrowthPercent": 7.6,
          "moneyPolicyChangeImpact": -6,
          "inflationPercent": 2.8,
          "bondYieldAvgPercent": 4.86,
          "taxRevenueBillions": 119.6,
          "taxGrowthPercent": 7.5,
          "economicGrowthPercent": 2.5,
          "stockGrowthPercent": 23.9,
          "stockVolumeMillions": 2070.0
        }
      ]
    },

    {
      "crashYear": 1974,
      "priorYears": [
        {
          "year": 1970,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 233.2,
          "m2GrowthPercent": 5.6,
          "moneyPolicyChangeImpact": -6,
          "inflationPercent": 5.8,
          "bondYieldAvgPercent": 6.04,
          "taxRevenueBillions": 192.8,
          "taxGrowthPercent": -2.1,
          "economicGrowthPercent": 0.2,
          "stockGrowthPercent": 4.0,
          "stockVolumeMillions": 3540.0
        },
        {
          "year": 1971,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 249.1,
          "m2GrowthPercent": 6.8,
          "moneyPolicyChangeImpact": 6,
          "inflationPercent": 4.3,
          "bondYieldAvgPercent": 6.21,
          "taxRevenueBillions": 187.1,
          "taxGrowthPercent": -3.0,
          "economicGrowthPercent": 3.3,
          "stockGrowthPercent": 14.3,
          "stockVolumeMillions": 3620.0
        },
        {
          "year": 1972,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 268.1,
          "m2GrowthPercent": 7.6,
          "moneyPolicyChangeImpact": 7,
          "inflationPercent": 3.3,
          "bondYieldAvgPercent": 6.70,
          "taxRevenueBillions": 207.3,
          "taxGrowthPercent": 10.8,
          "economicGrowthPercent": 5.3,
          "stockGrowthPercent": 18.9,
          "stockVolumeMillions": 4300.0
        },
        {
          "year": 1973,
          "bankingCreditStressRating": 6.0,
          "m2Billions": 292.0,
          "m2GrowthPercent": 8.9,
          "moneyPolicyChangeImpact": -8,
          "inflationPercent": 6.2,
          "bondYieldAvgPercent": 7.00,
          "taxRevenueBillions": 230.8,
          "taxGrowthPercent": 11.3,
          "economicGrowthPercent": 5.6,
          "stockGrowthPercent": -14.7,
          "stockVolumeMillions": 4500.0
        }
      ]
    },

    {
      "crashYear": 1987,
      "priorYears": [
        {
          "year": 1983,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 1828.0,
          "m2GrowthPercent": 9.0,
          "moneyPolicyChangeImpact": 4,
          "inflationPercent": 3.2,
          "bondYieldAvgPercent": 11.10,
          "taxRevenueBillions": 600.6,
          "taxGrowthPercent": 3.3,
          "economicGrowthPercent": 4.6,
          "stockGrowthPercent": 22.6,
          "stockVolumeMillions": 11270.0
        },
        {
          "year": 1984,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 1962.0,
          "m2GrowthPercent": 7.3,
          "moneyPolicyChangeImpact": 5,
          "inflationPercent": 4.3,
          "bondYieldAvgPercent": 12.46,
          "taxRevenueBillions": 666.5,
          "taxGrowthPercent": 11.0,
          "economicGrowthPercent": 7.2,
          "stockGrowthPercent": 6.3,
          "stockVolumeMillions": 13660.0
        },
        {
          "year": 1985,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 2099.0,
          "m2GrowthPercent": 7.0,
          "moneyPolicyChangeImpact": 5,
          "inflationPercent": 3.6,
          "bondYieldAvgPercent": 10.62,
          "taxRevenueBillions": 734.1,
          "taxGrowthPercent": 10.1,
          "economicGrowthPercent": 4.2,
          "stockGrowthPercent": 31.7,
          "stockVolumeMillions": 17590.0
        },
        {
          "year": 1986,
          "bankingCreditStressRating": 4.0,
          "m2Billions": 2241.0,
          "m2GrowthPercent": 6.8,
          "moneyPolicyChangeImpact": -7,
          "inflationPercent": 1.9,
          "bondYieldAvgPercent": 7.67,
          "taxRevenueBillions": 769.2,
          "taxGrowthPercent": 4.8,
          "economicGrowthPercent": 3.5,
          "stockGrowthPercent": 18.4,
          "stockVolumeMillions": 25100.0
        }
      ]
    },

    {
      "crashYear": 2000,
      "priorYears": [
        {
          "year": 1996,
          "bankingCreditStressRating": 1.0,
          "m2Billions": 3845.5,
          "m2GrowthPercent": 4.7,
          "moneyPolicyChangeImpact": 3,
          "inflationPercent": 2.9,
          "bondYieldAvgPercent": 6.44,
          "taxRevenueBillions": 1453.2,
          "taxGrowthPercent": 10.2,
          "economicGrowthPercent": 3.8,
          "stockGrowthPercent": 23.0,
          "stockVolumeMillions": 105460.0
        },
        {
          "year": 1997,
          "bankingCreditStressRating": 1.0,
          "m2Billions": 4044.0,
          "m2GrowthPercent": 5.2,
          "moneyPolicyChangeImpact": 4,
          "inflationPercent": 2.3,
          "bondYieldAvgPercent": 6.35,
          "taxRevenueBillions": 1579.0,
          "taxGrowthPercent": 8.7,
          "economicGrowthPercent": 4.4,
          "stockGrowthPercent": 33.4,
          "stockVolumeMillions": 134620.0
        },
        {
          "year": 1998,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 4404.0,
          "m2GrowthPercent": 8.9,
          "moneyPolicyChangeImpact": 6,
          "inflationPercent": 1.6,
          "bondYieldAvgPercent": 5.26,
          "taxRevenueBillions": 1721.8,
          "taxGrowthPercent": 9.0,
          "economicGrowthPercent": 4.5,
          "stockGrowthPercent": 28.6,
          "stockVolumeMillions": 169320.0
        },
        {
          "year": 1999,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 4600.0,
          "m2GrowthPercent": 4.5,
          "moneyPolicyChangeImpact": -7,
          "inflationPercent": 2.2,
          "bondYieldAvgPercent": 5.65,
          "taxRevenueBillions": 1827.5,
          "taxGrowthPercent": 6.1,
          "economicGrowthPercent": 4.8,
          "stockGrowthPercent": 21.0,
          "stockVolumeMillions": 203770.0
        }
      ]
    },

    {
      "crashYear": 2008,
      "priorYears": [
        {
          "year": 2004,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 6407.0,
          "m2GrowthPercent": 5.4,
          "moneyPolicyChangeImpact": 4,
          "inflationPercent": 2.7,
          "bondYieldAvgPercent": 4.27,
          "taxRevenueBillions": 1880.1,
          "taxGrowthPercent": -5.7,
          "economicGrowthPercent": 3.9,
          "stockGrowthPercent": 10.9,
          "stockVolumeMillions": 1099000.0
        },
        {
          "year": 2005,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 6687.0,
          "m2GrowthPercent": 4.4,
          "moneyPolicyChangeImpact": 5,
          "inflationPercent": 3.4,
          "bondYieldAvgPercent": 4.29,
          "taxRevenueBillions": 2153.6,
          "taxGrowthPercent": 14.5,
          "economicGrowthPercent": 3.5,
          "stockGrowthPercent": 4.9,
          "stockVolumeMillions": 1190000.0
        },
        {
          "year": 2006,
          "bankingCreditStressRating": 6.0,
          "m2Billions": 7013.0,
          "m2GrowthPercent": 4.9,
          "moneyPolicyChangeImpact": 6,
          "inflationPercent": 3.2,
          "bondYieldAvgPercent": 4.80,
          "taxRevenueBillions": 2406.9,
          "taxGrowthPercent": 11.8,
          "economicGrowthPercent": 2.8,
          "stockGrowthPercent": 15.8,
          "stockVolumeMillions": 1328000.0
        },
        {
          "year": 2007,
          "bankingCreditStressRating": 9.0,
          "m2Billions": 7409.0,
          "m2GrowthPercent": 5.6,
          "moneyPolicyChangeImpact": -8,
          "inflationPercent": 2.9,
          "bondYieldAvgPercent": 4.63,
          "taxRevenueBillions": 2568.0,
          "taxGrowthPercent": 6.7,
          "economicGrowthPercent": 2.0,
          "stockGrowthPercent": 5.5,
          "stockVolumeMillions": 1487000.0
        }
      ]
    },

    {
      "crashYear": 2020,
      "priorYears": [
        {
          "year": 2016,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 13232.0,
          "m2GrowthPercent": 6.3,
          "moneyPolicyChangeImpact": 4,
          "inflationPercent": 1.3,
          "bondYieldAvgPercent": 1.84,
          "taxRevenueBillions": 3268.0,
          "taxGrowthPercent": 0.6,
          "economicGrowthPercent": 1.8,
          "stockGrowthPercent": 12.0,
          "stockVolumeMillions": 3065000.0
        },
        {
          "year": 2017,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 13896.0,
          "m2GrowthPercent": 5.0,
          "moneyPolicyChangeImpact": 4,
          "inflationPercent": 2.1,
          "bondYieldAvgPercent": 2.33,
          "taxRevenueBillions": 3316.0,
          "taxGrowthPercent": 1.5,
          "economicGrowthPercent": 2.5,
          "stockGrowthPercent": 21.8,
          "stockVolumeMillions": 3071000.0
        },
        {
          "year": 2018,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 14443.0,
          "m2GrowthPercent": 3.9,
          "moneyPolicyChangeImpact": -6,
          "inflationPercent": 2.4,
          "bondYieldAvgPercent": 2.91,
          "taxRevenueBillions": 3329.0,
          "taxGrowthPercent": 0.4,
          "economicGrowthPercent": 3.0,
          "stockGrowthPercent": -4.4,
          "stockVolumeMillions": 3189000.0
        },
        {
          "year": 2019,
          "bankingCreditStressRating": 5.0,
          "m2Billions": 15391.0,
          "m2GrowthPercent": 6.6,
          "moneyPolicyChangeImpact": 7,
          "inflationPercent": 1.8,
          "bondYieldAvgPercent": 2.14,
          "taxRevenueBillions": 3463.0,
          "taxGrowthPercent": 4.0,
          "economicGrowthPercent": 2.6,
          "stockGrowthPercent": 31.5,
          "stockVolumeMillions": 3304000.0
        }
      ]
    },

    {
      "crashYear": 2022,
      "priorYears": [
        {
          "year": 2018,
          "bankingCreditStressRating": 2.0,
          "m2Billions": 14443.0,
          "m2GrowthPercent": 3.9,
          "moneyPolicyChangeImpact": -6,
          "inflationPercent": 2.4,
          "bondYieldAvgPercent": 2.91,
          "taxRevenueBillions": 3329.0,
          "taxGrowthPercent": 0.4,
          "economicGrowthPercent": 3.0,
          "stockGrowthPercent": -4.4,
          "stockVolumeMillions": 3189000.0
        },
        {
          "year": 2019,
          "bankingCreditStressRating": 3.0,
          "m2Billions": 15391.0,
          "m2GrowthPercent": 6.6,
          "moneyPolicyChangeImpact": 7,
          "inflationPercent": 1.8,
          "bondYieldAvgPercent": 2.14,
          "taxRevenueBillions": 3463.0,
          "taxGrowthPercent": 4.0,
          "economicGrowthPercent": 2.6,
          "stockGrowthPercent": 31.5,
          "stockVolumeMillions": 3304000.0
        },
        {
          "year": 2020,
          "bankingCreditStressRating": 8.0,
          "m2Billions": 17733.0,
          "m2GrowthPercent": 15.2,
          "moneyPolicyChangeImpact": 10,
          "inflationPercent": 1.2,
          "bondYieldAvgPercent": 0.89,
          "taxRevenueBillions": 3421.0,
          "taxGrowthPercent": -1.2,
          "economicGrowthPercent": -2.2,
          "stockGrowthPercent": 18.4,
          "stockVolumeMillions": 4189000.0
        },
        {
          "year": 2021,
          "bankingCreditStressRating": 7.0,
          "m2Billions": 21186.0,
          "m2GrowthPercent": 19.5,
          "moneyPolicyChangeImpact": 10,
          "inflationPercent": 4.7,
          "bondYieldAvgPercent": 1.45,
          "taxRevenueBillions": 4047.1,
          "taxGrowthPercent": 18.3,
          "economicGrowthPercent": 5.8,
          "stockGrowthPercent": 28.7,
          "stockVolumeMillions": 4646000.0
        }
      ]
    }
  ]
}
"""


