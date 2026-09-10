//
//  File2.swift
//  Stock Crashes and Manias
//
//  Created by David Nishimoto on 9/10/26.
//

import Foundation


let historicalMarketJSON = """
{
  "crashPeriods": [
    {
      "crashYear": 1907,
      "priorYears": [
        {
          "year": 1903,
          "m2Billions": 9.6,
          "m2GrowthPercent": 7.9,
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
          "m2Billions": 9.4,
          "m2GrowthPercent": -2.1,
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
          "m2Billions": 10.5,
          "m2GrowthPercent": 11.7,
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
          "m2Billions": 11.0,
          "m2GrowthPercent": 4.8,
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
          "m2Billions": 45.8,
          "m2GrowthPercent": 4.1,
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
          "m2Billions": 48.5,
          "m2GrowthPercent": 5.9,
          "inflationPercent": 1.0,
          "bondYieldAvgPercent": 3.67,
          "taxRevenueBillions": 3.962,
          "taxGrowthPercent": 4.8,
          "economicGrowthPercent": 0.8,
          "stockGrowthPercent": 8.4,
          "stockVolumeMillions": 1_178.0
        },
        {
          "year": 1927,
          "m2Billions": 51.5,
          "m2GrowthPercent": 6.2,
          "inflationPercent": -1.9,
          "bondYieldAvgPercent": 3.51,
          "taxRevenueBillions": 3.992,
          "taxGrowthPercent": 0.8,
          "economicGrowthPercent": 1.9,
          "stockGrowthPercent": 19.9,
          "stockVolumeMillions": 1_408.0
        },
        {
          "year": 1928,
          "m2Billions": 53.0,
          "m2GrowthPercent": 2.9,
          "inflationPercent": -1.2,
          "bondYieldAvgPercent": 3.66,
          "taxRevenueBillions": 3.872,
          "taxGrowthPercent": -3.0,
          "economicGrowthPercent": 4.9,
          "stockGrowthPercent": 43.6,
          "stockVolumeMillions": 1_693.0
        }
      ]
    },

    {
      "crashYear": 1937,
      "priorYears": [
        {
          "year": 1933,
          "m2Billions": 32.2,
          "m2GrowthPercent": 3.2,
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
          "m2Billions": 35.8,
          "m2GrowthPercent": 11.2,
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
          "m2Billions": 39.5,
          "m2GrowthPercent": 10.3,
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
          "m2Billions": 43.1,
          "m2GrowthPercent": 9.1,
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
          "m2Billions": 168.1,
          "m2GrowthPercent": 4.7,
          "inflationPercent": 1.3,
          "bondYieldAvgPercent": 4.19,
          "taxRevenueBillions": 91.8,
          "taxGrowthPercent": 6.8,
          "economicGrowthPercent": 5.8,
          "stockGrowthPercent": 16.5,
          "stockVolumeMillions": 1_470.0
        },
        {
          "year": 1965,
          "m2Billions": 180.2,
          "m2GrowthPercent": 7.2,
          "inflationPercent": 1.6,
          "bondYieldAvgPercent": 4.21,
          "taxRevenueBillions": 98.1,
          "taxGrowthPercent": 6.9,
          "economicGrowthPercent": 6.4,
          "stockGrowthPercent": 12.5,
          "stockVolumeMillions": 1_680.0
        },
        {
          "year": 1966,
          "m2Billions": 188.7,
          "m2GrowthPercent": 4.7,
          "inflationPercent": 2.9,
          "bondYieldAvgPercent": 4.65,
          "taxRevenueBillions": 111.3,
          "taxGrowthPercent": 13.5,
          "economicGrowthPercent": 6.5,
          "stockGrowthPercent": -10.1,
          "stockVolumeMillions": 1_770.0
        },
        {
          "year": 1967,
          "m2Billions": 203.1,
          "m2GrowthPercent": 7.6,
          "inflationPercent": 2.8,
          "bondYieldAvgPercent": 4.86,
          "taxRevenueBillions": 119.6,
          "taxGrowthPercent": 7.5,
          "economicGrowthPercent": 2.5,
          "stockGrowthPercent": 23.9,
          "stockVolumeMillions": 2_070.0
        }
      ]
    },

    {
      "crashYear": 1974,
      "priorYears": [
        {
          "year": 1970,
          "m2Billions": 233.2,
          "m2GrowthPercent": 5.6,
          "inflationPercent": 5.8,
          "bondYieldAvgPercent": 6.04,
          "taxRevenueBillions": 192.8,
          "taxGrowthPercent": -2.1,
          "economicGrowthPercent": 0.2,
          "stockGrowthPercent": 4.0,
          "stockVolumeMillions": 3_540.0
        },
        {
          "year": 1971,
          "m2Billions": 249.1,
          "m2GrowthPercent": 6.8,
          "inflationPercent": 4.3,
          "bondYieldAvgPercent": 6.21,
          "taxRevenueBillions": 187.1,
          "taxGrowthPercent": -3.0,
          "economicGrowthPercent": 3.3,
          "stockGrowthPercent": 14.3,
          "stockVolumeMillions": 3_620.0
        },
        {
          "year": 1972,
          "m2Billions": 268.1,
          "m2GrowthPercent": 7.6,
          "inflationPercent": 3.3,
          "bondYieldAvgPercent": 6.70,
          "taxRevenueBillions": 207.3,
          "taxGrowthPercent": 10.8,
          "economicGrowthPercent": 5.3,
          "stockGrowthPercent": 18.9,
          "stockVolumeMillions": 4_300.0
        },
        {
          "year": 1973,
          "m2Billions": 292.0,
          "m2GrowthPercent": 8.9,
          "inflationPercent": 6.2,
          "bondYieldAvgPercent": 7.00,
          "taxRevenueBillions": 230.8,
          "taxGrowthPercent": 11.3,
          "economicGrowthPercent": 5.6,
          "stockGrowthPercent": -14.7,
          "stockVolumeMillions": 4_500.0
        }
      ]
    },

    {
      "crashYear": 1987,
      "priorYears": [
        {
          "year": 1983,
          "m2Billions": 1_828.0,
          "m2GrowthPercent": 9.0,
          "inflationPercent": 3.2,
          "bondYieldAvgPercent": 11.10,
          "taxRevenueBillions": 600.6,
          "taxGrowthPercent": 3.3,
          "economicGrowthPercent": 4.6,
          "stockGrowthPercent": 22.6,
          "stockVolumeMillions": 11_270.0
        },
        {
          "year": 1984,
          "m2Billions": 1_962.0,
          "m2GrowthPercent": 7.3,
          "inflationPercent": 4.3,
          "bondYieldAvgPercent": 12.46,
          "taxRevenueBillions": 666.5,
          "taxGrowthPercent": 11.0,
          "economicGrowthPercent": 7.2,
          "stockGrowthPercent": 6.3,
          "stockVolumeMillions": 13_660.0
        },
        {
          "year": 1985,
          "m2Billions": 2_099.0,
          "m2GrowthPercent": 7.0,
          "inflationPercent": 3.6,
          "bondYieldAvgPercent": 10.62,
          "taxRevenueBillions": 734.1,
          "taxGrowthPercent": 10.1,
          "economicGrowthPercent": 4.2,
          "stockGrowthPercent": 31.7,
          "stockVolumeMillions": 17_590.0
        },
        {
          "year": 1986,
          "m2Billions": 2_241.0,
          "m2GrowthPercent": 6.8,
          "inflationPercent": 1.9,
          "bondYieldAvgPercent": 7.67,
          "taxRevenueBillions": 769.2,
          "taxGrowthPercent": 4.8,
          "economicGrowthPercent": 3.5,
          "stockGrowthPercent": 18.4,
          "stockVolumeMillions": 25_100.0
        }
      ]
    },

    {
      "crashYear": 2000,
      "priorYears": [
        {
          "year": 1996,
          "m2Billions": 3_845.5,
          "m2GrowthPercent": 4.7,
          "inflationPercent": 2.9,
          "bondYieldAvgPercent": 6.44,
          "taxRevenueBillions": 1_453.2,
          "taxGrowthPercent": 10.2,
          "economicGrowthPercent": 3.8,
          "stockGrowthPercent": 23.0,
          "stockVolumeMillions": 105_460.0
        },
        {
          "year": 1997,
          "m2Billions": 4_044.0,
          "m2GrowthPercent": 5.2,
          "inflationPercent": 2.3,
          "bondYieldAvgPercent": 6.35,
          "taxRevenueBillions": 1_579.0,
          "taxGrowthPercent": 8.7,
          "economicGrowthPercent": 4.4,
          "stockGrowthPercent": 33.4,
          "stockVolumeMillions": 134_620.0
        },
        {
          "year": 1998,
          "m2Billions": 4_404.0,
          "m2GrowthPercent": 8.9,
          "inflationPercent": 1.6,
          "bondYieldAvgPercent": 5.26,
          "taxRevenueBillions": 1_721.8,
          "taxGrowthPercent": 9.0,
          "economicGrowthPercent": 4.5,
          "stockGrowthPercent": 28.6,
          "stockVolumeMillions": 169_320.0
        },
        {
          "year": 1999,
          "m2Billions": 4_600.0,
          "m2GrowthPercent": 4.5,
          "inflationPercent": 2.2,
          "bondYieldAvgPercent": 5.65,
          "taxRevenueBillions": 1_827.5,
          "taxGrowthPercent": 6.1,
          "economicGrowthPercent": 4.8,
          "stockGrowthPercent": 21.0,
          "stockVolumeMillions": 203_770.0
        }
      ]
    },

    {
      "crashYear": 2008,
      "priorYears": [
        {
          "year": 2004,
          "m2Billions": 6_407.0,
          "m2GrowthPercent": 5.4,
          "inflationPercent": 2.7,
          "bondYieldAvgPercent": 4.27,
          "taxRevenueBillions": 1_880.1,
          "taxGrowthPercent": -5.7,
          "economicGrowthPercent": 3.9,
          "stockGrowthPercent": 10.9,
          "stockVolumeMillions": 1_099_000.0
        },
        {
          "year": 2005,
          "m2Billions": 6_687.0,
          "m2GrowthPercent": 4.4,
          "inflationPercent": 3.4,
          "bondYieldAvgPercent": 4.29,
          "taxRevenueBillions": 2_153.6,
          "taxGrowthPercent": 14.5,
          "economicGrowthPercent": 3.5,
          "stockGrowthPercent": 4.9,
          "stockVolumeMillions": 1_190_000.0
        },
        {
          "year": 2006,
          "m2Billions": 7_013.0,
          "m2GrowthPercent": 4.9,
          "inflationPercent": 3.2,
          "bondYieldAvgPercent": 4.80,
          "taxRevenueBillions": 2_406.9,
          "taxGrowthPercent": 11.8,
          "economicGrowthPercent": 2.8,
          "stockGrowthPercent": 15.8,
          "stockVolumeMillions": 1_328_000.0
        },
        {
          "year": 2007,
          "m2Billions": 7_409.0,
          "m2GrowthPercent": 5.6,
          "inflationPercent": 2.9,
          "bondYieldAvgPercent": 4.63,
          "taxRevenueBillions": 2_568.0,
          "taxGrowthPercent": 6.7,
          "economicGrowthPercent": 2.0,
          "stockGrowthPercent": 5.5,
          "stockVolumeMillions": 1_487_000.0
        }
      ]
    },

    {
      "crashYear": 2020,
      "priorYears": [
        {
          "year": 2016,
          "m2Billions": 13_232.0,
          "m2GrowthPercent": 6.3,
          "inflationPercent": 1.3,
          "bondYieldAvgPercent": 1.84,
          "taxRevenueBillions": 3_268.0,
          "taxGrowthPercent": 0.6,
          "economicGrowthPercent": 1.8,
          "stockGrowthPercent": 12.0,
          "stockVolumeMillions": 3_065_000.0
        },
        {
          "year": 2017,
          "m2Billions": 13_896.0,
          "m2GrowthPercent": 5.0,
          "inflationPercent": 2.1,
          "bondYieldAvgPercent": 2.33,
          "taxRevenueBillions": 3_316.0,
          "taxGrowthPercent": 1.5,
          "economicGrowthPercent": 2.5,
          "stockGrowthPercent": 21.8,
          "stockVolumeMillions": 3_071_000.0
        },
        {
          "year": 2018,
          "m2Billions": 14_443.0,
          "m2GrowthPercent": 3.9,
          "inflationPercent": 2.4,
          "bondYieldAvgPercent": 2.91,
          "taxRevenueBillions": 3_329.0,
          "taxGrowthPercent": 0.4,
          "economicGrowthPercent": 3.0,
          "stockGrowthPercent": -4.4,
          "stockVolumeMillions": 3_189_000.0
        },
        {
          "year": 2019,
          "m2Billions": 15_391.0,
          "m2GrowthPercent": 6.6,
          "inflationPercent": 1.8,
          "bondYieldAvgPercent": 2.14,
          "taxRevenueBillions": 3_463.0,
          "taxGrowthPercent": 4.0,
          "economicGrowthPercent": 2.6,
          "stockGrowthPercent": 31.5,
          "stockVolumeMillions": 3_304_000.0
        }
      ]
    },

    {
      "crashYear": 2022,
      "priorYears": [
        {
          "year": 2018,
          "m2Billions": 14_443.0,
          "m2GrowthPercent": 3.9,
          "inflationPercent": 2.4,
          "bondYieldAvgPercent": 2.91,
          "taxRevenueBillions": 3_329.0,
          "taxGrowthPercent": 0.4,
          "economicGrowthPercent": 3.0,
          "stockGrowthPercent": -4.4,
          "stockVolumeMillions": 3_189_000.0
        },
        {
          "year": 2019,
          "m2Billions": 15_391.0,
          "m2GrowthPercent": 6.6,
          "inflationPercent": 1.8,
          "bondYieldAvgPercent": 2.14,
          "taxRevenueBillions": 3_463.0,
          "taxGrowthPercent": 4.0,
          "economicGrowthPercent": 2.6,
          "stockGrowthPercent": 31.5,
          "stockVolumeMillions": 3_304_000.0
        },
        {
          "year": 2020,
          "m2Billions": 17_733.0,
          "m2GrowthPercent": 15.2,
          "inflationPercent": 1.2,
          "bondYieldAvgPercent": 0.89,
          "taxRevenueBillions": 3_421.0,
          "taxGrowthPercent": -1.2,
          "economicGrowthPercent": -2.2,
          "stockGrowthPercent": 18.4,
          "stockVolumeMillions": 4_189_000.0
        },
        {
          "year": 2021,
          "m2Billions": 21_186.0,
          "m2GrowthPercent": 19.5,
          "inflationPercent": 4.7,
          "bondYieldAvgPercent": 1.45,
          "taxRevenueBillions": 4_047.1,
          "taxGrowthPercent": 18.3,
          "economicGrowthPercent": 5.8,
          "stockGrowthPercent": 28.7,
          "stockVolumeMillions": 4_646_000.0
        }
      ]
    }
  ]
}
"""

// ============================================================
// MARK: - JSON MODELS
// ============================================================

struct HistoricalJSONRoot: Codable {
    let crashPeriods: [HistoricalCrashPeriod]
}

struct HistoricalCrashPeriod: Codable, Identifiable {
    var id: Int { crashYear }

    let crashYear: Int
    let priorYears: [HistoricalYear]
}

struct HistoricalYear: Codable, Identifiable {
    var id: Int { year }

    let year: Int

    let m2Billions: Double?
    let m2GrowthPercent: Double?
    let inflationPercent: Double?
    let bondYieldAvgPercent: Double?

    let taxRevenueBillions: Double?
    let taxGrowthPercent: Double?

    let economicGrowthPercent: Double?
    let stockGrowthPercent: Double?

    let stockVolumeMillions: Double?
}

// ============================================================
// MARK: - HISTORICAL ANALYSIS
// ============================================================

struct HistoricalAnalysis: Identifiable {

    let id = UUID()

    let crashYear: Int
    let priorYearsUsed: Int

    let m2Growth: Double
    let inflation: Double
    let bondYield: Double
    let taxGrowth: Double
    let economicGrowth: Double
    let stockGrowth: Double
    let stockVolumeGrowth: Double

    let crashInterval: Double

    let optimism: Double
    let momentum: Double
    let momentumTurn: Double

    let equilibrium: Double
    let powerLaw: Double

    let cellularRisk: Double
}

// ============================================================
// MARK: - MARKET CELL
// ============================================================

enum MarketCellState: String {

    case stable
    case rising
    case stressed
    case critical
    case crash

    var name: String {
        switch self {
        case .stable:
            return "Stable"
        case .rising:
            return "Rising"
        case .stressed:
            return "Stressed"
        case .critical:
            return "Critical"
        case .crash:
            return "Release"
        }
    }
}

struct MarketCell: Identifiable {

    let id: Int

    var energy: Double
    var momentum: Double

    var momentumChange: Double

    var equilibrium: Double
    var equilibriumInflection: Double

    var inflationExhaustion: Double
    var taxationExhaustion: Double
    var stockGrowthExhaustion: Double

    var contagionExhaustion: Double
    var intervalExhaustion: Double
    var internalExhaustion: Double

    var exhaustion: Double
    var stress: Double

    var state: MarketCellState
}
struct MarketSimulationResult {

    let year: Int

    let moneyPressure: Double
    let inflationPressure: Double
    let taxationPressure: Double

    let economicGrowthPressure: Double
    let stockGrowthPressure: Double
    let stockSlowdownPressure: Double

    let bondPressure: Double
    let volumePressure: Double
    let cyclePressure: Double
    let shockPressure: Double

    let meanEnergy: Double
    let meanMomentum: Double
    let meanExhaustion: Double
    let meanStress: Double

    let criticalFraction: Double
    let releaseFraction: Double

    let usefulFuel: Double
    let overdrivePressure: Double

    // IMPORTANT:
    // This is the historical/model equilibrium measure.
    let equilibriumPressure: Double

    let equilibriumInflection: Double

    let systemicRisk: Double

    let cells: [MarketCell]

    var riskLevel: String {

        switch systemicRisk {
        case 0..<0.20:
            return "LOW"
        case 0.20..<0.40:
            return "MODERATE"
        case 0.40..<0.65:
            return "ELEVATED"
        case 0.65..<0.80:
            return "HIGH"
        default:
            return "CRITICAL"
        }
    }
}
