//
//  File.swift
//  Stock Crashes and ManiasTests
//
//  Created by David Nishimoto on 9/11/26.
//

import Foundation

import XCTest
@testable import Stock_Crashes_and_Manias

final class MarketExhaustionEngineTests: XCTestCase {

    func testSystemicRiskAcrossAllHistoricalCrashYears() {

        let historicalEngine = HistoricalMarketEngine()
        let engine = MarketExhaustionEngine()

        XCTAssertFalse(
            historicalEngine.periods.isEmpty,
            "Historical periods must load before systemic-risk testing."
        )

        var systemicResults: [(year: Int, systemicRisk: Double)] = []

        for period in historicalEngine.periods.sorted(by: {
            $0.crashYear < $1.crashYear
        }) {

            let analysis = historicalEngine.analysis(
                for: period
            )

            let previousStockGrowthPercent =
                period.priorYears
                    .sorted { $0.year < $1.year }
                    .dropFirst()
                    .first?
                    .stockGrowthPercent
                    ?? analysis.stockGrowth

            let result = engine.analyze(
                year: period.crashYear,

                growthM2:
                    analysis.m2Growth,

                inflationPercent:
                    analysis.inflation,

                taxGrowthPercent:
                    analysis.taxGrowth,

                economicGrowthPercent:
                    analysis.economicGrowth,

                stockGrowthPercent:
                    analysis.stockGrowth,

                previousStockGrowthPercent:
                    previousStockGrowthPercent,

                bondYieldAvgPercent:
                    analysis.bondYield,

                growthVolumePercent:
                    analysis.stockVolumeGrowth,

                crashInterval:
                    analysis.crashInterval,

                externalShockPercent:
                    0.0
            )

            systemicResults.append(
                (
                    year: period.crashYear,
                    systemicRisk: result.systemicRisk
                )
            )

            XCTAssertTrue(
                result.systemicRisk.isFinite,
                "\(period.crashYear): systemic risk is not finite."
            )

            XCTAssertGreaterThanOrEqual(
                result.systemicRisk,
                0.0,
                "\(period.crashYear): systemic risk is below 0."
            )

            XCTAssertLessThanOrEqual(
                result.systemicRisk,
                1.0,
                "\(period.crashYear): systemic risk is above 1."
            )
        }

        XCTAssertEqual(
            systemicResults.count,
            historicalEngine.periods.count,
            "Every historical crash period should produce one systemic-risk result."
        )

        for result in systemicResults {
            print(
                "Crash \(result.year): systemic risk = " +
                String(format: "%.4f", result.systemicRisk)
            )
        }
    }
}
