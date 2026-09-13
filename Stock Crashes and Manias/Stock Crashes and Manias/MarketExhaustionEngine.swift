//
//  MarketExhaustionEngine.swift
//  Stock Crashes and Manias
//
//  Created by David Nishimoto on 9/10/26.
//

import Foundation
import SwiftUI
import Combine

// ============================================================
// MARK: - Canonical Market Scenario
// ============================================================
//
// This is the single input object passed into the cellular
// automaton.
//
// Raw historical observations are converted into this structure
// before entering the CA.
//
// The CA should never need to know where the values came from.
//

struct MarketScenario: Equatable {

    var moneySupplyChangePercent: Double = 0.0
    var inflationPercent: Double = 0.0
    var taxationPercent: Double = 0.0
    var economicGrowthPercent: Double = 0.0
    var stockGrowthPercent: Double = 0.0
    var previousStockGrowthPercent: Double = 0.0
    var bondYieldAvgPercent: Double = 0.0
    var bankingCreditStressRating: Double = 0.0
    var moneyPolicyChangeImpact: Double = 0.0

    /// Deliberately interpreted as magnitude by the CA.
    var externalShockMagnitudePercent: Double = 0.0

    init(
        moneySupplyChangePercent: Double = 0.0,
        inflationPercent: Double = 0.0,
        taxationPercent: Double = 0.0,
        economicGrowthPercent: Double = 0.0,
        stockGrowthPercent: Double = 0.0,
        previousStockGrowthPercent: Double = 0.0,
        bondYieldAvgPercent: Double = 0.0,
        bankingCreditStressRating: Double = 0.0,
        moneyPolicyChangeImpact: Double = 0.0,
        externalShockMagnitudePercent: Double = 0.0
    ) {
        self.moneySupplyChangePercent = moneySupplyChangePercent
        self.inflationPercent = inflationPercent
        self.taxationPercent = taxationPercent
        self.economicGrowthPercent = economicGrowthPercent
        self.stockGrowthPercent = stockGrowthPercent
        self.previousStockGrowthPercent = previousStockGrowthPercent
        self.bondYieldAvgPercent = bondYieldAvgPercent
        self.bankingCreditStressRating = bankingCreditStressRating
        self.moneyPolicyChangeImpact = moneyPolicyChangeImpact
        self.externalShockMagnitudePercent = externalShockMagnitudePercent
    }
}

// ============================================================
// MARK: - Engine
// ============================================================

@MainActor
final class MarketExhaustionEngine: ObservableObject {

    // --------------------------------------------------------
    // Historical crash records
    // --------------------------------------------------------

    private(set) var crashRecords: [CrashRecord] = [

        CrashRecord(
            year: 1907,
            volumeMillions: 210.0
        ),

        CrashRecord(
            year: 1929,
            volumeMillions: 600.0
        ),

        CrashRecord(
            year: 1937,
            volumeMillions: 500.0
        ),

        CrashRecord(
            year: 1962,
            volumeMillions: 900.0
        ),

        CrashRecord(
            year: 1970,
            volumeMillions: 1100.0
        ),

        CrashRecord(
            year: 1973,
            volumeMillions: 1400.0
        ),

        CrashRecord(
            year: 1974,
            volumeMillions: 1500.0
        ),

        CrashRecord(
            year: 1987,
            volumeMillions: 3000.0
        ),

        CrashRecord(
            year: 1990,
            volumeMillions: 3200.0
        ),

        CrashRecord(
            year: 2000,
            volumeMillions: 5000.0
        ),

        CrashRecord(
            year: 2008,
            volumeMillions: 7000.0
        ),

        CrashRecord(
            year: 2020,
            volumeMillions: 9000.0
        ),

        CrashRecord(
            year: 2022,
            volumeMillions: 10000.0
        )
    ]

    // --------------------------------------------------------
    // Simulation
    // --------------------------------------------------------

    private(set) var cells: [MarketCell] = []

    let gridWidth: Int
    let gridHeight: Int

    var parameters: MarketParameters

    private(set) var yearlyRiskHistory: [YearlyRiskSnapshot] = []

    // --------------------------------------------------------
    // Random source
    // --------------------------------------------------------

    private let randomSeed: UInt64
    private var random: SplitMix64

    // --------------------------------------------------------
    // Historical macro data
    // --------------------------------------------------------

    private lazy var historicalYears: [HistoricalYear] = {
        loadHistoricalYears()
    }()

    // ========================================================
    // MARK: - Initialization
    // ========================================================

    init(
        parameters: MarketParameters = MarketParameters(),
        seed: UInt64 = 42
    ) {
        self.parameters = parameters

        self.gridWidth = max(
            parameters.gridWidth,
            1
        )

        self.gridHeight = max(
            parameters.gridHeight,
            1
        )

        self.randomSeed = seed
        self.random = SplitMix64(
            seed: seed
        )

        resetCells()
    }

    // ========================================================
    // MARK: - Numeric Helpers
    // ========================================================

    private func bounded(
        _ value: Double,
        minimum: Double = 0.0,
        maximum: Double = 1.0
    ) -> Double {

        guard value.isFinite else {
            return minimum
        }

        return min(
            max(
                value,
                minimum
            ),
            maximum
        )
    }

    private func safeDivide(
        _ numerator: Double,
        _ denominator: Double,
        fallback: Double = 0.0
    ) -> Double {

        guard numerator.isFinite,
              denominator.isFinite,
              abs(denominator) > Double.leastNonzeroMagnitude
        else {
            return fallback
        }

        let result = numerator / denominator

        guard result.isFinite else {
            return fallback
        }

        return result
    }

    private func normalized(
        _ value: Double,
        minimum: Double,
        maximum: Double
    ) -> Double {

        guard maximum > minimum else {
            return 0.0
        }

        return bounded(
            safeDivide(
                value - minimum,
                maximum - minimum
            )
        )
    }

    // ========================================================
    // MARK: - Historical Data Loading
    // ========================================================

    private func loadHistoricalYears() -> [HistoricalYear] {

        guard let data = historicalMarketJSON.data(
            using: .utf8
        ) else {
            return []
        }

        do {

            let root = try JSONDecoder().decode(
                HistoricalJSONRoot.self,
                from: data
            )

            var result: [HistoricalYear] = []

            for period in root.crashPeriods {

                result.append(
                    contentsOf: period.priorYears
                )
            }

            // Remove duplicate years.
            var byYear: [Int: HistoricalYear] = [:]

            for item in result {
                byYear[item.year] = item
            }

            return byYear.values.sorted {
                $0.year < $1.year
            }

        } catch {

            return []
        }
    }

    // ========================================================
    // MARK: - Historical Scenario
    // ========================================================

    /// Returns the latest historical observation that would
    /// have been available for the requested year.
    ///
    /// Example:
    ///
    /// analyze 2008
    ///      ↓
    /// latest embedded observation <= 2008
    ///      ↓
    /// 2007 data
    ///
    /// This avoids using future information.
    private func historicalScenario(
        for year: Int
    ) -> MarketScenario {

        let eligible = historicalYears.filter {
            $0.year <= year
        }

        guard let current = eligible.last else {
            return MarketScenario()
        }

        let previous = eligible.dropLast().last

        return MarketScenario(

            moneySupplyChangePercent:
                finiteOrZero(
                    current.m2GrowthPercent
                ),

            inflationPercent:
                finiteOrZero(
                    current.inflationPercent
                ),

            taxationPercent:
                finiteOrZero(
                    current.taxGrowthPercent
                ),

            economicGrowthPercent:
                finiteOrZero(
                    current.economicGrowthPercent
                ),

            stockGrowthPercent:
                finiteOrZero(
                    current.stockGrowthPercent
                ),

            previousStockGrowthPercent:
                finiteOrZero(
                    previous?.stockGrowthPercent
                ),

            bondYieldAvgPercent:
                finiteOrZero(
                    current.bondYieldAvgPercent
                ),

            bankingCreditStressRating:
                finiteOrZero(
                    current.bankingCreditStressRating
                ),

            moneyPolicyChangeImpact:
                finiteOrZero(
                    current.moneyPolicyChangeImpact
                ),

            externalShockMagnitudePercent:
                0.0
        )
    }

    private func finiteOrZero(
        _ value: Double?
    ) -> Double {

        guard let value,
              value.isFinite
        else {
            return 0.0
        }

        return value
    }

    // ========================================================
    // MARK: - Historical Cycle Pressure
    // ========================================================

    /// Backward-compatible public API.
    ///
    /// This is retained for the UI and existing callers.
    ///
    /// Internally the quantity is a model-defined cycle-pressure
    /// exponent derived from crash-interval dispersion. It is not
    /// a conventional statistical power-law maximum-likelihood
    /// exponent.
    func estimatePowerLawAlpha() -> Double {

        guard crashRecords.count >= 2 else {
            return 2.0
        }

        return estimateCyclePressureExponent(
            upThroughCrashIndex:
                crashRecords.count - 1
        )
    }

    private func estimateCyclePressureExponent(
        upThroughCrashIndex crashIndex: Int
    ) -> Double {

        guard crashIndex > 0,
              crashIndex < crashRecords.count
        else {
            return 2.0
        }

        let intervals = crashIntervals(
            upThroughCrashIndex:
                crashIndex
        )

        guard intervals.count >= 2 else {
            return 2.0
        }

        let mean =
            intervals.reduce(
                0.0,
                +
            ) /
            Double(intervals.count)

        guard mean > 0.0,
              mean.isFinite
        else {
            return 2.0
        }

        var variance = 0.0

        for interval in intervals {

            let difference =
                interval - mean

            variance +=
                difference * difference
        }

        variance /=
            Double(
                max(
                    intervals.count - 1,
                    1
                )
            )

        let standardDeviation =
            sqrt(
                max(
                    variance,
                    0.0
                )
            )

        guard standardDeviation.isFinite else {
            return 2.0
        }

        let coefficient =
            safeDivide(
                standardDeviation,
                mean,
                fallback: 0.0
            )

        let boundedCoefficient =
            min(
                max(
                    coefficient,
                    0.0
                ),
                2.0
            )

        let alpha =
            1.0 +
            boundedCoefficient

        return bounded(
            alpha / 3.0,
            minimum: 0.25,
            maximum: 1.0
        )
    }

    // ========================================================
    // MARK: - Crash Intervals
    // ========================================================

    private func crashIntervals() -> [Double] {

        guard crashRecords.count >= 2 else {
            return []
        }

        return crashIntervals(
            upThroughCrashIndex:
                crashRecords.count - 1
        )
    }

    private func crashIntervals(
        upThroughCrashIndex crashIndex: Int
    ) -> [Double] {

        guard crashIndex > 0,
              crashIndex < crashRecords.count
        else {
            return []
        }

        var result: [Double] = []

        for index in 1...crashIndex {

            let previous =
                crashRecords[index - 1]

            let current =
                crashRecords[index]

            let interval =
                Double(
                    max(
                        current.year -
                        previous.year,
                        1
                    )
                )

            if interval.isFinite {
                result.append(interval)
            }
        }

        return result
    }

    // ========================================================
    // MARK: - Cycle Pressure
    // ========================================================

    func powerLawPressure(
        yearsSinceCrash: Int
    ) -> Double {

        let intervals =
            crashIntervals()

        let alpha =
            estimatePowerLawAlpha()

        return powerLawPressure(
            yearsSinceCrash:
                yearsSinceCrash,
            alpha:
                alpha,
            intervals:
                intervals
        )
    }

    private func powerLawPressure(
        yearsSinceCrash: Int,
        alpha: Double,
        intervals: [Double]
    ) -> Double {

        guard !intervals.isEmpty else {
            return 0.0
        }

        let positiveIntervals =
            intervals.filter {
                $0.isFinite &&
                $0 > 0.0
            }

        guard !positiveIntervals.isEmpty else {
            return 0.0
        }

        let meanInterval =
            positiveIntervals.reduce(
                0.0,
                +
            ) /
            Double(
                positiveIntervals.count
            )

        guard meanInterval > 0.0 else {
            return 0.0
        }

        let elapsed =
            max(
                Double(yearsSinceCrash),
                0.0
            )

        let x =
            safeDivide(
                elapsed + 1.0,
                meanInterval + 1.0,
                fallback: 0.0
            )

        let exponent =
            min(
                max(
                    alpha,
                    0.05
                ),
                4.0
            )

        let raw =
            pow(
                max(x, 0.0),
                exponent
            )

        guard raw.isFinite else {
            return 0.0
        }

        return bounded(raw)
    }

    // ========================================================
    // MARK: - Volume Pressure
    // ========================================================

    func calculateVolumePressure() -> Double {

        guard crashRecords.count >= 3 else {
            return 0.0
        }

        let recent =
            crashRecords[
                crashRecords.count - 1
            ]

        let previous =
            crashRecords[
                crashRecords.count - 2
            ]

        let older =
            crashRecords[
                crashRecords.count - 3
            ]

        return volumePressure(
            recent:
                recent.volumeMillions,
            previous:
                previous.volumeMillions,
            older:
                older.volumeMillions
        )
    }

    private func calculateCurrentVolumePressure(
        points: [MarketVolumePoint]
    ) -> Double {

        let sorted =
            points.sorted {
                $0.year < $1.year
            }

        guard sorted.count >= 3 else {
            return 0.0
        }

        let recent =
            sorted[sorted.count - 1]
                .volumeMillions

        let previous =
            sorted[sorted.count - 2]
                .volumeMillions

        let older =
            sorted[sorted.count - 3]
                .volumeMillions

        return volumePressure(
            recent:
                recent,
            previous:
                previous,
            older:
                older
        )
    }

    /// Calculates pressure from the three crash observations
    /// immediately available at a given historical year.
    ///
    /// This is deliberately not called with the terminal crash
    /// record for every year of a historical interval.
    private func historicalVolumePressure(
        forYear year: Int
    ) -> Double {

        let eligible =
            crashRecords.filter {
                $0.year <= year
            }

        guard eligible.count >= 3 else {
            return 0.0
        }

        let recent =
            eligible[eligible.count - 1]

        let previous =
            eligible[eligible.count - 2]

        let older =
            eligible[eligible.count - 3]

        return volumePressure(
            recent:
                recent.volumeMillions,
            previous:
                previous.volumeMillions,
            older:
                older.volumeMillions
        )
    }

    private func historicalVolumePressure(
        crashIndex: Int
    ) -> Double {

        guard crashIndex >= 2,
              crashIndex < crashRecords.count
        else {
            return 0.0
        }

        let recent =
            crashRecords[crashIndex]

        let previous =
            crashRecords[crashIndex - 1]

        let older =
            crashRecords[crashIndex - 2]

        return volumePressure(
            recent:
                recent.volumeMillions,
            previous:
                previous.volumeMillions,
            older:
                older.volumeMillions
        )
    }

    private func volumePressure(
        recent: Double,
        previous: Double,
        older: Double
    ) -> Double {

        guard recent.isFinite,
              previous.isFinite,
              older.isFinite
        else {
            return 0.0
        }

        let previousGrowth =
            safeDivide(
                previous - older,
                max(
                    abs(older),
                    1.0
                )
            )

        let recentGrowth =
            safeDivide(
                recent - previous,
                max(
                    abs(previous),
                    1.0
                )
            )

        let acceleration =
            recentGrowth -
            previousGrowth

        let growthComponent =
            bounded(
                max(
                    recentGrowth,
                    0.0
                )
            )

        let accelerationComponent =
            bounded(
                max(
                    acceleration,
                    0.0
                )
            )

        return bounded(
            0.70 * growthComponent +
            0.30 * accelerationComponent
        )
    }

    // ========================================================
    // MARK: - Cellular Automaton Reset
    // ========================================================

    func resetCells() {

        // Reset deterministic random stream.
        random =
            SplitMix64(
                seed: randomSeed
            )

        cells.removeAll(
            keepingCapacity: true
        )

        let count =
            gridWidth *
            gridHeight

        guard count > 0 else {
            yearlyRiskHistory.removeAll()
            return
        }

        cells.reserveCapacity(
            count
        )

        for _ in 0..<count {

            let energyVariation =
                (
                    random.nextUnit() -
                    0.5
                ) * 0.10

            let initialEnergy =
                bounded(
                    parameters.initialEnergy +
                    energyVariation
                )

            cells.append(
                MarketCell(
                    energy:
                        initialEnergy,

                    momentum:
                        0.0,

                    liquidity:
                        bounded(
                            parameters.initialLiquidity
                        ),

                    capital:
                        bounded(
                            parameters.initialCapital
                        ),

                    exhaustion:
                        0.0,

                    stress:
                        0.0,

                    financialPotential:
                        0.0,

                    contagion:
                        0.0,

                    dissipation:
                        0.0,

                    state:
                        .stable
                )
            )
        }

        yearlyRiskHistory.removeAll()
    }

    // ========================================================
    // MARK: - Neighbor Indices
    // ========================================================

    private func neighborIndices(
        for index: Int
    ) -> [Int] {

        guard index >= 0,
              index < cells.count
        else {
            return []
        }

        let x =
            index % gridWidth

        let y =
            index / gridWidth

        let directions: [(Int, Int)]

        if parameters.diagonalNeighbors {

            directions = [

                (-1, -1),
                ( 0, -1),
                ( 1, -1),

                (-1,  0),
                ( 1,  0),

                (-1,  1),
                ( 0,  1),
                ( 1,  1)
            ]

        } else {

            directions = [

                ( 0, -1),
                (-1,  0),
                ( 1,  0),
                ( 0,  1)
            ]
        }

        var neighbors: [Int] = []

        for (dx, dy) in directions {

            let nx =
                x + dx

            let ny =
                y + dy

            guard nx >= 0,
                  nx < gridWidth,
                  ny >= 0,
                  ny < gridHeight
            else {
                continue
            }

            neighbors.append(
                ny * gridWidth + nx
            )
        }

        return neighbors
    }

    // ========================================================
    // MARK: - Cellular Automaton Step
    // ========================================================

    /// Advances exactly one synchronous CA generation.
    ///
    /// Every cell reads only from previousCells.
    func stepCA(
        equilibriumPressure: Double,
        volumePressure: Double,
        scenario: MarketScenario
    ) {

        guard !cells.isEmpty else {
            return
        }

        let previousCells =
            cells

        // ----------------------------------------------------
        // 1. System pressures
        // ----------------------------------------------------

        let normalizedEquilibrium =
            bounded(
                equilibriumPressure
            )

        let normalizedVolume =
            bounded(
                volumePressure
            )

        // ----------------------------------------------------
        // 2. Macro normalization
        // ----------------------------------------------------

        // Money supply:
        // ±20% = strong model range.
        let moneySupplyForcing =
            bounded(
                scenario.moneySupplyChangePercent / 20.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // Inflation:
        // 10% = strong model range.
        let inflationForcing =
            bounded(
                scenario.inflationPercent / 10.0
            )

        // Tax growth:
        // -50%...+50% model range.
        let taxationForcing =
            bounded(
                scenario.taxationPercent / 50.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // Economic growth:
        // ±15% gives more room than the previous ±10%
        // historical dataset normalization.
        let growthForcing =
            bounded(
                scenario.economicGrowthPercent / 15.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // Stock growth:
        // ±60% gives additional room for historical extremes.
        let stockGrowthForcing =
            bounded(
                scenario.stockGrowthPercent / 60.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // ----------------------------------------------------
        // Stock-growth slowdown
        // ----------------------------------------------------

        let stockGrowthChange =
            scenario.stockGrowthPercent -
            scenario.previousStockGrowthPercent

        let stockGrowthSlowdown =
            bounded(
                -stockGrowthChange / 20.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // ----------------------------------------------------
        // Bond yields
        // ----------------------------------------------------

        let bondYieldPressure =
            bounded(
                scenario.bondYieldAvgPercent / 10.0
            )

        // ----------------------------------------------------
        // Banking stress
        //
        // Historical JSON uses approximately 0...10.
        // ----------------------------------------------------

        let bankingStress =
            bounded(
                scenario.bankingCreditStressRating / 10.0
            )

        // ----------------------------------------------------
        // Monetary policy
        //
        // Historical JSON uses approximately -10...+10.
        // ----------------------------------------------------

        let policyForcing =
            bounded(
                scenario.moneyPolicyChangeImpact / 10.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // ----------------------------------------------------
        // External shock magnitude
        // ----------------------------------------------------

        let externalShock =
            bounded(
                abs(
                    scenario.externalShockMagnitudePercent
                ) / 20.0
            )

        // ----------------------------------------------------
        // 3. Base market forcing
        // ----------------------------------------------------

        let externalForcing =
            bounded(
                parameters.equilibriumWeight *
                normalizedEquilibrium
                +
                parameters.volumeWeight *
                normalizedVolume
            )

        // ----------------------------------------------------
        // 4. Macro energy
        // ----------------------------------------------------

        let expansionaryEnergy =
            max(
                moneySupplyForcing,
                0.0
            ) * 0.30
            +
            max(
                growthForcing,
                0.0
            ) * 0.20
            +
            max(
                stockGrowthForcing,
                0.0
            ) * 0.10
            +
            max(
                policyForcing,
                0.0
            ) * 0.10

        let contractionaryEnergy =
            max(
                -moneySupplyForcing,
                0.0
            ) * 0.25
            +
            inflationForcing * 0.10
            +
            max(
                taxationForcing,
                0.0
            ) * 0.10
            +
            bondYieldPressure * 0.15
            +
            bankingStress * 0.15
            +
            externalShock * 0.15

        let macroEnergyForcing =
            bounded(
                expansionaryEnergy -
                contractionaryEnergy,
                minimum: -1.0,
                maximum: 1.0
            )

        // ----------------------------------------------------
        // 5. Macro momentum
        // ----------------------------------------------------

        let expansionaryMomentum =
            moneySupplyForcing * 0.35
            +
            growthForcing * 0.20
            +
            stockGrowthForcing * 0.20
            +
            policyForcing * 0.10

        let contractionaryMomentum =
            max(
                stockGrowthSlowdown,
                0.0
            ) * 0.20
            +
            bondYieldPressure * 0.15
            +
            bankingStress * 0.20
            +
            externalShock * 0.15

        let macroMomentumForcing =
            bounded(
                expansionaryMomentum -
                contractionaryMomentum,
                minimum: -1.0,
                maximum: 1.0
            )

        // ----------------------------------------------------
        // 6. Macro stress
        // ----------------------------------------------------

        let macroStressForcing =
            bounded(
                inflationForcing * 0.15
                +
                max(
                    taxationForcing,
                    0.0
                ) * 0.10
                +
                bondYieldPressure * 0.15
                +
                bankingStress * 0.20
                +
                max(
                    stockGrowthSlowdown,
                    0.0
                ) * 0.15
                +
                externalShock * 0.20
                +
                max(
                    -growthForcing,
                    0.0
                ) * 0.10
            )

        // ====================================================
        // 7. Synchronous CA update
        // ====================================================

        for index in previousCells.indices {

            let previous =
                previousCells[index]

            // ------------------------------------------------
            // Neighbor field
            // ------------------------------------------------

            let neighbors =
                neighborIndices(
                    for: index
                )

            let neighborCount =
                max(
                    neighbors.count,
                    1
                )

            var neighborEnergy = 0.0
            var neighborMomentum = 0.0
            var neighborPotential = 0.0
            var neighborStress = 0.0

            for neighborIndex in neighbors {

                guard neighborIndex >= 0,
                      neighborIndex < previousCells.count
                else {
                    continue
                }

                let neighbor =
                    previousCells[
                        neighborIndex
                    ]

                neighborEnergy +=
                    neighbor.energy

                neighborMomentum +=
                    neighbor.momentum

                neighborPotential +=
                    neighbor.financialPotential

                neighborStress +=
                    neighbor.stress
            }

            neighborEnergy /=
                Double(neighborCount)

            neighborMomentum /=
                Double(neighborCount)

            neighborPotential /=
                Double(neighborCount)

            neighborStress /=
                Double(neighborCount)

            // ------------------------------------------------
            // Energy transfer
            // ------------------------------------------------

            let energyGradient =
                neighborEnergy -
                previous.energy

            let energyTransfer =
                energyGradient *
                parameters.energyTransferRate

            // ------------------------------------------------
            // Money supply energy
            // ------------------------------------------------

            let monetaryEnergy =
                moneySupplyForcing *
                parameters.moneySupplyEnergyWeight

            // ------------------------------------------------
            // Economic growth energy
            // ------------------------------------------------

            let growthEnergy =
                growthForcing *
                parameters.economicGrowthEnergyWeight

            // ------------------------------------------------
            // External shock energy
            // ------------------------------------------------

            let disturbanceEnergy =
                externalShock *
                parameters.externalShockEnergyWeight

            // ------------------------------------------------
            // Base injection
            // ------------------------------------------------

            let baseInjectedEnergy =
                externalForcing *
                parameters.energyInjectionRate

            let macroInjectedEnergy =
                macroEnergyForcing *
                parameters.macroEnergyInjectionRate

            // ------------------------------------------------
            // Retained energy
            // ------------------------------------------------

            let retainedEnergy =
                previous.energy *
                parameters.energyRetention

            // ------------------------------------------------
            // Preliminary energy
            // ------------------------------------------------

            let preliminaryEnergy =
                retainedEnergy
                +
                baseInjectedEnergy
                +
                macroInjectedEnergy
                +
                monetaryEnergy
                +
                growthEnergy
                +
                energyTransfer
                -
                disturbanceEnergy

            // ------------------------------------------------
            // Energy change
            // ------------------------------------------------

            let directionalChange =
                preliminaryEnergy -
                previous.energy

            // ------------------------------------------------
            // Momentum
            // ------------------------------------------------

            let preliminaryMomentum =
                previous.momentum *
                parameters.momentumRetention
                +
                directionalChange *
                parameters.momentumResponse
                +
                macroMomentumForcing *
                parameters.macroMomentumResponse

            // ------------------------------------------------
            // Financial potential
            // ------------------------------------------------

            let energyPotential =
                bounded(
                    preliminaryEnergy
                ) *
                parameters.potentialEnergyWeight

            let momentumPotential =
                abs(
                    preliminaryMomentum
                ) *
                parameters.potentialMomentumWeight

            let rawPotential =
                (
                    energyPotential +
                    momentumPotential
                ) *
                parameters.potentialGain

            let localPotential =
                bounded(
                    rawPotential
                )

            // ------------------------------------------------
            // Potential gradient
            // ------------------------------------------------

            let potentialGradient =
                neighborPotential -
                localPotential

            let potentialMomentum =
                potentialGradient *
                parameters.potentialGradientResponse

            // ------------------------------------------------
            // Momentum propagation
            // ------------------------------------------------

            let momentumGradient =
                neighborMomentum -
                previous.momentum

            let newMomentum =
                preliminaryMomentum
                +
                potentialMomentum
                +
                momentumGradient *
                parameters.momentumTransferRate

            // ------------------------------------------------
            // Liquidity depletion
            // ------------------------------------------------

            let liquidityPressure =
                localPotential *
                parameters.liquidityDepletionRate
                +
                inflationForcing *
                parameters.inflationLiquidityRate
                +
                bondYieldPressure *
                parameters.bondYieldLiquidityRate
                +
                bankingStress *
                parameters.bankingLiquidityRate
                +
                max(
                    taxationForcing,
                    0.0
                ) *
                parameters.taxLiquidityRate

            let newLiquidity =
                bounded(
                    previous.liquidity -
                    liquidityPressure
                )

            // ------------------------------------------------
            // Capital depletion
            // ------------------------------------------------

            let capitalPressure =
                localPotential *
                parameters.capitalDepletionRate
                +
                max(
                    taxationForcing,
                    0.0
                ) *
                parameters.taxCapitalRate
                +
                bankingStress *
                parameters.bankingCapitalRate
                +
                externalShock *
                parameters.externalShockCapitalRate

            let newCapital =
                bounded(
                    previous.capital -
                    capitalPressure
                )

            // ------------------------------------------------
            // Resource depletion
            // ------------------------------------------------

            let resourceDepletion =
                bounded(
                    1.0 -
                    (
                        0.40 * newLiquidity
                        +
                        0.40 * newCapital
                        +
                        0.20 *
                        bounded(
                            preliminaryEnergy
                        )
                    )
                )

            // ------------------------------------------------
            // Direct energy depletion
            // ------------------------------------------------

            let energyDepletion =
                bounded(
                    1.0 -
                    bounded(
                        preliminaryEnergy
                    )
                )

            // ------------------------------------------------
            // Exhaustion
            // ------------------------------------------------

            let exhaustionPressure =
                bounded(
                    resourceDepletion * 0.70
                    +
                    energyDepletion * 0.30
                )

            let recovery =
                previous.exhaustion *
                parameters.exhaustionRecoveryRate

            let accumulatedExhaustion =
                previous.exhaustion
                -
                recovery
                +
                exhaustionPressure *
                parameters.exhaustionAccumulationRate
                +
                macroStressForcing *
                parameters.macroExhaustionRate

            let newExhaustion =
                bounded(
                    accumulatedExhaustion
                )

            // ------------------------------------------------
            // Contagion
            // ------------------------------------------------

            let stressGradient =
                neighborStress -
                previous.stress

            let contagionInput =
                max(
                    stressGradient,
                    0.0
                )
                +
                neighborStress * 0.50

            let newContagion =
                bounded(
                    contagionInput *
                    parameters.contagionRate
                )

            // ------------------------------------------------
            // Dissipation
            // ------------------------------------------------

            let rawDissipation =
                previous.stress *
                parameters.dissipationRate

            let newDissipation =
                bounded(
                    rawDissipation
                )

            // ------------------------------------------------
            // Dissipation removes energy
            // ------------------------------------------------

            let dissipatedEnergy =
                newDissipation *
                parameters.energyDissipationWeight

            let finalEnergy =
                bounded(
                    preliminaryEnergy -
                    dissipatedEnergy
                )

            // ------------------------------------------------
            // Final energy depletion
            // ------------------------------------------------

            let finalEnergyDepletion =
                bounded(
                    1.0 -
                    finalEnergy
                )

            // ------------------------------------------------
            // Stress
            // ------------------------------------------------

            let stressFromEnergy =
                finalEnergyDepletion *
                parameters.energyDepletionStressWeight

            let stressFromMomentum =
                abs(
                    newMomentum
                ) *
                parameters.momentumWeight

            let stressFromPotential =
                localPotential *
                parameters.potentialWeight

            let stressFromExhaustion =
                newExhaustion *
                parameters.exhaustionWeight

            let stressFromContagion =
                newContagion *
                parameters.contagionWeight

            let stressFromMacro =
                macroStressForcing *
                parameters.macroStressWeight

            let stressFromExternalForcing =
                externalForcing *
                parameters.energyWeight

            let rawStress =
                stressFromEnergy
                +
                stressFromMomentum
                +
                stressFromPotential
                +
                stressFromExhaustion
                +
                stressFromContagion
                +
                stressFromMacro
                +
                stressFromExternalForcing
                -
                newDissipation

            // ------------------------------------------------
            // Stochastic perturbation
            // ------------------------------------------------

            let noise =
                (
                    random.nextUnit() -
                    0.5
                ) *
                parameters.stochasticNoise

            let newStress =
                bounded(
                    rawStress +
                    noise
                )

            // ------------------------------------------------
            // State transition
            // ------------------------------------------------

            let severeEnergyDepletion =
                finalEnergy <=
                parameters.severeEnergyDepletionThreshold

            let newState: MarketState

            if severeEnergyDepletion ||
                newStress >= parameters.crashedThreshold {

                newState = .crashed

            } else if newStress >=
                        parameters.criticalThreshold {

                newState = .critical

            } else if newStress >=
                        parameters.stressedThreshold {

                newState = .stressed

            } else if newStress >=
                        parameters.risingThreshold {

                newState = .rising

            } else {

                newState = .stable
            }

            // ------------------------------------------------
            // Commit
            // ------------------------------------------------

            cells[index].energy =
                finalEnergy

            cells[index].momentum =
                bounded(
                    newMomentum,
                    minimum: -1.0,
                    maximum: 1.0
                )

            cells[index].financialPotential =
                localPotential

            cells[index].liquidity =
                newLiquidity

            cells[index].capital =
                newCapital

            cells[index].exhaustion =
                newExhaustion

            cells[index].contagion =
                newContagion

            cells[index].dissipation =
                newDissipation

            cells[index].stress =
                newStress

            cells[index].state =
                newState
        }
    }

    // ========================================================
    // MARK: - Backward-Compatible stepCA
    // ========================================================

    /// Retained so existing callers do not break.
    func stepCA(
        equilibriumPressure: Double,
        volumePressure: Double,
        moneySupplyChangePercent: Double,
        inflationPercent: Double,
        taxationPercent: Double,
        economicGrowthPercent: Double,
        stockGrowthPercent: Double,
        previousStockGrowthPercent: Double,
        bondYieldAvgPercent: Double,
        bankingCreditStressRating: Double,
        moneyPolicyChangeImpact: Double,
        externalShockPercent: Double
    ) {

        let scenario =
            MarketScenario(
                moneySupplyChangePercent:
                    moneySupplyChangePercent,

                inflationPercent:
                    inflationPercent,

                taxationPercent:
                    taxationPercent,

                economicGrowthPercent:
                    economicGrowthPercent,

                stockGrowthPercent:
                    stockGrowthPercent,

                previousStockGrowthPercent:
                    previousStockGrowthPercent,

                bondYieldAvgPercent:
                    bondYieldAvgPercent,

                bankingCreditStressRating:
                    bankingCreditStressRating,

                moneyPolicyChangeImpact:
                    moneyPolicyChangeImpact,

                externalShockMagnitudePercent:
                    externalShockPercent
            )

        stepCA(
            equilibriumPressure:
                equilibriumPressure,
            volumePressure:
                volumePressure,
            scenario:
                scenario
        )
    }

    // ========================================================
    // MARK: - State Classification
    // ========================================================

    private func stateForStress(
        _ stress: Double
    ) -> MarketState {

        let value =
            bounded(stress)

        if value >= parameters.crashedThreshold {
            return .crashed
        }

        if value >= parameters.criticalThreshold {
            return .critical
        }

        if value >= parameters.stressedThreshold {
            return .stressed
        }

        if value >= parameters.risingThreshold {
            return .rising
        }

        return .stable
    }

    // ========================================================
    // MARK: - Run
    // ========================================================

    /// Runs the requested number of generations using one
    /// explicit scenario.
    func run(
        years: Int,
        equilibriumPressure: Double,
        volumePressure: Double,
        scenario: MarketScenario
    ) {

        guard years > 0 else {
            return
        }

        for _ in 0..<years {

            stepCA(
                equilibriumPressure:
                    equilibriumPressure,

                volumePressure:
                    volumePressure,

                scenario:
                    scenario
            )
        }
    }

    /// Backward-compatible run.
    ///
    /// Unlike the previous implementation this no longer feeds
    /// eleven unexplained literal zeroes into stepCA().
    ///
    /// A caller that has no macro scenario explicitly receives
    /// a neutral scenario.
    func run(
        years: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) {

        run(
            years:
                years,

            equilibriumPressure:
                equilibriumPressure,

            volumePressure:
                volumePressure,

            scenario:
                MarketScenario()
        )
    }

    // ========================================================
    // MARK: - Run One Year
    // ========================================================

    func runYear(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double,
        scenario: MarketScenario
    ) {

        stepCA(
            equilibriumPressure:
                equilibriumPressure,

            volumePressure:
                volumePressure,

            scenario:
                scenario
        )

        let snapshot =
            makeYearlyRiskSnapshot(
                year:
                    year,

                equilibriumPressure:
                    equilibriumPressure,

                volumePressure:
                    volumePressure
            )

        yearlyRiskHistory.append(
            snapshot
        )
    }

    /// Backward-compatible neutral-scenario overload.
    func runYear(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) {

        runYear(
            year:
                year,

            equilibriumPressure:
                equilibriumPressure,

            volumePressure:
                volumePressure,

            scenario:
                MarketScenario()
        )
    }

    // ========================================================
    // MARK: - Cellular Metrics
    // ========================================================

    func cellularStress() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let total =
            cells.reduce(
                0.0
            ) {
                $0 + $1.stress
            }

        return bounded(
            total /
            Double(cells.count)
        )
    }

    func averageEnergy() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        return bounded(
            cells.reduce(
                0.0
            ) {
                $0 + $1.energy
            }
            /
            Double(cells.count)
        )
    }

    func averageMomentum() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        return bounded(
            cells.reduce(
                0.0
            ) {
                $0 + $1.momentum
            }
            /
            Double(cells.count),
            minimum: -1.0,
            maximum: 1.0
        )
    }

    func averageFinancialPotential() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        return bounded(
            cells.reduce(
                0.0
            ) {
                $0 + $1.financialPotential
            }
            /
            Double(cells.count)
        )
    }

    func averageLiquidity() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        return bounded(
            cells.reduce(
                0.0
            ) {
                $0 + $1.liquidity
            }
            /
            Double(cells.count)
        )
    }

    func averageCapital() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        return bounded(
            cells.reduce(
                0.0
            ) {
                $0 + $1.capital
            }
            /
            Double(cells.count)
        )
    }

    func averageExhaustion() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        return bounded(
            cells.reduce(
                0.0
            ) {
                $0 + $1.exhaustion
            }
            /
            Double(cells.count)
        )
    }

    // ========================================================
    // MARK: - State Fractions
    // ========================================================

    /// Only .critical cells.
    ///
    /// Crashed cells are deliberately excluded so that the
    /// critical and crashed populations are mutually exclusive.
    func criticalCellFraction() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let critical =
            cells.filter {
                $0.state == .critical
            }.count

        return safeDivide(
            Double(critical),
            Double(cells.count)
        )
    }

    /// Only .crashed cells.
    func crashCellFraction() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let crashed =
            cells.filter {
                $0.state == .crashed
            }.count

        return safeDivide(
            Double(crashed),
            Double(cells.count)
        )
    }

    /// Critical + crashed.
    ///
    /// This is available separately so callers that want the
    /// broader distressed population do not overload the meaning
    /// of criticalCellFraction().
    func distressedCellFraction() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let distressed =
            cells.filter {
                $0.state == .critical ||
                $0.state == .crashed
            }.count

        return safeDivide(
            Double(distressed),
            Double(cells.count)
        )
    }

    // ========================================================
    // MARK: - Systemic Risk
    // ========================================================

    func systemicRisk() -> Double {

        let stress =
            cellularStress()

        let critical =
            criticalCellFraction()

        let crashed =
            crashCellFraction()

        let exhaustion =
            averageExhaustion()

        // These are mutually exclusive state populations.
        //
        // 35% average cell stress
        // 25% critical population
        // 25% crashed population
        // 15% exhaustion
        let risk =
            0.35 * stress
            +
            0.25 * critical
            +
            0.25 * crashed
            +
            0.15 * exhaustion

        return bounded(risk)
    }

    func riskLevel() -> MarketState {

        stateForStress(
            systemicRisk()
        )
    }

    // ========================================================
    // MARK: - Yearly Snapshot
    // ========================================================

    func makeYearlyRiskSnapshot(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) -> YearlyRiskSnapshot {

        YearlyRiskSnapshot(

            year:
                year,

            equilibriumPressure:
                bounded(
                    equilibriumPressure
                ),

            volumePressure:
                bounded(
                    volumePressure
                ),

            averageEnergy:
                averageEnergy(),

            averageMomentum:
                averageMomentum(),

            averageFinancialPotential:
                averageFinancialPotential(),

            averageLiquidity:
                averageLiquidity(),

            averageCapital:
                averageCapital(),

            averageExhaustion:
                averageExhaustion(),

            averageStress:
                cellularStress(),

            criticalFraction:
                criticalCellFraction(),

            crashFraction:
                crashCellFraction(),

            systemicRisk:
                systemicRisk(),

            riskLevel:
                riskLevel()
        )
    }

    // ========================================================
    // MARK: - Historical Anchor
    // ========================================================

    private func historicalCrashIndex(
        for year: Int
    ) -> Int? {

        crashRecords.indices.last(
            where: {
                crashRecords[$0].year <= year
            }
        )
    }

    // ========================================================
    // MARK: - Current Analysis
    // ========================================================

    func analyze(
        currentYear: Int,
        currentVolumePoints:
            [MarketVolumePoint] = []
    ) -> MarketRiskResult {

        resetCells()

        // ----------------------------------------------------
        // Historical crash anchor
        // ----------------------------------------------------

        let historicalIndex =
            historicalCrashIndex(
                for:
                    currentYear
            )

        let anchorYear =
            historicalIndex.map {
                crashRecords[$0].year
            }
            ??
            currentYear

        let yearsSinceCrash =
            max(
                currentYear -
                anchorYear,
                0
            )

        // ----------------------------------------------------
        // Cycle-pressure exponent
        // ----------------------------------------------------

        let alpha: Double

        if let index =
            historicalIndex {

            alpha =
                estimateCyclePressureExponent(
                    upThroughCrashIndex:
                        index
                )

        } else {

            alpha = 2.0
        }

        // ----------------------------------------------------
        // Historical intervals
        // ----------------------------------------------------

        let intervals: [Double]

        if let index =
            historicalIndex {

            intervals =
                crashIntervals(
                    upThroughCrashIndex:
                        index
                )

        } else {

            intervals = []
        }

        // ----------------------------------------------------
        // Equilibrium pressure
        // ----------------------------------------------------

        let equilibrium =
            powerLawPressure(
                yearsSinceCrash:
                    yearsSinceCrash,

                alpha:
                    alpha,

                intervals:
                    intervals
            )

        // ----------------------------------------------------
        // Volume pressure
        // ----------------------------------------------------

        let volume: Double

        if currentVolumePoints.count >= 3 {

            volume =
                calculateCurrentVolumePressure(
                    points:
                        currentVolumePoints
                )

        } else {

            volume =
                historicalVolumePressure(
                    forYear:
                        currentYear
                )
        }

        // ----------------------------------------------------
        // IMPORTANT:
        //
        // Macro inputs now come from the historical dataset.
        // ----------------------------------------------------

        let scenario =
            historicalScenario(
                for:
                    currentYear
            )

        // ----------------------------------------------------
        // One generation = analyzed year.
        // ----------------------------------------------------

        runYear(
            year:
                currentYear,

            equilibriumPressure:
                equilibrium,

            volumePressure:
                volume,

            scenario:
                scenario
        )

        // ----------------------------------------------------
        // Result
        // ----------------------------------------------------

        return MarketRiskResult(

            year:
                currentYear,

            equilibriumPressure:
                equilibrium,

            volumePressure:
                volume,

            averageEnergy:
                averageEnergy(),

            averageMomentum:
                averageMomentum(),

            averageFinancialPotential:
                averageFinancialPotential(),

            averageLiquidity:
                averageLiquidity(),

            averageCapital:
                averageCapital(),

            exhaustion:
                averageExhaustion(),

            cellularStress:
                cellularStress(),

            criticalCellFraction:
                criticalCellFraction(),

            crashCellFraction:
                crashCellFraction(),

            systemicRisk:
                systemicRisk(),

            riskLevel:
                riskLevel()
        )
    }

    // ========================================================
    // MARK: - Historical Crash Analysis
    // ========================================================

    func analyzeHistoricalCrash(
        at crashIndex: Int
    ) -> MarketRiskResult? {

        guard crashIndex >= 0,
              crashIndex < crashRecords.count
        else {
            return nil
        }

        resetCells()

        let record =
            crashRecords[crashIndex]

        // ----------------------------------------------------
        // First crash has no prior crash interval.
        // ----------------------------------------------------

        guard crashIndex > 0 else {

            return analyze(
                currentYear:
                    record.year
            )
        }

        let previousRecord =
            crashRecords[
                crashIndex - 1
            ]

        let intervalYears =
            max(
                record.year -
                previousRecord.year,
                1
            )

        let alpha =
            estimateCyclePressureExponent(
                upThroughCrashIndex:
                    crashIndex
            )

        let intervals =
            crashIntervals(
                upThroughCrashIndex:
                    crashIndex
            )

        // ----------------------------------------------------
        // Simulate each year separately.
        //
        // Each year gets:
        //
        // 1. Its own cycle pressure.
        // 2. Its own historical macro scenario.
        // 3. Volume information available at that year.
        //
        // No terminal crash information is retroactively
        // applied to every preceding year.
        // ----------------------------------------------------

        for offset in 1...intervalYears {

            let year =
                previousRecord.year +
                offset

            let yearsSinceCrash =
                max(
                    year -
                    previousRecord.year,
                    0
                )

            let equilibrium =
                powerLawPressure(
                    yearsSinceCrash:
                        yearsSinceCrash,

                    alpha:
                        alpha,

                    intervals:
                        intervals
                )

            let volume =
                historicalVolumePressure(
                    forYear:
                        year
                )

            let scenario =
                historicalScenario(
                    for:
                        year
                )

            runYear(
                year:
                    year,

                equilibriumPressure:
                    equilibrium,

                volumePressure:
                    volume,

                scenario:
                    scenario
            )
        }

        // ----------------------------------------------------
        // Terminal pressure
        // ----------------------------------------------------

        let terminalEquilibrium =
            powerLawPressure(
                yearsSinceCrash:
                    intervalYears,

                alpha:
                    alpha,

                intervals:
                    intervals
            )

        let terminalVolume =
            historicalVolumePressure(
                forYear:
                    record.year
            )

        return MarketRiskResult(

            year:
                record.year,

            equilibriumPressure:
                terminalEquilibrium,

            volumePressure:
                terminalVolume,

            averageEnergy:
                averageEnergy(),

            averageMomentum:
                averageMomentum(),

            averageFinancialPotential:
                averageFinancialPotential(),

            averageLiquidity:
                averageLiquidity(),

            averageCapital:
                averageCapital(),

            exhaustion:
                averageExhaustion(),

            cellularStress:
                cellularStress(),

            criticalCellFraction:
                criticalCellFraction(),

            crashCellFraction:
                crashCellFraction(),

            systemicRisk:
                systemicRisk(),

            riskLevel:
                riskLevel()
        )
    }

    // ========================================================
    // MARK: - Explicit Scenario Analysis
    // ========================================================

    /// Allows the UI or a controlled experiment to run the CA
    /// using explicitly supplied macroeconomic values.
    func analyze(
        currentYear: Int,
        volumePressure: Double,
        scenario: MarketScenario
    ) -> MarketRiskResult {

        resetCells()

        let historicalIndex =
            historicalCrashIndex(
                for:
                    currentYear
            )

        let anchorYear =
            historicalIndex.map {
                crashRecords[$0].year
            }
            ??
            currentYear

        let yearsSinceCrash =
            max(
                currentYear -
                anchorYear,
                0
            )

        let alpha: Double

        let intervals: [Double]

        if let index =
            historicalIndex {

            alpha =
                estimateCyclePressureExponent(
                    upThroughCrashIndex:
                        index
                )

            intervals =
                crashIntervals(
                    upThroughCrashIndex:
                        index
                )

        } else {

            alpha = 2.0
            intervals = []
        }

        let equilibrium =
            powerLawPressure(
                yearsSinceCrash:
                    yearsSinceCrash,

                alpha:
                    alpha,

                intervals:
                    intervals
            )

        runYear(
            year:
                currentYear,

            equilibriumPressure:
                equilibrium,

            volumePressure:
                volumePressure,

            scenario:
                scenario
        )

        return MarketRiskResult(

            year:
                currentYear,

            equilibriumPressure:
                equilibrium,

            volumePressure:
                bounded(
                    volumePressure
                ),

            averageEnergy:
                averageEnergy(),

            averageMomentum:
                averageMomentum(),

            averageFinancialPotential:
                averageFinancialPotential(),

            averageLiquidity:
                averageLiquidity(),

            averageCapital:
                averageCapital(),

            exhaustion:
                averageExhaustion(),

            cellularStress:
                cellularStress(),

            criticalCellFraction:
                criticalCellFraction(),

            crashCellFraction:
                crashCellFraction(),

            systemicRisk:
                systemicRisk(),

            riskLevel:
                riskLevel()
        )
    }

    // ========================================================
    // MARK: - Validation
    // ========================================================

    func validateCellState() -> Bool {

        for cell in cells {

            guard cell.momentum.isFinite,
                  cell.momentum >= -1.0,
                  cell.momentum <= 1.0
            else {
                return false
            }

            let unsignedValues = [

                cell.energy,
                cell.liquidity,
                cell.capital,
                cell.exhaustion,
                cell.stress,
                cell.financialPotential,
                cell.contagion,
                cell.dissipation
            ]

            for value in unsignedValues {

                guard value.isFinite,
                      value >= 0.0,
                      value <= 1.0
                else {
                    return false
                }
            }

            // State must agree with the stress thresholds unless
            // the cell is crashed because of severe energy
            // depletion.
            if cell.state != .crashed {

                let expected =
                    stateForStress(
                        cell.stress
                    )

                guard cell.state == expected else {
                    return false
                }
            }
        }

        return true
    }

    // ========================================================
    // MARK: - Historical Causality Validation
    // ========================================================

    func validateHistoricalCausality(
        year: Int
    ) -> Bool {

        guard let selectedIndex =
                historicalCrashIndex(
                    for:
                        year
                )
        else {

            // No crash before this year.
            return crashRecords.allSatisfy {
                $0.year > year
            }
        }

        guard selectedIndex >= 0,
              selectedIndex < crashRecords.count
        else {
            return false
        }

        // The selected record must be the latest crash that
        // actually occurred by this year.
        let expectedIndex =
            crashRecords.indices.last(
                where: {
                    crashRecords[$0].year <= year
                }
            )

        return selectedIndex ==
            expectedIndex
    }

    // ========================================================
    // MARK: - Historical Scenario Validation
    // ========================================================

    /// Confirms that the scenario selected for a year does not
    /// come from a future historical observation.
    func validateHistoricalScenarioCausality(
        year: Int
    ) -> Bool {

        guard let selected =
            historicalYears.last(
                where: {
                    $0.year <= year
                }
            )
        else {
            return historicalYears.allSatisfy {
                $0.year > year
            }
        }

        return selected.year <= year
    }

    // ========================================================
    // MARK: - Full Model Validation
    // ========================================================

    func validateModel() -> Bool {

        guard gridWidth > 0,
              gridHeight > 0
        else {
            return false
        }

        guard !cells.isEmpty else {
            return false
        }

        guard validateCellState() else {
            return false
        }

        guard validateHistoricalCausality(
            year:
                crashRecords.last?.year ?? 0
        )
        else {
            return false
        }

        return true
    }
}
