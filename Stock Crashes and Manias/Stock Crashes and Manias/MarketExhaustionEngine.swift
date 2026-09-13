// MARK: - Engine
import SwiftUI
import Combine

@MainActor
final class MarketExhaustionEngine: ObservableObject {

    // ------------------------------------------------------------
    // Historical records
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // Simulation
    // ------------------------------------------------------------

    private(set) var cells: [MarketCell] = []

    let gridWidth: Int
    let gridHeight: Int

    var parameters: MarketParameters

    private(set) var yearlyRiskHistory: [YearlyRiskSnapshot] = []

    // ------------------------------------------------------------
    // Random source
    // ------------------------------------------------------------

    private var random: SplitMix64

    // ------------------------------------------------------------
    // Initialization
    // ------------------------------------------------------------

    init(
        parameters: MarketParameters = MarketParameters(),
        seed: UInt64 = 42
    ) {

        self.parameters = parameters
        self.gridWidth = max(parameters.gridWidth, 1)
        self.gridHeight = max(parameters.gridHeight, 1)
        self.random = SplitMix64(seed: seed)

        resetCells()
    }

    // MARK: - Numeric Helpers

    private func bounded(
        _ value: Double,
        minimum: Double = 0.0,
        maximum: Double = 1.0
    ) -> Double {

        guard value.isFinite else {
            return minimum
        }

        return min(
            max(value, minimum),
            maximum
        )
    }

    private func safeDivide(
        _ numerator: Double,
        _ denominator: Double,
        fallback: Double = 0.0
    ) -> Double {

        guard denominator.isFinite,
              abs(denominator) > Double.leastNonzeroMagnitude,
              numerator.isFinite else {
            return fallback
        }

        return numerator / denominator
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

    // MARK: - Historical Power Law

    func estimatePowerLawAlpha() -> Double {

        guard crashRecords.count >= 2 else {
            return 2.0
        }

        return estimatePowerLawAlpha(
            upThroughCrashIndex: crashRecords.count - 1
        )
    }

    private func estimatePowerLawAlpha(
        upThroughCrashIndex crashIndex: Int
    ) -> Double {

        guard crashIndex > 0,
              crashIndex < crashRecords.count else {
            return 2.0
        }

        var intervalRatios: [Double] = []

        for index in 1...crashIndex {

            let previous = crashRecords[index - 1]
            let current = crashRecords[index]

            let interval = Double(
                max(
                    current.year - previous.year,
                    1
                )
            )

            guard interval.isFinite else {
                continue
            }

            intervalRatios.append(interval)
        }

        guard intervalRatios.count >= 2 else {
            return 2.0
        }

        let mean = intervalRatios.reduce(
            0.0,
            +
        ) / Double(intervalRatios.count)

        guard mean > 0.0 else {
            return 2.0
        }

        var variance = 0.0

        for value in intervalRatios {

            let difference = value - mean

            variance +=
                difference * difference
        }

        variance /= Double(
            max(
                intervalRatios.count - 1,
                1
            )
        )

        let standardDeviation = sqrt(
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

        // Stable bounded exponent.
        let alpha =
            1.0 +
            min(
                max(
                    coefficient,
                    0.0
                ),
                2.0
            )

        return bounded(
            alpha / 3.0,
            minimum: 0.25,
            maximum: 1.0
        )
    }

    // MARK: - Crash Intervals

    private func crashIntervals() -> [Double] {

        guard crashRecords.count >= 2 else {
            return []
        }

        return crashIntervals(
            upThroughCrashIndex: crashRecords.count - 1
        )
    }

    private func crashIntervals(
        upThroughCrashIndex crashIndex: Int
    ) -> [Double] {

        guard crashIndex > 0 else {
            return []
        }

        var result: [Double] = []

        for index in 1...crashIndex {

            let previous = crashRecords[index - 1]
            let current = crashRecords[index]

            let interval = Double(
                max(
                    current.year - previous.year,
                    1
                )
            )

            result.append(interval)
        }

        return result
    }

    // MARK: - Power Law Pressure

    func powerLawPressure(
        yearsSinceCrash: Int
    ) -> Double {

        let intervals = crashIntervals()
        let alpha = estimatePowerLawAlpha()

        return powerLawPressure(
            yearsSinceCrash: yearsSinceCrash,
            alpha: alpha,
            intervals: intervals
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
                $0.isFinite && $0 > 0.0
            }

        guard !positiveIntervals.isEmpty else {
            return 0.0
        }

        let meanInterval =
            positiveIntervals.reduce(
                0.0,
                +
            ) / Double(
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
            max(
                min(
                    alpha,
                    4.0
                ),
                0.05
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

    // MARK: - Volume Pressure

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
            recent: recent.volumeMillions,
            previous: previous.volumeMillions,
            older: older.volumeMillions
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

        let recent = sorted[
            sorted.count - 1
        ].volumeMillions

        let previous = sorted[
            sorted.count - 2
        ].volumeMillions

        let older = sorted[
            sorted.count - 3
        ].volumeMillions

        return volumePressure(
            recent: recent,
            previous: previous,
            older: older
        )
    }

    private func historicalVolumePressure(
        crashIndex: Int
    ) -> Double {

        guard crashIndex >= 2,
              crashIndex < crashRecords.count else {
            return 0.0
        }

        let recent =
            crashRecords[crashIndex]

        let previous =
            crashRecords[crashIndex - 1]

        let older =
            crashRecords[crashIndex - 2]

        return volumePressure(
            recent: recent.volumeMillions,
            previous: previous.volumeMillions,
            older: older.volumeMillions
        )
    }

    private func volumePressure(
        recent: Double,
        previous: Double,
        older: Double
    ) -> Double {

        guard recent.isFinite,
              previous.isFinite,
              older.isFinite else {
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
            recentGrowth - previousGrowth

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

    // MARK: - Cellular Automaton Reset

    func resetCells() {

        cells.removeAll(
            keepingCapacity: true
        )

        let count =
            gridWidth *
            gridHeight

        guard count > 0 else {
            return
        }

        cells.reserveCapacity(count)

        for _ in 0..<count {

            let energyVariation =
                (random.nextUnit() - 0.5) *
                0.10

            let initialEnergy =
                bounded(
                    parameters.initialEnergy +
                    energyVariation
                )

            cells.append(
                MarketCell(
                    energy: initialEnergy,
                    momentum: 0.0,
                    liquidity:
                        bounded(
                            parameters.initialLiquidity
                        ),
                    capital:
                        bounded(
                            parameters.initialCapital
                        ),
                    exhaustion: 0.0,
                    stress: 0.0,
                    financialPotential: 0.0,
                    contagion: 0.0,
                    dissipation: 0.0,
                    state: .stable
                )
            )
        }

        yearlyRiskHistory.removeAll()
    }

    // MARK: - Neighbor Indices

    private func neighborIndices(
        for index: Int
    ) -> [Int] {

        guard index >= 0,
              index < cells.count else {
            return []
        }

        let x =
            index % gridWidth

        let y =
            index / gridWidth

        var neighbors: [Int] = []

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

        for (dx, dy) in directions {

            let nx = x + dx
            let ny = y + dy

            guard nx >= 0,
                  nx < gridWidth,
                  ny >= 0,
                  ny < gridHeight else {
                continue
            }

            neighbors.append(
                ny * gridWidth + nx
            )
        }

        return neighbors
    }

    // MARK: - Average Neighbor Stress

    private func averageNeighborStress(
        index: Int,
        snapshot: [MarketCell]
    ) -> Double {

        let neighbors =
            neighborIndices(
                for: index
            )

        guard !neighbors.isEmpty else {
            return 0.0
        }

        var total = 0.0
        var count = 0

        for neighborIndex in neighbors {

            guard neighborIndex >= 0,
                  neighborIndex < snapshot.count else {
                continue
            }

            let value =
                snapshot[neighborIndex].stress

            guard value.isFinite else {
                continue
            }

            total += value
            count += 1
        }

        guard count > 0 else {
            return 0.0
        }

        return bounded(
            total / Double(count)
        )
    }

    // MARK: - Cellular Automaton Step

    /// Renamed from "step" to avoid conflict with simd module.
    ///
    /// Advances the cellular automaton by exactly one generation.
    ///
    /// All cells read exclusively from `previousCells`.
    /// No cell can observe another cell's partially updated state.
    ///
    /// Macro inputs are normalized before entering the CA so that:
    /// - money supply affects financial energy and momentum
    /// - inflation creates resource pressure
    /// - taxation removes available capital/liquidity
    /// - economic growth supplies productive energy
    /// - stock growth supplies momentum
    /// - stock-growth slowdown creates stress
    /// - bond yields create financing pressure
    /// - banking stress depletes financial resources
    /// - monetary policy affects expansion/contraction
    /// - trading volume supplies market disturbance
    /// - crash-cycle equilibrium supplies systemic pressure
    /// - external shocks disturb energy and stress
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
        guard !cells.isEmpty else {
            return
        }

        // ------------------------------------------------------------
        // IMPORTANT:
        //
        // Every cell reads from exactly the same previous generation.
        // This guarantees synchronous CA behavior.
        // ------------------------------------------------------------

        let previousCells = cells

        // ------------------------------------------------------------
        // 1. NORMALIZE SYSTEM-LEVEL PRESSURES
        // ------------------------------------------------------------

        let normalizedEquilibrium =
            bounded(equilibriumPressure)

        let normalizedVolume =
            bounded(volumePressure)

        // ------------------------------------------------------------
        // Money supply
        //
        // ±20% is treated as the strong model range.
        //
        // +5%  -> +0.25
        // -5%  -> -0.25
        // ------------------------------------------------------------

        let moneySupplyForcing =
            bounded(
                moneySupplyChangePercent / 20.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // ------------------------------------------------------------
        // Inflation
        //
        // 10% represents a strong inflationary condition.
        // ------------------------------------------------------------

        let inflationForcing =
            bounded(
                inflationPercent / 10.0
            )

        // ------------------------------------------------------------
        // Taxation
        //
        // 50% is treated as the strong model range.
        // ------------------------------------------------------------

        let taxationForcing =
            bounded(
                taxationPercent / 50.0
            )

        // ------------------------------------------------------------
        // Economic growth
        //
        // ±10% represents strong expansion/contraction.
        // ------------------------------------------------------------

        let growthForcing =
            bounded(
                economicGrowthPercent / 10.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // ------------------------------------------------------------
        // Stock growth
        //
        // ±50% represents strong market movement.
        // ------------------------------------------------------------

        let stockGrowthForcing =
            bounded(
                stockGrowthPercent / 50.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // ------------------------------------------------------------
        // Stock-growth slowdown
        //
        // A declining growth rate is itself a stress signal.
        // ------------------------------------------------------------

        let stockGrowthChange =
            stockGrowthPercent -
            previousStockGrowthPercent

        let stockGrowthSlowdown =
            bounded(
                -stockGrowthChange / 20.0,
                minimum: -1.0,
                maximum: 1.0
            )

        // ------------------------------------------------------------
        // Bond yield pressure
        //
        // 10% is treated as a strong financing-pressure condition.
        // ------------------------------------------------------------

        let bondYieldPressure =
            bounded(
                bondYieldAvgPercent / 10.0
            )

        // ------------------------------------------------------------
        // Banking / credit stress
        //
        // Expected UI range: 0...5.
        // ------------------------------------------------------------

        let bankingStress =
            bounded(
                bankingCreditStressRating / 5.0
            )

        // ------------------------------------------------------------
        // Monetary policy
        //
        // Positive = expansionary
        // Negative = contractionary
        //
        // Expected model range approximately -1...+1.
        // ------------------------------------------------------------

        let policyForcing =
            bounded(
                moneyPolicyChangeImpact,
                minimum: -1.0,
                maximum: 1.0
            )

        // ------------------------------------------------------------
        // External shock
        //
        // 20% is treated as a very strong disturbance.
        // Magnitude is used because a shock is destabilizing regardless
        // of whether its raw sign is positive or negative.
        // ------------------------------------------------------------

        let externalShock =
            bounded(
                abs(externalShockPercent) / 20.0
            )

        // ------------------------------------------------------------
        // 2. BASE MARKET FORCING
        // ------------------------------------------------------------

        let externalForcing =
            bounded(
                parameters.equilibriumWeight *
                    normalizedEquilibrium
                +
                parameters.volumeWeight *
                    normalizedVolume
            )

        // ------------------------------------------------------------
        // 3. MACROECONOMIC ENERGY FORCING
        //
        // Expansion:
        //   money supply
        //   economic growth
        //   stock growth
        //   monetary policy
        //
        // Contraction:
        //   monetary tightening
        //   inflation
        //   taxation
        //   bond yields
        //   banking stress
        //   external shock
        // ------------------------------------------------------------

        let expansionaryEnergy =
            max(moneySupplyForcing, 0.0) * 0.30
            +
            max(growthForcing, 0.0) * 0.20
            +
            max(stockGrowthForcing, 0.0) * 0.10
            +
            max(policyForcing, 0.0) * 0.10

        let contractionaryEnergy =
            max(-moneySupplyForcing, 0.0) * 0.25
            +
            inflationForcing * 0.10
            +
            taxationForcing * 0.10
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

        // ------------------------------------------------------------
        // 4. MACROECONOMIC MOMENTUM
        //
        // Money supply and growth create directional momentum.
        // Slowdown, yields, banking stress and shocks oppose it.
        // ------------------------------------------------------------

        let expansionaryMomentum =
            moneySupplyForcing * 0.35
            +
            growthForcing * 0.20
            +
            stockGrowthForcing * 0.20
            +
            policyForcing * 0.10

        let contractionaryMomentum =
            stockGrowthSlowdown * 0.20
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

        // ------------------------------------------------------------
        // 5. MACROECONOMIC STRESS
        // ------------------------------------------------------------

        let macroStressForcing =
            bounded(
                inflationForcing * 0.15
                +
                taxationForcing * 0.10
                +
                bondYieldPressure * 0.15
                +
                bankingStress * 0.20
                +
                stockGrowthSlowdown * 0.15
                +
                externalShock * 0.20
                +
                max(-growthForcing, 0.0) * 0.10
            )

        // ------------------------------------------------------------
        // 6. SYNCHRONOUS CELL UPDATE
        // ------------------------------------------------------------

        for index in previousCells.indices {

            let previous =
                previousCells[index]

            // --------------------------------------------------------
            // Neighbor field
            // --------------------------------------------------------

            let neighbors =
                neighborIndices(for: index)

            let neighborCount =
                max(neighbors.count, 1)

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
                    previousCells[neighborIndex]

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

            // --------------------------------------------------------
            // 7. ENERGY TRANSFER BETWEEN NEIGHBORS
            //
            // Energy flows toward a cell when neighboring cells contain
            // greater available financial energy.
            // --------------------------------------------------------

            let energyGradient =
                neighborEnergy -
                previous.energy

            let energyTransfer =
                energyGradient *
                parameters.energyTransferRate

            // --------------------------------------------------------
            // 8. MONEY-SUPPLY ENERGY
            //
            // This is the explicit money-supply -> CA pathway.
            // --------------------------------------------------------

            let monetaryEnergy =
                moneySupplyForcing *
                parameters.moneySupplyEnergyWeight

            // --------------------------------------------------------
            // 9. ECONOMIC GROWTH ENERGY
            // --------------------------------------------------------

            let growthEnergy =
                growthForcing *
                parameters.economicGrowthEnergyWeight

            // --------------------------------------------------------
            // 10. EXTERNAL SHOCK ENERGY
            // --------------------------------------------------------

            let disturbanceEnergy =
                externalShock *
                parameters.externalShockEnergyWeight

            // --------------------------------------------------------
            // 11. BASE ENERGY INJECTION
            // --------------------------------------------------------

            let baseInjectedEnergy =
                externalForcing *
                parameters.energyInjectionRate

            let macroInjectedEnergy =
                macroEnergyForcing *
                parameters.macroEnergyInjectionRate

            // --------------------------------------------------------
            // 12. RETAINED ENERGY
            // --------------------------------------------------------

            let retainedEnergy =
                previous.energy *
                parameters.energyRetention

            // --------------------------------------------------------
            // 13. PRELIMINARY ENERGY
            // --------------------------------------------------------

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

            // --------------------------------------------------------
            // 14. ENERGY CHANGE
            // --------------------------------------------------------

            let directionalChange =
                preliminaryEnergy -
                previous.energy

            // --------------------------------------------------------
            // 15. PRELIMINARY MOMENTUM
            // --------------------------------------------------------

            let preliminaryMomentum =
                previous.momentum *
                    parameters.momentumRetention
                +
                directionalChange *
                    parameters.momentumResponse
                +
                macroMomentumForcing *
                    parameters.macroMomentumResponse

            // --------------------------------------------------------
            // 16. FINANCIAL POTENTIAL
            // --------------------------------------------------------

            let energyPotential =
                bounded(preliminaryEnergy) *
                parameters.potentialEnergyWeight

            let momentumPotential =
                abs(preliminaryMomentum) *
                parameters.potentialMomentumWeight

            let rawPotential =
                (
                    energyPotential +
                    momentumPotential
                ) *
                parameters.potentialGain

            let localPotential =
                bounded(rawPotential)

            // --------------------------------------------------------
            // 17. FINANCIAL-POTENTIAL GRADIENT
            // --------------------------------------------------------

            let potentialGradient =
                neighborPotential -
                localPotential

            let potentialMomentum =
                potentialGradient *
                parameters.potentialGradientResponse

            // --------------------------------------------------------
            // 18. NEIGHBOR MOMENTUM PROPAGATION
            // --------------------------------------------------------

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

            // --------------------------------------------------------
            // 19. LIQUIDITY DEPLETION
            // --------------------------------------------------------

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
                taxationForcing *
                    parameters.taxLiquidityRate

            let newLiquidity =
                bounded(
                    previous.liquidity -
                    liquidityPressure
                )

            // --------------------------------------------------------
            // 20. CAPITAL DEPLETION
            // --------------------------------------------------------

            let capitalPressure =
                localPotential *
                    parameters.capitalDepletionRate
                +
                taxationForcing *
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

            // --------------------------------------------------------
            // 21. RESOURCE DEPLETION
            // --------------------------------------------------------

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

            // --------------------------------------------------------
            // 22. DIRECT ENERGY DEPLETION
            // --------------------------------------------------------

            let energyDepletion =
                bounded(
                    1.0 -
                    bounded(preliminaryEnergy)
                )

            // --------------------------------------------------------
            // 23. EXHAUSTION
            // --------------------------------------------------------

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

            // --------------------------------------------------------
            // 24. CONTAGION
            // --------------------------------------------------------

            let stressGradient =
                neighborStress -
                previous.stress

            let contagionInput =
                max(stressGradient, 0.0)
                +
                neighborStress * 0.50

            let newContagion =
                bounded(
                    contagionInput *
                    parameters.contagionRate
                )

            // --------------------------------------------------------
            // 25. DISSIPATION
            // --------------------------------------------------------

            let rawDissipation =
                previous.stress *
                parameters.dissipationRate

            let newDissipation =
                bounded(
                    rawDissipation
                )

            // --------------------------------------------------------
            // 26. DISSIPATION REMOVES ENERGY
            // --------------------------------------------------------

            let dissipatedEnergy =
                newDissipation *
                parameters.energyDissipationWeight

            let finalEnergy =
                bounded(
                    preliminaryEnergy -
                    dissipatedEnergy
                )

            // --------------------------------------------------------
            // 27. FINAL ENERGY DEPLETION
            // --------------------------------------------------------

            let finalEnergyDepletion =
                bounded(
                    1.0 -
                    finalEnergy
                )

            // --------------------------------------------------------
            // 28. STRESS
            //
            // High available energy is not inherently stress.
            // Depletion is what creates energy-related stress.
            // --------------------------------------------------------

            let stressFromEnergy =
                finalEnergyDepletion *
                parameters.energyDepletionStressWeight

            let stressFromMomentum =
                abs(newMomentum) *
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

            // --------------------------------------------------------
            // 29. STOCHASTIC PERTURBATION
            // --------------------------------------------------------

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

            // --------------------------------------------------------
            // 30. STATE TRANSITION
            //
            // A cell can enter crashed state through either:
            //
            // A. critical systemic stress
            // B. severe remaining-energy depletion
            // --------------------------------------------------------

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

            // --------------------------------------------------------
            // 31. SYNCHRONOUS COMMIT
            // --------------------------------------------------------

            cells[index].energy =
                finalEnergy

            // Momentum is directional persistence and must keep its
            // sign; only its magnitude (used above for stress) is
            // unsigned. Bound to [-1, 1] rather than clamping to
            // [0, 1] via abs(), which would erase direction.
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
    // MARK: - State Classification

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

    // MARK: - Run

    func run(
        years: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) {

        guard years > 0 else {
            return
        }

        // TODO: Replace these 0.0 placeholders with real scenario values.
        for _ in 0..<years {

            stepCA(
                equilibriumPressure: equilibriumPressure,
                volumePressure: volumePressure,
                moneySupplyChangePercent: 0.0,         // TODO: provide scenario value
                inflationPercent: 0.0,                 // TODO: provide scenario value
                taxationPercent: 0.0,                  // TODO: provide scenario value
                economicGrowthPercent: 0.0,            // TODO: provide scenario value
                stockGrowthPercent: 0.0,               // TODO: provide scenario value
                previousStockGrowthPercent: 0.0,       // TODO: provide scenario value
                bondYieldAvgPercent: 0.0,              // TODO: provide scenario value
                bankingCreditStressRating: 0.0,        // TODO: provide scenario value
                moneyPolicyChangeImpact: 0.0,          // TODO: provide scenario value
                externalShockPercent: 0.0              // TODO: provide scenario value
            )
        }
    }

    // MARK: - Run One Year

    func runYear(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) {

        stepCA(
            equilibriumPressure:
                equilibriumPressure,
            volumePressure:
                volumePressure,
            moneySupplyChangePercent: 0.0,
            inflationPercent: 0.0,
            taxationPercent: 0.0,
            economicGrowthPercent: 0.0,
            stockGrowthPercent: 0.0,
            previousStockGrowthPercent: 0.0,
            bondYieldAvgPercent: 0.0,
            bankingCreditStressRating: 0.0,
            moneyPolicyChangeImpact: 0.0,
            externalShockPercent: 0.0
        )

        let snapshot =
            makeYearlyRiskSnapshot(
                year: year,
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure
            )

        yearlyRiskHistory.append(
            snapshot
        )
    }

    // MARK: - Cellular Metrics

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

        // Momentum is signed; bound to [-1, 1] instead of the
        // default [0, 1] so a negative average isn't clamped to 0.
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

    func criticalCellFraction() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let critical =
            cells.filter {
                $0.state == .critical ||
                $0.state == .crashed
            }.count

        return safeDivide(
            Double(critical),
            Double(cells.count)
        )
    }

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

    // MARK: - Systemic Risk

    func systemicRisk() -> Double {

        let stress =
            cellularStress()

        let critical =
            criticalCellFraction()

        let crashed =
            crashCellFraction()

        let exhaustion =
            averageExhaustion()

        let risk =
            0.35 * stress +
            0.25 * critical +
            0.25 * crashed +
            0.15 * exhaustion

        return bounded(risk)
    }

    func riskLevel() -> MarketState {

        let risk =
            systemicRisk()

        return stateForStress(
            risk
        )
    }

    // MARK: - Yearly Snapshot

    func makeYearlyRiskSnapshot(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) -> YearlyRiskSnapshot {

        YearlyRiskSnapshot(
            year: year,
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

    // MARK: - Historical Anchor

    private func historicalCrashIndex(
        for year: Int
    ) -> Int? {

        crashRecords.indices.last(
            where: {
                crashRecords[$0].year <= year
            }
        )
    }

    // MARK: - Corrected Analysis Pipeline

    func analyze(
        currentYear: Int,
        currentVolumePoints:
            [MarketVolumePoint] = []
    ) -> MarketRiskResult {

        resetCells()

        // --------------------------------------------------------
        // IMPORTANT HISTORICAL-CAUSALITY RULE
        //
        // Find the most recent crash that existed at the time
        // being analyzed.
        //
        // A 1937 analysis cannot use 2008 or 2022.
        // A 2008 analysis cannot use 2020 or 2022.
        // A 2025 analysis may use 2022 because 2022 is historical
        // relative to 2025.
        // --------------------------------------------------------

        let historicalIndex =
            historicalCrashIndex(
                for: currentYear
            )

        let anchorYear =
            historicalIndex.map {
                crashRecords[$0].year
            }
            ?? currentYear

        let yearsSinceCrash =
            max(
                currentYear -
                anchorYear,
                0
            )

        // --------------------------------------------------------
        // Alpha is estimated only through the historical anchor.
        // --------------------------------------------------------

        let alpha: Double

        if let index = historicalIndex {

            alpha =
                estimatePowerLawAlpha(
                    upThroughCrashIndex:
                        index
                )

        } else {

            alpha = 2.0
        }

        // --------------------------------------------------------
        // Intervals are also restricted to the historical anchor.
        // --------------------------------------------------------

        let intervals: [Double]

        if let index = historicalIndex {

            intervals =
                crashIntervals(
                    upThroughCrashIndex:
                        index
                )

        } else {

            intervals = []
        }

        // --------------------------------------------------------
        // Equilibrium pressure
        // --------------------------------------------------------

        let equilibrium =
            powerLawPressure(
                yearsSinceCrash:
                    yearsSinceCrash,
                alpha:
                    alpha,
                intervals:
                    intervals
            )

        // --------------------------------------------------------
        // Volume pressure
        //
        // Explicit current points take precedence.
        //
        // Otherwise use historical records only through the
        // selected historical anchor.
        // --------------------------------------------------------

        let volume: Double

        if currentVolumePoints.count >= 3 {

            volume =
                calculateCurrentVolumePressure(
                    points:
                        currentVolumePoints
                )

        } else if let index = historicalIndex {

            volume =
                historicalVolumePressure(
                    crashIndex:
                        index
            )

        } else {

            volume = 0.0
        }

        // --------------------------------------------------------
        // One CA generation represents the analyzed year.
        // --------------------------------------------------------

        runYear(
            year: currentYear,
            equilibriumPressure:
                equilibrium,
            volumePressure:
                volume
        )

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

    // MARK: - Historical Crash Analysis

    func analyzeHistoricalCrash(
        at crashIndex: Int
    ) -> MarketRiskResult? {

        guard crashIndex >= 0,
              crashIndex < crashRecords.count else {
            return nil
        }

        resetCells()

        let record =
            crashRecords[crashIndex]

        // --------------------------------------------------------
        // First crash has no prior crash interval.
        // --------------------------------------------------------

        guard crashIndex > 0 else {

            let result =
                analyze(
                    currentYear:
                        record.year
                )

            return result
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
            estimatePowerLawAlpha(
                upThroughCrashIndex:
                    crashIndex
            )

        let intervals =
            crashIntervals(
                upThroughCrashIndex:
                    crashIndex
            )

        let volume =
            historicalVolumePressure(
                crashIndex:
                    crashIndex
            )

        // --------------------------------------------------------
        // Simulate every year between the preceding crash and
        // the selected crash.
        //
        // This produces an actual evolving CA rather than
        // evaluating only the terminal year.
        // --------------------------------------------------------

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

            runYear(
                year:
                    year,
                equilibriumPressure:
                    equilibrium,
                volumePressure:
                    volume
            )
        }

        // --------------------------------------------------------
        // Return the terminal state for the selected historical
        // crash.
        // --------------------------------------------------------

        let terminalEquilibrium =
            powerLawPressure(
                yearsSinceCrash:
                    intervalYears,
                alpha:
                    alpha,
                intervals:
                    intervals
            )

        return MarketRiskResult(
            year:
                record.year,

            equilibriumPressure:
                terminalEquilibrium,

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

    // MARK: - Validation

    func validateCellState() -> Bool {

        for cell in cells {

            guard cell.momentum.isFinite,
                  cell.momentum >= -1.0,
                  cell.momentum <= 1.0 else {
                return false
            }

            // Momentum is signed ([-1, 1]); every other field is
            // unsigned and bounded to [0, 1].
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

                guard value.isFinite else {
                    return false
                }

                guard value >= 0.0,
                      value <= 1.0 else {
                    return false
                }
            }
        }

        return true
    }

    func validateHistoricalCausality(
        year: Int
    ) -> Bool {

        guard let index =
                historicalCrashIndex(
                    for: year
                ) else {

            return crashRecords.allSatisfy {
                $0.year > year
            }
        }

        return crashRecords[
            index
        ].year <= year
        &&
        crashRecords[
            index
        ].year <= year
        &&
        crashRecords[
            index
        ].year ==
            crashRecords.last(
                where: {
                    $0.year <= year
                }
            )?.year
    }
}

