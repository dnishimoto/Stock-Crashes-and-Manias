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

    // --------------------------------------------------------
    // MARK: Load Historical Data
    // --------------------------------------------------------

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

        let valid: [Double] =
            values.compactMap { optionalValue in

                guard
                    let value = optionalValue,
                    value.isFinite
                else {
                    return nil
                }

                return value
            }

        guard !valid.isEmpty else {
            return 0
        }

        return
            valid.reduce(0, +) /
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

        guard
            let first = volumes.first,
            let last = volumes.last,
            first > 0
        else {
            return 0
        }

        return
            ((last - first) / first) * 100
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

        guard
            let index =
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
    // MARK: Historical Record Analysis
    // --------------------------------------------------------

    func analysis(
        for period: HistoricalCrashPeriod
    ) -> HistoricalAnalysis {

        // ----------------------------------------------------
        // Sorted historical rows
        // ----------------------------------------------------

        let historicalYears =
            period.priorYears.sorted {
                $0.year < $1.year
            }

        // The model stores only the year numbers in
        // HistoricalAnalysis.priorYearsUsed.
        //let priorYearNumbers: [Int] = historicalYears


        // ----------------------------------------------------
        // Historical averages
        // ----------------------------------------------------

        let m2Growth =
            average(
                historicalYears.map {
                    $0.m2GrowthPercent
                }
            )

        let moneyPolicyChangeImpact =
            average(
                historicalYears.compactMap {
                    $0.moneyPolicyChangeImpact
                }
            )

        let bankingCreditStressRating =
            average(
                historicalYears.compactMap {
                    $0.bankingCreditStressRating
                }
            )

        let inflation =
            average(
                historicalYears.map {
                    $0.inflationPercent
                }
            )

        let bondYield =
            average(
                historicalYears.map {
                    $0.bondYieldAvgPercent
                }
            )

        let taxGrowth =
            average(
                historicalYears.map {
                    $0.taxGrowthPercent
                }
            )

        let economicGrowth =
            average(
                historicalYears.map {
                    $0.economicGrowthPercent
                }
            )

        let stockGrowth =
            average(
                historicalYears.map {
                    $0.stockGrowthPercent
                }
            )

        // volumeGrowth() expects [Int].
        let stockVolumeGrowth =
            volumeGrowth(
                historicalYears
            )

        // crashInterval() currently returns a numeric value that
        // must be stored as Int in HistoricalAnalysis.
        let interval =
            Int(
                crashInterval(
                    for: period.crashYear
                )
            )

        // ----------------------------------------------------
        // Optimism
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

        let bankingSignal = normalize(bankingCreditStressRating, lower: 0, upper: 10)

        // ----------------------------------------------------
        // Optimism
        // ----------------------------------------------------
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
        // Higher value means stronger evidence that expansion
        // is losing acceleration.
        // ----------------------------------------------------

        let momentumTurn =
            clamp(
                1.0 -
                momentum +
                0.50 * inflationSignal +
                0.25 * bondSignal
            )

        // ----------------------------------------------------
        // Equilibrium
        //
        // Money + stock activity establish the expansion.
        // Equilibrium increases as marginal momentum weakens
        // under increasing pressure.
        // Banking stress is now included as a direct term.
        // ----------------------------------------------------

        let cycleIntervalSignal =
            normalize(
                Double(interval),
                lower: 0,
                upper: 25
            )

        let equilibrium =
            clamp(
                0.45 * momentumTurn +
                0.25 * inflationSignal +
                0.15 * bondSignal +
                0.10 * volumeSignal +
                0.05 * cycleIntervalSignal +
                0.10 * bankingSignal
            )

        // ----------------------------------------------------
        // Power-law / cycle-pressure term
        //
        // This is a model-defined nonlinear pressure term.
        // It is not an empirical claim that the historical
        // crashes follow a measured power law.
        // ----------------------------------------------------

        let cycleTerm =
            cycleIntervalSignal

        let base =
            max(
                0.0,
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
                (
                    0.65 +
                    0.35 * equilibrium
                )
            )

        let  priorYearsUsed = historicalYears.map(\.year)
        // ----------------------------------------------------
        // HistoricalAnalysis
        // ----------------------------------------------------

        return HistoricalAnalysis(
            crashYear:
                period.crashYear,

            priorYearsUsed:
                priorYearsUsed,

            m2Growth:
                m2Growth,

            inflation:
                inflation,

            bondYield:
                bondYield,

            taxGrowth:
                taxGrowth,

            economicGrowth:
                economicGrowth,

            stockGrowth:
                stockGrowth,

            stockVolumeGrowth:
                stockVolumeGrowth,

            moneyPolicyChangeImpact:
                moneyPolicyChangeImpact,

            crashInterval:
                interval,

            optimism:
                optimism,

            momentum:
                momentum,

            momentumTurn:
                momentumTurn,

            equilibrium:
                equilibrium,

            powerLaw:
                powerLaw,

            // Cellular risk is calculated by the CA pipeline,
            // not by this historical-input analysis.
            cellularRisk:
                0.0,

            bankingCreditStressRating:
                bankingCreditStressRating
        )
    }

   
  

    // --------------------------------------------------------
    // MARK: Normalization
    // --------------------------------------------------------

    private func normalize(
        _ value: Double,
        lower: Double,
        upper: Double
    ) -> Double {

        guard
            value.isFinite,
            upper > lower
        else {
            return 0
        }

        return clamp(
            (value - lower) /
            (upper - lower)
        )
    }

    // --------------------------------------------------------
    // MARK: Clamp
    // --------------------------------------------------------

    private func clamp(
        _ value: Double
    ) -> Double {

        min(
            1,
            max(
                0,
                value.isFinite
                ? value
                : 0
            )
        )
    }
}

