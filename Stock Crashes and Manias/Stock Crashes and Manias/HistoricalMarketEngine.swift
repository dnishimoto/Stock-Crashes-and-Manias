//
//  File.swift
//  Stock Crashes and Manias
//
//  Created by David Nishimoto on 9/10/26.
//

import Foundation



final class HistoricalMarketEngine {

    private(set) var periods: [HistoricalCrashPeriod] = []

    init() {
        load()
    }

    private func load() {

        guard let data =
                historicalMarketJSON.data(
                    using: .utf8
                )
        else {
            periods = []
            return
        }

        do {

            let decoded =
                try JSONDecoder()
                    .decode(
                        HistoricalJSONRoot.self,
                        from: data
                    )

            periods =
                decoded.crashPeriods

        } catch {

            print(
                "Historical JSON decode error: \(error)"
            )

            periods = []
        }
    }

    // --------------------------------------------------------
    // MARK: Average Optional Values
    // --------------------------------------------------------

    private func average(
        _ values: [Double?]
    ) -> Double {


        let valid: [Double] = values.compactMap { optionalValue in
            guard let value = optionalValue, value.isFinite else {
                return nil
            }

            return value
        }

        guard !valid.isEmpty else {
            return 0
        }

        return valid.reduce(0, +) /
            Double(valid.count)
    }

    // --------------------------------------------------------
    // MARK: Volume Growth
    // --------------------------------------------------------

    private func volumeGrowth(
        _ years: [HistoricalYear]
    ) -> Double {

        let volumes =
            years.compactMap {
                $0.stockVolumeMillions
            }

        guard volumes.count >= 2 else {
            return 0
        }

        guard let first = volumes.first,
              let last = volumes.last,
              first > 0
        else {
            return 0
        }

        return ((last - first) / first) * 100
    }

    // --------------------------------------------------------
    // MARK: Crash Interval
    // --------------------------------------------------------

    func crashInterval(
        for crashYear: Int
    ) -> Double {

        let sorted =
            periods
                .map(\.crashYear)
                .sorted()

        guard let index =
                sorted.firstIndex(
                    of: crashYear
                )
        else {
            return 0
        }

        guard index > 0 else {
            return 0
        }

        return Double(
            crashYear -
            sorted[index - 1]
        )
    }

    // --------------------------------------------------------
    // MARK: Historical Record
    // --------------------------------------------------------

    func analysis(
        for period: HistoricalCrashPeriod
    ) -> HistoricalAnalysis {

        let years =
            period.priorYears.sorted {
                $0.year < $1.year
            }

        let m2Growth =
            average(
                years.map {
                    $0.m2GrowthPercent
                }
            )

        let moneyPolicyChangeImpact = average(
            period.priorYears.compactMap(\.moneyPolicyChangeImpact)
        )
        
        let bankingCreditStressRating = average(
            period.priorYears.compactMap(\.bankingCreditStressRating)
        )
        
        let inflation =
            average(
                years.map {
                    $0.inflationPercent
                }
            )

        let bondYield =
            average(
                years.map {
                    $0.bondYieldAvgPercent
                }
            )

        let taxGrowth =
            average(
                years.map {
                    $0.taxGrowthPercent
                }
            )

        let economicGrowth =
            average(
                years.map {
                    $0.economicGrowthPercent
                }
            )

        let stockGrowth =
            average(
                years.map {
                    $0.stockGrowthPercent
                }
            )

        let stockVolumeGrowth =
            volumeGrowth(years)

        let interval =
            crashInterval(
                for: period.crashYear
            )

        // ----------------------------------------------------
        // Optimism
        //
        // Money growth + stock growth + volume expansion.
        // Inflation and rates act as counter-pressure.
        // ----------------------------------------------------

        let moneySignal =
            normalize(
                m2Growth,
                lower: -5,
                upper: 20
            )

        let stockSignal =
            normalize(
                stockGrowth,
                lower: -50,
                upper: 100
            )

        let volumeSignal =
            normalize(
                stockVolumeGrowth,
                lower: -50,
                upper: 300
            )

        let inflationSignal =
            normalize(
                inflation,
                lower: 0,
                upper: 15
            )

        let bondSignal =
            normalize(
                bondYield,
                lower: 0,
                upper: 15
            )

        let optimism =
            clamp(
                0.40 * moneySignal +
                0.40 * stockSignal +
                0.20 * volumeSignal -
                0.10 * inflationSignal -
                0.10 * bondSignal
            )

        // ----------------------------------------------------
        // Momentum
        // ----------------------------------------------------

        let momentum =
            clamp(
                0.45 * moneySignal +
                0.35 * stockSignal +
                0.20 * volumeSignal
            )

        // ----------------------------------------------------
        // Momentum Turn
        //
        // Higher value means stronger evidence that the
        // expansion is losing acceleration.
        // ----------------------------------------------------

        let momentumTurn =
            clamp(
                1 -
                momentum +
                0.50 * inflationSignal +
                0.25 * bondSignal
            )

        // ----------------------------------------------------
        // Equilibrium
        //
        // The central historical measure.
        //
        // Money + stock activity establish the expansion.
        // The equilibrium appears when marginal momentum
        // begins to weaken under increasing pressure.
        // ----------------------------------------------------

        let equilibrium =
            clamp(
                0.45 * momentumTurn +
                0.25 * inflationSignal +
                0.15 * bondSignal +
                0.10 * volumeSignal +
                0.05 *
                normalize(
                    interval,
                    lower: 0,
                    upper: 25
                )
            )

        // ----------------------------------------------------
        // Power Law
        //
        // Inputs:
        //   x = optimism
        //   y = equilibrium
        //
        // Interval is included only as a weak cycle term.
        //
        // This is deliberately bounded so a missing or zero
        // historical value does not create NaN/Infinity.
        // ----------------------------------------------------

        let cycleTerm =
            normalize(
                interval,
                lower: 0,
                upper: 25
            )

        let base =
            max(
                0,
                optimism
            )

        let exponent =
            0.75 +
            0.50 * cycleTerm

        let powerLaw =
            clamp(
                pow(
                    base,
                    exponent
                ) *
                (0.65 + 0.35 * equilibrium)
            )


        
        return HistoricalAnalysis(
            crashYear: period.crashYear,
            priorYearsUsed: years.count,
            m2Growth: m2Growth,
            inflation: inflation,
            bondYield: bondYield,
            taxGrowth: taxGrowth,
            economicGrowth: economicGrowth,
            stockGrowth: stockGrowth,
            stockVolumeGrowth: stockVolumeGrowth,
            moneyPolicyChangeImpact: moneyPolicyChangeImpact,
            crashInterval: interval,
            optimism: optimism,
            momentum: momentum,
            momentumTurn: momentumTurn,
            equilibrium: equilibrium,
            powerLaw: powerLaw,
            cellularRisk: 0,
            bankingCreditStressRating: bankingCreditStressRating
        )
    }

    // --------------------------------------------------------
    // MARK: Cellular Automaton Analysis (Historical)
    // --------------------------------------------------------
    //
    // Runs the SAME MarketExhaustionEngine cellular automaton
    // used for the current year against the years leading up
    // to a historical crash, so energy / momentum / exhaustion /
    // equilibrium are directly comparable across every event.
    //

    func caAnalysis(
        for period: HistoricalCrashPeriod,
        using engine: MarketExhaustionEngine
    ) -> MarketSimulationResult {

        let years =
            period.priorYears.sorted {
                $0.year < $1.year
            }

        let growthM2 =
            average(
                years.map {
                    $0.m2GrowthPercent
                }
            )

        let inflationPercent =
            average(
                years.map {
                    $0.inflationPercent
                }
            )

        let taxGrowthPercent =
            average(
                years.map {
                    $0.taxGrowthPercent
                }
            )

        let economicGrowthPercent =
            average(
                years.map {
                    $0.economicGrowthPercent
                }
            )

        let bondYieldAvgPercent =
            average(
                years.map {
                    $0.bondYieldAvgPercent
                }
            )

        let growthVolumePercent =
            volumeGrowth(years)

        let interval =
            crashInterval(
                for: period.crashYear
            )

        // The two years closest to the crash carry the
        // slowdown signal the CA relies on.

        let stockGrowthPercent =
            years.last?.stockGrowthPercent ?? 0

        let previousStockGrowthPercent =
            years.count >= 2
            ? (years[years.count - 2].stockGrowthPercent
                ?? stockGrowthPercent)
            : stockGrowthPercent

        let moneyPolicyChangeImpact = average(
            period.priorYears.compactMap(\.moneyPolicyChangeImpact)
        )
        let bankingCreditStressRating = average(
            years.map {
                $0.bankingCreditStressRating
            }
        )


        return engine.analyze(
            year: period.crashYear,
            growthM2: growthM2,
            moneyPolicyChangeImpact: moneyPolicyChangeImpact,
            bankingCreditStressRating: bankingCreditStressRating,
            inflationPercent: inflationPercent,
            taxGrowthPercent: taxGrowthPercent,
            economicGrowthPercent: economicGrowthPercent,
            stockGrowthPercent: stockGrowthPercent,
            previousStockGrowthPercent:
                previousStockGrowthPercent,
            bondYieldAvgPercent: bondYieldAvgPercent,
            growthVolumePercent: growthVolumePercent,
            crashInterval: interval,
            externalShockPercent: 0
        )
    }

    private func normalize(
        _ value: Double,
        lower: Double,
        upper: Double
    ) -> Double {

        guard value.isFinite,
              upper > lower
        else {
            return 0
        }

        return clamp(
            (value - lower) /
            (upper - lower)
        )
    }

    private func clamp(
        _ value: Double
    ) -> Double {

        min(
            1,
            max(
                0,
                value.isFinite ? value : 0
            )
        )
    }
}
