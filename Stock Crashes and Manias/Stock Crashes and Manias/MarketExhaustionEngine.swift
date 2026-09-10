//
//  File.swift
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

    private let risingThreshold = 0.20
    private let stressedThreshold = 0.40
    private let criticalThreshold = 0.65
    private let releaseThreshold = 0.85

    private let energyReleaseThreshold = 0.08

    private let inflationWeight = 0.35
    private let taxationWeight = 0.15
    private let stockSlowdownWeight = 0.50

    private let contagionAmplifier = 0.75
    private let intervalAmplifier = 0.15

    init(gridWidth: Int = 20, gridHeight: Int = 12) {

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

    private func clamp(
        _ value: Double,
        _ lower: Double = 0,
        _ upper: Double = 1
    ) -> Double {

        min(upper, max(lower, value))
    }

    // --------------------------------------------------------
    // MARK: Reset
    // --------------------------------------------------------

    func reset() {

        cells = []

        let count = gridWidth * gridHeight

        for index in 0..<count {

            let x = Double(index % gridWidth) /
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

    private func neighborIndices(for index: Int) -> [Int] {

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

                guard nx >= 0,
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

        if energy <= energyReleaseThreshold ||
            stress >= releaseThreshold {

            return .crash
        }

        if stress < risingThreshold {
            return .stable
        }

        if stress < stressedThreshold {
            return .rising
        }

        if stress < criticalThreshold {
            return .stressed
        }

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

        // ========================================================
        // 1. EXHAUSTION CHANNELS
        // ========================================================

        let inflationExhaustion = normalize(
            inflationPressure * (1.0 + 0.60 * moneyPressure),
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


        // ========================================================
        // 2. INTERNAL EXHAUSTION
        // ========================================================

        let internalExhaustion = clamp(
            0.35 * inflationExhaustion +
            0.15 * taxationExhaustion +
            0.50 * stockGrowthExhaustion,
            0.0,
            1.0
        )


        // ========================================================
        // 3. INTERVAL PRESSURE
        // ========================================================
        //
        // Crash interval remains deliberately weak.
        //

        let intervalExhaustion = clamp(
            0.15 * cyclePressure,
            0.0,
            0.15
        )


        // ========================================================
        // 4. SYSTEMIC AMPLIFICATION
        // ========================================================

        let systemicAmplification =
            1.0 +
            0.75 * clamp(contagion, 0.0, 1.0) +
            intervalExhaustion


        // ========================================================
        // 5. MARKET FUEL
        // ========================================================
        //
        // Money growth provides the primary fuel.
        // Economic growth determines how effectively that fuel
        // can become productive momentum.
        //

        let fuel = clamp(
            moneyPressure *
            (0.50 + 0.50 * economicGrowthPressure),
            0.0,
            1.0
        )


        // ========================================================
        // 6. MOMENTUM DRIVE
        // ========================================================
        //
        // Momentum is driven by:
        //
        //   35% monetary fuel
        //   25% stock growth
        //   15% economic growth
        //
        // This prevents momentum from being generated solely
        // from the exhaustion mechanism.
        //

        let momentumDrive = clamp(
            0.35 * fuel +
            0.25 * stockGrowthPressure +
            0.15 * economicGrowthPressure,
            0.0,
            1.0
        )


        // ========================================================
        // 7. EQUILIBRIUM PRESSURE
        // ========================================================

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


        // ========================================================
        // 8. EQUILIBRIUM INFLECTION
        // ========================================================
        //
        // Positive value means equilibrium pressure is beginning
        // to overcome the forces increasing momentum.
        //

        let equilibriumInflection = normalize(
            equilibriumPressure - momentumDrive,
            lowerBound: 0.0,
            upperBound: 1.0
        )


        // ========================================================
        // 9. BASE EXHAUSTION
        // ========================================================

        let baseExhaustion = clamp(
            internalExhaustion +
            0.20 * contagion +
            0.10 * equilibriumInflection,
            0.0,
            1.0
        )


        // ========================================================
        // 10. TOTAL EXHAUSTION
        // ========================================================

        let totalExhaustion = clamp(
            (
                baseExhaustion * systemicAmplification
            ) +
            0.10 * bondPressure +
            0.10 * volumePressure +
            0.10 * shockPressure,
            0.0,
            1.0
        )


        // ========================================================
        // 11. USEFUL FUEL
        // ========================================================
        //
        // Fuel becomes less useful as the cell becomes exhausted.
        //

        let usefulFuel = clamp(
            fuel *
            current.energy *
            (1.0 - totalExhaustion),
            0.0,
            1.0
        )


        // ========================================================
        // 12. MOMENTUM UPDATE
        // ========================================================
        //
        // Before equilibrium:
        //     momentum can grow.
        //
        // At equilibrium:
        //     growth begins to turn.
        //
        // After equilibrium:
        //     exhaustion reduces momentum.
        //

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


        // ========================================================
        // 13. ENERGY UPDATE
        // ========================================================
        //
        // Energy is stored market potential.
        //
        // Useful economic activity replenishes it.
        // Exhaustion consumes it.
        //

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


        // ========================================================
        // 14. STRESS
        // ========================================================

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


        // ========================================================
        // 15. MARKET STATE
        // ========================================================

        let nextState: MarketCellState

        if nextEnergy <= energyReleaseThreshold &&
            nextStress >= releaseThreshold {

            nextState = .crash

        } else if nextStress >= criticalThreshold {

            nextState = .critical

        } else if nextStress >= stressedThreshold {

            nextState = .stressed

        } else if nextMomentum > current.momentum {

            nextState = .rising

        } else {

            nextState = .stable
        }


        // ========================================================
        // 16. RETURN CELL
        // ========================================================

        return MarketCell(
            id: current.id,
            energy: nextEnergy,
            momentum: nextMomentum,
            momentumChange: nextMomentum - current.momentum,
            equilibrium: equilibriumPressure,
            equilibriumInflection: equilibriumInflection,
            inflationExhaustion: inflationExhaustion,
            taxationExhaustion: taxationExhaustion,
            stockGrowthExhaustion: stockGrowthExhaustion,
            contagionExhaustion: contagion,
            intervalExhaustion: intervalExhaustion,
            internalExhaustion: internalExhaustion,
            exhaustion: totalExhaustion,
            stress: nextStress,
            state: nextState
        )

    }
    private func neighborIndices(of index: Int) -> [Int] {
        // Your cellular automaton is a 20 × 12 grid.
        let gridWidth = 20
        let gridHeight = 12

        let x = index % gridWidth
        let y = index / gridWidth

        var indices: [Int] = []

        for dy in -1...1 {
            for dx in -1...1 {
                if dx == 0 && dy == 0 {
                    continue
                }

                let nx = x + dx
                let ny = y + dy

                guard nx >= 0,
                      nx < gridWidth,
                      ny >= 0,
                      ny < gridHeight else {
                    continue
                }

                indices.append(ny * gridWidth + nx)
            }
        }

        return indices
    }
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

            // Snapshot of the current generation.
            // Every cell must calculate its next state from the
            // same previous generation.
            let currentCells = cells

            var nextCells = currentCells

            for index in currentCells.indices {

                // ------------------------------------------------
                // Neighbor topology
                // ------------------------------------------------

                let neighborIndices = self.neighborIndices(for: index)

                // ------------------------------------------------
                // Neighbor exhaustion
                // ------------------------------------------------

                let neighborExhaustion: Double

                if neighborIndices.isEmpty {
                    neighborExhaustion = 0.0
                } else {
                    neighborExhaustion =
                        neighborIndices.reduce(0.0) { total, neighborIndex in
                            total + currentCells[neighborIndex].exhaustion
                        }
                        / Double(neighborIndices.count)
                }

                // ------------------------------------------------
                // Neighbor stress
                // ------------------------------------------------

                let neighborStress: Double

                if neighborIndices.isEmpty {
                    neighborStress = 0.0
                } else {
                    neighborStress =
                        neighborIndices.reduce(0.0) { total, neighborIndex in
                            total + currentCells[neighborIndex].stress
                        }
                        / Double(neighborIndices.count)
                }

                // ------------------------------------------------
                // Contagion
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
                    contagion: contagion,
                    moneyPressure: moneyPressure,
                    inflationPressure: inflationPressure,
                    taxationPressure: taxationPressure,
                    economicGrowthPressure: economicGrowthPressure,
                    stockGrowthPressure: stockGrowthPressure,
                    stockSlowdownPressure: stockSlowdownPressure,
                    bondPressure: bondPressure,
                    volumePressure: volumePressure,
                    cyclePressure: cyclePressure,
                    shockPressure: shockPressure
                )
            }

            // Advance the entire cellular automaton simultaneously.
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

        let momentumChange =
            stockGrowthPercent -
            previousStockGrowthPercent

        let stockSlowdownPressure =
            normalize(
                -momentumChange,
                lowerBound: 0,
                upperBound: 30
            )

        let bondPressure =
            normalize(
                bondYieldAvgPercent,
                lowerBound: 0,
                upperBound: 15
            )

        let volumePressure =
            normalize(
                growthVolumePercent,
                lowerBound: -50,
                upperBound: 300
            )

        let cyclePressure =
            normalize(
                crashInterval,
                lowerBound: 0,
                upperBound: 25
            )

        let shockPressure =
            normalize(
                externalShockPercent,
                lowerBound: 0,
                upperBound: 100
            )

        run(
            generations: 20,
            moneyPressure: moneyPressure,
            inflationPressure: inflationPressure,
            taxationPressure: taxationPressure,
            economicGrowthPressure: economicGrowthPressure,
            stockGrowthPressure: stockGrowthPressure,
            stockSlowdownPressure: stockSlowdownPressure,
            bondPressure: bondPressure,
            volumePressure: volumePressure,
            cyclePressure: cyclePressure,
            shockPressure: shockPressure
        )

        let meanEnergy =
            mean(\.energy)

        let meanMomentum =
            mean(\.momentum)

        let meanExhaustion =
            mean(\.exhaustion)

        let meanStress =
            mean(\.stress)

        let criticalFraction =
            fraction(
                where: {
                    $0.state == .critical
                }
            )

        let releaseFraction =
            fraction(
                where: {
                    $0.state == .crash
                }
            )

        let usefulFuel =
            clamp(
                moneyPressure *
                meanEnergy *
                (1 - meanExhaustion)
            )

        let overdrivePressure =
            clamp(
                moneyPressure *
                inflationPressure
            )

        let equilibriumPressure =
            mean(\.equilibrium)

        let equilibriumInflection =
            mean(\.equilibriumInflection)

        let systemicRisk =
            clamp(
                0.20 * meanExhaustion +
                0.20 * meanStress +
                0.15 * criticalFraction +
                0.10 * releaseFraction +
                0.10 * (1 - meanEnergy) +
                0.10 * stockSlowdownPressure +
                0.10 * inflationPressure +
                0.05 * shockPressure
            )

        return MarketSimulationResult(
            year: year,
            moneyPressure: moneyPressure,
            inflationPressure: inflationPressure,
            taxationPressure: taxationPressure,
            economicGrowthPressure: economicGrowthPressure,
            stockGrowthPressure: stockGrowthPressure,
            stockSlowdownPressure: stockSlowdownPressure,
            bondPressure: bondPressure,
            volumePressure: volumePressure,
            cyclePressure: cyclePressure,
            shockPressure: shockPressure,
            meanEnergy: meanEnergy,
            meanMomentum: meanMomentum,
            meanExhaustion: meanExhaustion,
            meanStress: meanStress,
            criticalFraction: criticalFraction,
            releaseFraction: releaseFraction,
            usefulFuel: usefulFuel,
            overdrivePressure: overdrivePressure,
            equilibriumPressure: equilibriumPressure,
            equilibriumInflection: equilibriumInflection,
            systemicRisk: systemicRisk,
            cells: cells
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
            .map { $0[keyPath: keyPath] }
            .reduce(0, +) /
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
