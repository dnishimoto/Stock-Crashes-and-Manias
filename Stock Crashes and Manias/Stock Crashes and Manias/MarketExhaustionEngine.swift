

//
//  MarketExhaustionEngine.swift
//  Stock Crashes and Manias
//
//  Created by David Nishimoto on 9/10/26.
//

import Foundation
import SwiftUI

final class MarketExhaustionEngine {

    let gridWidth: Int
    let gridHeight: Int

    private(set) var cells: [MarketCell] = []

    // --------------------------------------------------------
    // MARK: Thresholds
    // --------------------------------------------------------

    private let risingThreshold = 0.20
    private let stressedThreshold = 0.40

    // IMPORTANT:
    // This is a STRESS threshold.
    // It is NOT an exhaustion value.
    private let criticalStressThreshold = 0.65

    // Stress at or above this level represents a release/crash
    // condition when combined with the energy condition below.
    private let releaseStressThreshold = 0.85

    // Energy below this level represents very low stored
    // market potential.
    private let energyReleaseThreshold = 0.08

    // --------------------------------------------------------
    // MARK: Model Weights
    // --------------------------------------------------------

    private let inflationWeight = 0.35
    private let taxationWeight = 0.15
    private let stockSlowdownWeight = 0.50

    private let contagionAmplifier = 0.75
    private let intervalAmplifier = 0.15

    // --------------------------------------------------------
    // MARK: Initialization
    // --------------------------------------------------------

    init(
        gridWidth: Int = 20,
        gridHeight: Int = 12
    ) {
        self.gridWidth = max(1, gridWidth)
        self.gridHeight = max(1, gridHeight)

        reset()
    }

    // --------------------------------------------------------
    // MARK: Normalize
    // --------------------------------------------------------

    private func normalize(
        _ value: Double,
        lowerBound: Double,
        upperBound: Double
    ) -> Double {

        guard value.isFinite else {
            return 0
        }

        guard upperBound > lowerBound else {
            return 0
        }

        return min(
            1,
            max(
                0,
                (value - lowerBound) /
                (upperBound - lowerBound)
            )
        )
    }

    // --------------------------------------------------------
    // MARK: Clamp
    // --------------------------------------------------------

    private func clamp(
        _ value: Double,
        _ lower: Double = 0,
        _ upper: Double = 1
    ) -> Double {

        guard value.isFinite else {
            return lower
        }

        return min(
            upper,
            max(lower, value)
        )
    }

    // --------------------------------------------------------
    // MARK: Reset
    // --------------------------------------------------------

    func reset() {

        cells = []

        let count = gridWidth * gridHeight

        for index in 0..<count {

            let x =
                Double(index % gridWidth) /
                Double(max(1, gridWidth - 1))

            let initialMomentum =
                0.20 +
                0.20 * x

            cells.append(
                MarketCell(
                    id: index,

                    energy: 0.85,

                    momentum: initialMomentum,

                    momentumChange: 0,

                    equilibrium: 0,

                    equilibriumInflection: 0,

                    inflationExhaustion: 0,

                    taxationExhaustion: 0,

                    stockGrowthExhaustion: 0,

                    contagionExhaustion: 0,

                    intervalExhaustion: 0,

                    internalExhaustion: 0,

                    // Actual exhaustion begins at zero.
                    exhaustion: 0,

                    stress: 0,

                    state: .stable
                )
            )
        }
    }

    // --------------------------------------------------------
    // MARK: Neighbor Topology
    // --------------------------------------------------------

    private func neighborIndices(
        for index: Int
    ) -> [Int] {

        let x = index % gridWidth
        let y = index / gridWidth

        var result: [Int] = []

        for dy in -1...1 {

            for dx in -1...1 {

                if dx == 0 && dy == 0 {
                    continue
                }

                let nx = x + dx
                let ny = y + dy

                guard
                    nx >= 0,
                    nx < gridWidth,
                    ny >= 0,
                    ny < gridHeight
                else {
                    continue
                }

                result.append(
                    ny * gridWidth + nx
                )
            }
        }

        return result
    }

    // --------------------------------------------------------
    // MARK: State
    // --------------------------------------------------------

    private func stateFor(
        energy: Double,
        stress: Double
    ) -> MarketCellState {

        // Crash/release condition.
        //
        // Very low energy OR very high stress represents
        // a release condition.
        if energy <= energyReleaseThreshold ||
            stress >= releaseStressThreshold {

            return .crash
        }

        // Normal/stable condition.
        if stress < risingThreshold {
            return .stable
        }

        // Market pressure is increasing.
        if stress < stressedThreshold {
            return .rising
        }

        // Market is materially stressed.
        if stress < criticalStressThreshold {
            return .stressed
        }

        // IMPORTANT:
        // 65% here refers ONLY to STRESS.
        //
        // It does NOT set exhaustion to 65%.
        return .critical
    }

    // --------------------------------------------------------
    // MARK: Cellular Automaton Step
    // --------------------------------------------------------

    private func step(
        _ current: MarketCell,
        contagion: Double,
        moneyPressure: Double,
        inflationPressure: Double,
        taxationPressure: Double,
        economicGrowthPressure: Double,
        stockGrowthPressure: Double,
        stockSlowdownPressure: Double,
        bondPressure: Double,
        volumePressure: Double,
        cyclePressure: Double,
        shockPressure: Double
    ) -> MarketCell {

        // ====================================================
        // 1. EXHAUSTION CHANNELS
        // ====================================================

        let inflationExhaustion = normalize(
            inflationPressure *
            (1.0 + 0.60 * moneyPressure),
            lowerBound: 0.0,
            upperBound: 1.60
        )

        let taxationExhaustion = clamp(
            taxationPressure,
            0.0,
            1.0
        )

        let stockGrowthExhaustion = clamp(
            stockSlowdownPressure,
            0.0,
            1.0
        )

        // ====================================================
        // 2. INTERNAL EXHAUSTION
        // ====================================================

        let internalExhaustion = clamp(
            inflationWeight * inflationExhaustion +
            taxationWeight * taxationExhaustion +
            stockSlowdownWeight * stockGrowthExhaustion,
            0.0,
            1.0
        )

        // ====================================================
        // 3. INTERVAL PRESSURE
        // ====================================================

        let intervalExhaustion = clamp(
            intervalAmplifier * cyclePressure,
            0.0,
            intervalAmplifier
        )

        // ====================================================
        // 4. SYSTEMIC AMPLIFICATION
        // ====================================================

        let systemicAmplification =
            1.0 +
            contagionAmplifier *
            clamp(contagion, 0.0, 1.0) +
            intervalExhaustion

        // ====================================================
        // 5. MARKET FUEL
        // ====================================================
        //
        // Money growth provides the primary fuel.
        //
        // Economic growth determines how effectively
        // monetary fuel becomes productive momentum.
        //
        // ====================================================

        let fuel = clamp(
            moneyPressure *
            (
                0.50 +
                0.50 * economicGrowthPressure
            ),
            0.0,
            1.0
        )

        // ====================================================
        // 6. MOMENTUM DRIVE
        // ====================================================
        //
        // Momentum is driven by:
        //
        // 35% monetary fuel
        // 25% stock growth
        // 15% economic growth
        //
        // ====================================================

        let momentumDrive = clamp(
            0.35 * fuel +
            0.25 * stockGrowthPressure +
            0.15 * economicGrowthPressure,
            0.0,
            1.0
        )

        // ====================================================
        // 7. EQUILIBRIUM PRESSURE
        // ====================================================

        let equilibriumPressure = clamp(
            0.45 * stockSlowdownPressure +
            0.20 * inflationExhaustion +
            0.15 * taxationExhaustion +
            0.10 * bondPressure +
            0.05 * volumePressure +
            0.05 * cyclePressure,
            0.0,
            1.0
        )

        // ====================================================
        // 8. EQUILIBRIUM INFLECTION
        // ====================================================
        //
        // Positive value means equilibrium pressure is
        // beginning to overcome forces increasing momentum.
        //
        // ====================================================

        let equilibriumInflection = normalize(
            equilibriumPressure - momentumDrive,
            lowerBound: 0.0,
            upperBound: 1.0
        )

        // ====================================================
        // 9. BASE EXHAUSTION
        // ====================================================

        let baseExhaustion = clamp(
            internalExhaustion +
            0.20 * contagion +
            0.10 * equilibriumInflection,
            0.0,
            1.0
        )

        // ====================================================
        // 10. TOTAL EXHAUSTION
        // ====================================================
        //
        // THIS IS THE ACTUAL EXHAUSTION VALUE.
        //
        // It is independent of the 65% critical-stress
        // threshold.
        //
        // ====================================================

        let totalExhaustion = clamp(
            (
                baseExhaustion *
                systemicAmplification
            ) +
            0.10 * bondPressure +
            0.10 * volumePressure +
            0.10 * shockPressure,
            0.0,
            1.0
        )

        // ====================================================
        // 11. USEFUL FUEL
        // ====================================================

        let usefulFuel = clamp(
            fuel *
            current.energy *
            (1.0 - totalExhaustion),
            0.0,
            1.0
        )

        // ====================================================
        // 12. MOMENTUM UPDATE
        // ====================================================

        let momentumGain =
            0.20 * momentumDrive +
            0.10 * usefulFuel

        let momentumLoss =
            0.12 * totalExhaustion +
            0.10 * equilibriumInflection

        let nextMomentum = clamp(
            current.momentum +
            momentumGain -
            momentumLoss,
            -1.0,
            1.0
        )

        // ====================================================
        // 13. ENERGY UPDATE
        // ====================================================

        let energyRecovery =
            0.10 * usefulFuel

        let energyLoss =
            0.06 * totalExhaustion

        let nextEnergy = clamp(
            current.energy +
            energyRecovery -
            energyLoss,
            0.0,
            1.0
        )

        // ====================================================
        // 14. STRESS
        // ====================================================
        //
        // Stress is intentionally separate from exhaustion.
        //
        // 65% is a stress threshold.
        //
        // ====================================================

        let nextStress = clamp(
            0.40 * totalExhaustion +
            0.20 * contagion +
            0.20 * equilibriumInflection +
            0.10 * (1.0 - nextEnergy) +
            0.05 * bondPressure +
            0.05 * shockPressure,
            0.0,
            1.0
        )

        // ====================================================
        // 15. MARKET STATE
        // ====================================================
        //
        // State is determined from energy and stress.
        //
        // It does NOT overwrite exhaustion.
        //
        // ====================================================

        let nextState = stateFor(
            energy: nextEnergy,
            stress: nextStress
        )

        // ====================================================
        // 16. RETURN CELL
        // ====================================================

        return MarketCell(
            id: current.id,

            energy: nextEnergy,

            momentum: nextMomentum,

            momentumChange:
                nextMomentum -
                current.momentum,

            equilibrium:
                equilibriumPressure,

            equilibriumInflection:
                equilibriumInflection,

            inflationExhaustion:
                inflationExhaustion,

            taxationExhaustion:
                taxationExhaustion,

            stockGrowthExhaustion:
                stockGrowthExhaustion,

            contagionExhaustion:
                contagion,

            intervalExhaustion:
                intervalExhaustion,

            internalExhaustion:
                internalExhaustion,

            // THIS is the actual exhaustion.
            exhaustion:
                totalExhaustion,

            // This is separate from exhaustion.
            stress:
                nextStress,

            state:
                nextState
        )
    }

    // --------------------------------------------------------
    // MARK: Run
    // --------------------------------------------------------

    func run(
        generations: Int = 20,
        moneyPressure: Double,
        inflationPressure: Double,
        taxationPressure: Double,
        economicGrowthPressure: Double,
        stockGrowthPressure: Double,
        stockSlowdownPressure: Double,
        bondPressure: Double,
        volumePressure: Double,
        cyclePressure: Double,
        shockPressure: Double
    ) {

        reset()

        for _ in 0..<max(1, generations) {

            // Snapshot the current generation.
            //
            // Every cell calculates its next state from
            // the same previous generation.

            let currentCells = cells
            var nextCells = currentCells

            for index in currentCells.indices {

                // ------------------------------------------------
                // Neighbor topology
                // ------------------------------------------------

                let neighborIndices =
                    self.neighborIndices(
                        for: index
                    )

                // ------------------------------------------------
                // Neighbor exhaustion
                // ------------------------------------------------

                let neighborExhaustion: Double

                if neighborIndices.isEmpty {

                    neighborExhaustion = 0.0

                } else {

                    neighborExhaustion =
                        neighborIndices.reduce(0.0) {
                            total,
                            neighborIndex in

                            total +
                            currentCells[
                                neighborIndex
                            ].exhaustion

                        } /
                        Double(neighborIndices.count)
                }

                // ------------------------------------------------
                // Neighbor stress
                // ------------------------------------------------

                let neighborStress: Double

                if neighborIndices.isEmpty {

                    neighborStress = 0.0

                } else {

                    neighborStress =
                        neighborIndices.reduce(0.0) {
                            total,
                            neighborIndex in

                            total +
                            currentCells[
                                neighborIndex
                            ].stress

                        } /
                        Double(neighborIndices.count)
                }

                // ------------------------------------------------
                // Contagion
                // ------------------------------------------------
                //
                // 65% of contagion comes from neighboring
                // exhaustion.
                //
                // 35% comes from neighboring stress.
                //
                // NOTE:
                // This 0.65 is a weighting factor.
                // It is NOT a 65% exhaustion threshold.
                //
                // ------------------------------------------------

                let contagion = clamp(
                    0.65 * neighborExhaustion +
                    0.35 * neighborStress,
                    0.0,
                    1.0
                )

                // ------------------------------------------------
                // Advance this cell
                // ------------------------------------------------

                nextCells[index] = step(
                    currentCells[index],

                    contagion:
                        contagion,

                    moneyPressure:
                        moneyPressure,

                    inflationPressure:
                        inflationPressure,

                    taxationPressure:
                        taxationPressure,

                    economicGrowthPressure:
                        economicGrowthPressure,

                    stockGrowthPressure:
                        stockGrowthPressure,

                    stockSlowdownPressure:
                        stockSlowdownPressure,

                    bondPressure:
                        bondPressure,

                    volumePressure:
                        volumePressure,

                    cyclePressure:
                        cyclePressure,

                    shockPressure:
                        shockPressure
                )
            }

            // Advance the entire cellular automaton
            // simultaneously.

            cells = nextCells
        }
    }

    // --------------------------------------------------------
    // MARK: Analyze
    // --------------------------------------------------------

    func analyze(
        year: Int,
        growthM2: Double,
        inflationPercent: Double,
        taxGrowthPercent: Double,
        economicGrowthPercent: Double,
        stockGrowthPercent: Double,
        previousStockGrowthPercent: Double,
        bondYieldAvgPercent: Double,
        growthVolumePercent: Double,
        crashInterval: Double,
        externalShockPercent: Double
    ) -> MarketSimulationResult {

        // ====================================================
        // 1. NORMALIZED INPUT PRESSURES
        // ====================================================

        let moneyPressure =
            normalize(
                growthM2,
                lowerBound: -5,
                upperBound: 20
            )

        let inflationPressure =
            normalize(
                inflationPercent,
                lowerBound: -5,
                upperBound: 15
            )

        let excessTaxGrowth =
            taxGrowthPercent -
            economicGrowthPercent

        let taxationPressure =
            normalize(
                excessTaxGrowth,
                lowerBound: -5,
                upperBound: 15
            )

        let economicGrowthPressure =
            normalize(
                economicGrowthPercent,
                lowerBound: -10,
                upperBound: 15
            )

        let stockGrowthPressure =
            normalize(
                stockGrowthPercent,
                lowerBound: -50,
                upperBound: 100
            )

        // ====================================================
        // 2. STOCK MOMENTUM CHANGE
        // ====================================================

        let momentumChange =
            stockGrowthPercent -
            previousStockGrowthPercent

        let stockSlowdownPressure =
            normalize(
                -momentumChange,
                lowerBound: 0,
                upperBound: 30
            )

        // ====================================================
        // 3. BOND PRESSURE
        // ====================================================

        let bondPressure =
            normalize(
                bondYieldAvgPercent,
                lowerBound: 0,
                upperBound: 15
            )

        // ====================================================
        // 4. VOLUME PRESSURE
        // ====================================================

        let volumePressure =
            normalize(
                growthVolumePercent,
                lowerBound: -50,
                upperBound: 300
            )

        // ====================================================
        // 5. CYCLE PRESSURE
        // ====================================================

        let cyclePressure =
            normalize(
                crashInterval,
                lowerBound: 0,
                upperBound: 25
            )

        // ====================================================
        // 6. EXTERNAL SHOCK
        // ====================================================

        let shockPressure =
            normalize(
                externalShockPercent,
                lowerBound: 0,
                upperBound: 100
            )

        // ====================================================
        // 7. RUN CELLULAR SIMULATION
        // ====================================================

        run(
            generations: 20,

            moneyPressure:
                moneyPressure,

            inflationPressure:
                inflationPressure,

            taxationPressure:
                taxationPressure,

            economicGrowthPressure:
                economicGrowthPressure,

            stockGrowthPressure:
                stockGrowthPressure,

            stockSlowdownPressure:
                stockSlowdownPressure,

            bondPressure:
                bondPressure,

            volumePressure:
                volumePressure,

            cyclePressure:
                cyclePressure,

            shockPressure:
                shockPressure
        )

        // ====================================================
        // 8. FINAL CELL STATISTICS
        // ====================================================

        let meanEnergy =
            mean(\.energy)

        let meanMomentum =
            mean(\.momentum)

        // IMPORTANT:
        //
        // This is the actual calculated mean exhaustion.
        //
        // It is NOT the 0.65 critical stress threshold.

        let meanExhaustion =
            mean(\.exhaustion)

        let meanStress =
            mean(\.stress)

        // ====================================================
        // 9. CRITICAL FRACTION
        // ====================================================
        //
        // Fraction of cells whose STATE is critical.
        //
        // A critical cell has stress >= 65%.
        //
        // This does NOT mean every critical cell has
        // exhaustion = 65%.
        //
        // ====================================================

        let criticalFraction =
            fraction(
                where: {
                    $0.state == .critical
                }
            )

        // ====================================================
        // 10. RELEASE FRACTION
        // ====================================================

        let releaseFraction =
            fraction(
                where: {
                    $0.state == .crash
                }
            )

        // ====================================================
        // 11. USEFUL FUEL
        // ====================================================

        let usefulFuel =
            clamp(
                moneyPressure *
                meanEnergy *
                (1.0 - meanExhaustion)
            )

        // ====================================================
        // 12. OVERDRIVE PRESSURE
        // ====================================================

        let overdrivePressure =
            clamp(
                moneyPressure *
                inflationPressure
            )

        // ====================================================
        // 13. EQUILIBRIUM
        // ====================================================

        let equilibriumPressure =
            mean(\.equilibrium)

        let equilibriumInflection =
            mean(\.equilibriumInflection)

        // ====================================================
        // 14. SYSTEMIC RISK
        // ====================================================
        //
        // Systemic risk is a separate composite measure.
        //
        // It uses actual exhaustion, actual stress,
        // critical-cell fraction, crash-cell fraction,
        // energy depletion, stock slowdown, inflation,
        // and external shock.
        //
        // It is NOT hardcoded to 65%.
        //
        // ====================================================

        let systemicRisk =
            clamp(
                0.20 * meanExhaustion +
                0.20 * meanStress +
                0.15 * criticalFraction +
                0.10 * releaseFraction +
                0.10 * (1.0 - meanEnergy) +
                0.10 * stockSlowdownPressure +
                0.10 * inflationPressure +
                0.05 * shockPressure
            )

        // ====================================================
        // 15. RETURN RESULT
        // ====================================================

        return MarketSimulationResult(

            year:
                year,

            moneyPressure:
                moneyPressure,

            inflationPressure:
                inflationPressure,

            taxationPressure:
                taxationPressure,

            economicGrowthPressure:
                economicGrowthPressure,

            stockGrowthPressure:
                stockGrowthPressure,

            stockSlowdownPressure:
                stockSlowdownPressure,

            bondPressure:
                bondPressure,

            volumePressure:
                volumePressure,

            cyclePressure:
                cyclePressure,

            shockPressure:
                shockPressure,

            meanEnergy:
                meanEnergy,

            meanMomentum:
                meanMomentum,

            // ACTUAL exhaustion result.
            meanExhaustion:
                meanExhaustion,

            // Separate stress result.
            meanStress:
                meanStress,

            // Percentage of cells classified critical.
            criticalFraction:
                criticalFraction,

            // Percentage of cells classified crash.
            releaseFraction:
                releaseFraction,

            usefulFuel:
                usefulFuel,

            overdrivePressure:
                overdrivePressure,

            equilibriumPressure:
                equilibriumPressure,

            equilibriumInflection:
                equilibriumInflection,

            systemicRisk:
                systemicRisk,

            cells:
                cells
        )
    }

    // --------------------------------------------------------
    // MARK: Statistics
    // --------------------------------------------------------

    private func mean(
        _ keyPath: KeyPath<MarketCell, Double>
    ) -> Double {

        guard !cells.isEmpty else {
            return 0
        }

        return cells
            .map {
                $0[keyPath: keyPath]
            }
            .reduce(0, +)
            /
            Double(cells.count)
    }

    private func fraction(
        where predicate: (MarketCell) -> Bool
    ) -> Double {

        guard !cells.isEmpty else {
            return 0
        }

        let count =
            cells.filter(predicate).count

        return Double(count) /
            Double(cells.count)
    }
}
