/*
 The cellular automaton begins with the historical years leading up to a market crash. Each prior year contributes its economic conditions to the evolving market system. Positive changes in the money supply provide an energy boost to the system, while negative changes in the money supply reduce available energy. These yearly changes accumulate so that the market enters the crash period with an energy and pressure history rather than beginning from an identical condition for every crash.

 The stock trading volume of the crash year establishes the initial cellular condition. The crash-year volume is normalized and used to determine the initial amount of energy available to the cellular grid. This initial energy represents the market activity present at the beginning of the crash simulation. The other historical economic variables do not replace the crash-year volume as the initial energy condition. Instead, they act on the cellular system after initialization.

 Once the cellular grid has been initialized, historical economic pressures influence the individual cells. Money-supply conditions, inflation, taxation, economic growth, stock growth, stock-growth slowdown, bond yields, trading volume, crash interval, and external shocks contribute to the pressure acting on the market cells. Positive monetary growth can continue to add energy and momentum to the system, while adverse economic conditions can increase pressure and consume available energy.

 Each cell interacts with its surrounding neighboring cells. A cell can be influenced by the energy, momentum, stress, exhaustion, and energy depletion of its neighbors. Energy can move between neighboring cells when differences in available energy exist. This allows energy and market activity to propagate through the cellular system rather than remaining isolated within individual cells.

 Contagion occurs when neighboring cells become increasingly stressed, exhausted, or energy depleted. A cell surrounded by unstable neighbors becomes more susceptible to instability itself. Neighboring exhaustion and stress therefore increase local pressure, allowing a disturbance that begins in one region of the cellular grid to spread progressively through surrounding regions.

 As the cellular automaton evolves, available energy is dissipated by market pressure, exhaustion, and contagion. Energy depletion increases as the remaining energy of a cell falls. The loss of available energy contributes to increasing instability and makes cells more vulnerable to further exhaustion. The system therefore represents a cycle in which energy can initially increase through monetary expansion and market activity but can subsequently be consumed as pressure, contagion, and instability develop.

 Exhaustion is an emergent property of the cellular system. It is determined by the combined effects of local economic pressure, contagion from neighboring cells, energy depletion, equilibrium imbalance, and external shocks. Exhaustion is not assigned directly from a predetermined critical value. The critical value is used only to classify the stress condition of a cell and does not mean that the cell's exhaustion automatically equals that value.

 Stress is calculated separately from exhaustion. Stress reflects the combined effects of exhaustion, contagion, equilibrium imbalance, energy depletion, bond pressure, and external shocks. As stress increases, a cell progresses from a stable condition to a rising condition, then to a stressed condition, a critical condition, and finally a crash or release condition when the appropriate thresholds are reached.

 A cell can also enter the crash or release state when its remaining energy becomes extremely low, even if its stress has not independently reached the highest stress threshold. This allows the cellular automaton to recognize two different pathways to failure: increasing systemic stress and severe depletion of available energy.

 The cellular automaton advances one generation at a time. Every cell calculates its next condition from the same previous generation, ensuring that all cellular changes occur simultaneously. The new energy, momentum, exhaustion, stress, equilibrium condition, and state of each cell then become the conditions used by the following generation.

 This process is repeated across multiple generations. During each generation, monetary energy, economic pressure, energy transfer, contagion, dissipation, depletion, exhaustion, and stress interact with one another. Local disturbances can therefore expand into larger regions of instability as neighboring cells influence one another.

 After the final generation, the cellular conditions are aggregated across the entire grid. The final average exhaustion represents the system's mean exhaustion, while remaining energy, momentum, stress, critical cells, and crash or release cells provide additional measures of the market's final condition. The resulting crash behavior is therefore intended to emerge from the historical buildup, monetary energy changes, crash-year volume, local economic pressures, and repeated interactions between neighboring cells rather than from a predetermined exhaustion value.

 */


import Foundation
import SwiftUI

final class MarketExhaustionEngine {

    // ============================================================
    // MARK: - Historical CA Input
    // ============================================================

    struct HistoricalCAInput: Identifiable {

        let id: Int
        let year: Int

        let growthM2: Double
        let inflationPercent: Double
        let taxGrowthPercent: Double
        let economicGrowthPercent: Double
        let stockGrowthPercent: Double
        let previousStockGrowthPercent: Double
        let bondYieldAvgPercent: Double
        let growthVolumePercent: Double
        let crashInterval: Double
        let externalShockPercent: Double

        init(
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
        ) {
            self.id = year
            self.year = year
            self.growthM2 = growthM2
            self.inflationPercent = inflationPercent
            self.taxGrowthPercent = taxGrowthPercent
            self.economicGrowthPercent = economicGrowthPercent
            self.stockGrowthPercent = stockGrowthPercent
            self.previousStockGrowthPercent = previousStockGrowthPercent
            self.bondYieldAvgPercent = bondYieldAvgPercent
            self.growthVolumePercent = growthVolumePercent
            self.crashInterval = crashInterval
            self.externalShockPercent = externalShockPercent
        }
    }

    // ============================================================
    // MARK: - Historical CA Frame
    // ============================================================

    struct HistoricalCAFrame: Identifiable {

        let id: Int
        let year: Int
        let isCrashYear: Bool

        let moneyEnergyChange: Double
        let volumePressure: Double

        let meanEnergy: Double
        let meanMomentum: Double
        let meanExhaustion: Double
        let meanStress: Double

        let cells: [MarketCell]

        init(
            year: Int,
            isCrashYear: Bool,
            moneyEnergyChange: Double,
            volumePressure: Double,
            meanEnergy: Double,
            meanMomentum: Double,
            meanExhaustion: Double,
            meanStress: Double,
            cells: [MarketCell]
        ) {
            self.id = year
            self.year = year
            self.isCrashYear = isCrashYear
            self.moneyEnergyChange = moneyEnergyChange
            self.volumePressure = volumePressure
            self.meanEnergy = meanEnergy
            self.meanMomentum = meanMomentum
            self.meanExhaustion = meanExhaustion
            self.meanStress = meanStress
            self.cells = cells
        }
    }

    // ============================================================
    // MARK: - Grid
    // ============================================================

    let gridWidth: Int
    let gridHeight: Int

    private(set) var cells: [MarketCell] = []

    private(set) var historicalFrames: [HistoricalCAFrame] = []

    // ============================================================
    // MARK: - Stress Thresholds
    // ============================================================

    private let risingThreshold = 0.20
    private let stressedThreshold = 0.40
    private let criticalStressThreshold = 0.65
    private let releaseStressThreshold = 0.85

    private let energyReleaseThreshold = 0.08

    // ============================================================
    // MARK: - Cellular Automaton Parameters
    // ============================================================

    private let contagionRate = 0.20
    private let stressContagionRate = 0.12
    private let energyTransferRate = 0.06
    private let dissipationRate = 0.08
    private let exhaustionEnergyLossRate = 0.12
    private let pressureEnergyLossRate = 0.10
    private let momentumContagionRate = 0.08

    // ============================================================
    // MARK: - Exhaustion Weights
    // ============================================================

    private let inflationWeight = 0.35
    private let taxationWeight = 0.15
    private let stockSlowdownWeight = 0.50

    // ============================================================
    // MARK: - Initialization
    // ============================================================

    init(
        gridWidth: Int = 20,
        gridHeight: Int = 12
    ) {
        self.gridWidth = max(1, gridWidth)
        self.gridHeight = max(1, gridHeight)

        reset()
    }

    // ============================================================
    // MARK: - Normalize
    // ============================================================

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

    // ============================================================
    // MARK: - Clamp
    // ============================================================

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

    // ============================================================
    // MARK: - Money Supply Energy
    // ============================================================

    /*
     Positive M2 growth adds energy.
     Negative M2 growth removes energy.

     This function is evaluated ONCE for each historical year.
     It is not repeatedly applied as an artificial generation.
     */

    private func moneySupplyEnergyChange(
        growthM2: Double
    ) -> Double {

        guard growthM2.isFinite else {
            return 0
        }

        if growthM2 >= 0 {
            return normalize(
                growthM2,
                lowerBound: 0,
                upperBound: 20
            )
        }

        return -normalize(
            abs(growthM2),
            lowerBound: 0,
            upperBound: 20
        )
    }

    // ============================================================
    // MARK: - Reset
    // ============================================================

    func reset() {

        cells.removeAll()
        historicalFrames.removeAll()

        let count = gridWidth * gridHeight

        for index in 0..<count {

            cells.append(
                MarketCell(
                    id: index,
                    energy: 0,
                    momentum: 0,
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

    // ============================================================
    // MARK: - Initialize Historical Grid
    // ============================================================

    /*
     The first historical year establishes the initial market grid.

     Subsequent years DO NOT reset the grid.

     This is what allows the cellular automaton to carry historical
     state forward into the crash year.
     */

    private func initializeHistoricalGrid(
        initialEnergy: Double
    ) {

        let energy = clamp(initialEnergy)

        for index in cells.indices {

            cells[index] = MarketCell(
                id: cells[index].id,
                energy: energy,
                momentum: 0,
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
        }
    }

    // ============================================================
    // MARK: - Apply Crash-Year Volume
    // ============================================================

    /*
     Crash-year volume establishes the crash-year market-energy
     condition.

     IMPORTANT:
     It does NOT reset the historical CA.

     The accumulated historical state remains in the cells.
     */

    private func applyCrashYearVolume(
        _ volumePressure: Double
    ) {

        let targetEnergy = clamp(volumePressure)

        for index in cells.indices {

            let existingEnergy = cells[index].energy

            /*
             The crash-year volume establishes available activity
             while preserving the accumulated historical state.

             The average prevents the crash-year volume from erasing
             the historical trajectory.
             */

            let crashEnergy = clamp(
                0.50 * existingEnergy +
                0.50 * targetEnergy
            )

            cells[index].energy = crashEnergy
        }
    }

    // ============================================================
    // MARK: - Neighbor Topology
    // ============================================================

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

    // ============================================================
    // MARK: - State
    // ============================================================

    private func stateFor(
        energy: Double,
        stress: Double
    ) -> MarketCellState {

        if energy <= energyReleaseThreshold ||
            stress >= releaseStressThreshold {

            return .crash
        }

        if stress < risingThreshold {
            return .stable
        }

        if stress < stressedThreshold {
            return .rising
        }

        if stress < criticalStressThreshold {
            return .stressed
        }

        return .critical
    }

    // ============================================================
    // MARK: - Cellular Step
    // ============================================================

    private func step(
        _ current: MarketCell,
        contagion: Double,
        neighborStress: Double,
        neighborEnergy: Double,
        neighborMomentum: Double,
        moneyPressure: Double,
        inflationPressure: Double,
        taxationPressure: Double,
        economicGrowthPressure: Double,
        stockGrowthPressure: Double,
        stockSlowdownPressure: Double,
        bondPressure: Double,
        volumePressure: Double,
        cyclePressure: Double,
        shockPressure: Double,
        moneyEnergyChange: Double
    ) -> MarketCell {

        // --------------------------------------------------------
        // 1. Inflation exhaustion
        // --------------------------------------------------------

        let inflationExhaustion = normalize(
            inflationPressure *
            (1.0 + 0.60 * moneyPressure),
            lowerBound: 0,
            upperBound: 1.60
        )

        // --------------------------------------------------------
        // 2. Taxation exhaustion
        // --------------------------------------------------------

        let taxationExhaustion = clamp(
            taxationPressure
        )

        // --------------------------------------------------------
        // 3. Stock-growth slowdown exhaustion
        // --------------------------------------------------------

        let stockGrowthExhaustion = clamp(
            stockSlowdownPressure
        )

        // --------------------------------------------------------
        // 4. Internal exhaustion
        // --------------------------------------------------------

        let internalExhaustion = clamp(
            inflationWeight * inflationExhaustion +
            taxationWeight * taxationExhaustion +
            stockSlowdownWeight * stockGrowthExhaustion
        )

        // --------------------------------------------------------
        // 5. Interval pressure
        // --------------------------------------------------------

        let intervalExhaustion = clamp(
            0.15 * cyclePressure
        )

        // --------------------------------------------------------
        // 6. Historical pressure
        // --------------------------------------------------------

        let historicalPressure = clamp(
            0.15 * moneyPressure +
            0.15 * inflationPressure +
            0.10 * taxationPressure +
            0.10 * economicGrowthPressure +
            0.15 * stockGrowthPressure +
            0.15 * stockSlowdownPressure +
            0.05 * bondPressure +
            0.05 * volumePressure +
            0.05 * cyclePressure +
            0.05 * shockPressure
        )

        // --------------------------------------------------------
        // 7. Monetary energy
        // --------------------------------------------------------

        let monetaryEnergyBoost = clamp(
            moneyEnergyChange,
            -1,
            1
        )

        // --------------------------------------------------------
        // 8. Momentum
        // --------------------------------------------------------

        let momentumDrive = clamp(
            0.30 * moneyPressure +
            0.25 * stockGrowthPressure +
            0.15 * economicGrowthPressure +
            0.10 * volumePressure +
            0.10 * current.momentum +
            0.10 * neighborMomentum
        )

        // --------------------------------------------------------
        // 9. Equilibrium pressure
        // --------------------------------------------------------

        let equilibriumPressure = clamp(
            0.40 * stockSlowdownPressure +
            0.20 * inflationExhaustion +
            0.15 * taxationExhaustion +
            0.10 * bondPressure +
            0.05 * volumePressure +
            0.05 * cyclePressure +
            0.05 * neighborStress
        )

        // --------------------------------------------------------
        // 10. Equilibrium inflection
        // --------------------------------------------------------

        let equilibriumInflection = clamp(
            equilibriumPressure -
            momentumDrive
        )

        // --------------------------------------------------------
        // 11. Contagion
        // --------------------------------------------------------

        let exhaustionContagion =
            contagionRate * contagion

        let stressContagion =
            stressContagionRate * neighborStress

        let neighborEnergyDepletion = clamp(
            1.0 - neighborEnergy
        )

        let depletionContagion =
            0.15 * neighborEnergyDepletion

        let contagionExhaustion = clamp(
            exhaustionContagion +
            stressContagion +
            depletionContagion
        )

        // --------------------------------------------------------
        // 12. Local exhaustion
        // --------------------------------------------------------

        let localExhaustion = clamp(
            0.35 * internalExhaustion +
            0.15 * intervalExhaustion +
            0.20 * historicalPressure +
            0.20 * contagionExhaustion +
            0.10 * equilibriumInflection
        )

        // --------------------------------------------------------
        // 13. Energy transfer
        // --------------------------------------------------------

        let energyGradient =
            neighborEnergy -
            current.energy

        let energyTransfer =
            energyTransferRate *
            energyGradient

        // --------------------------------------------------------
        // 14. Energy dissipation
        // --------------------------------------------------------

        let dissipation = clamp(
            dissipationRate +
            exhaustionEnergyLossRate * localExhaustion +
            pressureEnergyLossRate * historicalPressure +
            0.05 * contagionExhaustion,
            0,
            0.40
        )

        // --------------------------------------------------------
        // 15. Next energy
        // --------------------------------------------------------

        let nextEnergy = clamp(
            current.energy +
            monetaryEnergyBoost +
            energyTransfer -
            dissipation
        )

        // --------------------------------------------------------
        // 16. Energy depletion
        // --------------------------------------------------------

        let energyDepletion = clamp(
            1.0 - nextEnergy
        )

        // --------------------------------------------------------
        // 17. Emergent exhaustion
        // --------------------------------------------------------

        let totalExhaustion = clamp(
            0.40 * localExhaustion +
            0.25 * energyDepletion +
            0.20 * contagionExhaustion +
            0.10 * equilibriumInflection +
            0.05 * shockPressure
        )

        // --------------------------------------------------------
        // 18. Stress
        // --------------------------------------------------------

        let nextStress = clamp(
            0.35 * totalExhaustion +
            0.25 * contagionExhaustion +
            0.15 * equilibriumInflection +
            0.15 * energyDepletion +
            0.05 * bondPressure +
            0.05 * shockPressure
        )

        // --------------------------------------------------------
        // 19. Momentum gain
        // --------------------------------------------------------

        let monetaryMomentumEffect =
            0.12 * monetaryEnergyBoost

        let momentumGain =
            0.12 * momentumDrive +
            monetaryMomentumEffect

        // --------------------------------------------------------
        // 20. Momentum loss
        // --------------------------------------------------------

        let momentumLoss =
            0.10 * totalExhaustion +
            0.08 * equilibriumInflection +
            0.05 * energyDepletion

        // --------------------------------------------------------
        // 21. Neighbor momentum
        // --------------------------------------------------------

        let neighborMomentumEffect =
            momentumContagionRate *
            (
                neighborMomentum -
                current.momentum
            )

        // --------------------------------------------------------
        // 22. Next momentum
        // --------------------------------------------------------

        let nextMomentum = clamp(
            current.momentum +
            momentumGain -
            momentumLoss +
            neighborMomentumEffect,
            -1,
            1
        )

        // --------------------------------------------------------
        // 23. State
        // --------------------------------------------------------

        let nextState = stateFor(
            energy: nextEnergy,
            stress: nextStress
        )

        // --------------------------------------------------------
        // 24. Return
        // --------------------------------------------------------

        return MarketCell(
            id: current.id,
            energy: nextEnergy,
            momentum: nextMomentum,
            momentumChange:
                nextMomentum -
                current.momentum,
            equilibrium: equilibriumPressure,
            equilibriumInflection:
                equilibriumInflection,
            inflationExhaustion:
                inflationExhaustion,
            taxationExhaustion:
                taxationExhaustion,
            stockGrowthExhaustion:
                stockGrowthExhaustion,
            contagionExhaustion:
                contagionExhaustion,
            intervalExhaustion:
                intervalExhaustion,
            internalExhaustion:
                internalExhaustion,
            exhaustion: totalExhaustion,
            stress: nextStress,
            state: nextState
        )
    }

    // ============================================================
    // MARK: - Run One Historical Year
    // ============================================================

    private func runHistoricalYear(
        input: HistoricalCAInput
    ) {

        let moneyPressure = normalize(
            input.growthM2,
            lowerBound: -5,
            upperBound: 20
        )

        let inflationPressure = normalize(
            input.inflationPercent,
            lowerBound: -5,
            upperBound: 15
        )

        let excessTaxGrowth =
            input.taxGrowthPercent -
            input.economicGrowthPercent

        let taxationPressure = normalize(
            excessTaxGrowth,
            lowerBound: -5,
            upperBound: 15
        )

        let economicGrowthPressure = normalize(
            input.economicGrowthPercent,
            lowerBound: -10,
            upperBound: 15
        )

        let stockGrowthPressure = normalize(
            input.stockGrowthPercent,
            lowerBound: -50,
            upperBound: 100
        )

        let momentumChange =
            input.stockGrowthPercent -
            input.previousStockGrowthPercent

        let stockSlowdownPressure = normalize(
            -momentumChange,
            lowerBound: 0,
            upperBound: 30
        )

        let bondPressure = normalize(
            input.bondYieldAvgPercent,
            lowerBound: 0,
            upperBound: 15
        )

        let volumePressure = normalize(
            input.growthVolumePercent,
            lowerBound: -50,
            upperBound: 300
        )

        let cyclePressure = normalize(
            input.crashInterval,
            lowerBound: 0,
            upperBound: 25
        )

        let shockPressure = normalize(
            input.externalShockPercent,
            lowerBound: 0,
            upperBound: 100
        )

        let moneyEnergyChange =
            moneySupplyEnergyChange(
                growthM2: input.growthM2
            )

        // --------------------------------------------------------
        // Simultaneous generation update
        // --------------------------------------------------------

        let currentCells = cells
        var nextCells = currentCells

        for index in currentCells.indices {

            let neighbors = neighborIndices(
                for: index
            )

            if neighbors.isEmpty {

                nextCells[index] = step(
                    currentCells[index],
                    contagion: 0,
                    neighborStress: 0,
                    neighborEnergy:
                        currentCells[index].energy,
                    neighborMomentum:
                        currentCells[index].momentum,
                    moneyPressure: moneyPressure,
                    inflationPressure: inflationPressure,
                    taxationPressure: taxationPressure,
                    economicGrowthPressure:
                        economicGrowthPressure,
                    stockGrowthPressure:
                        stockGrowthPressure,
                    stockSlowdownPressure:
                        stockSlowdownPressure,
                    bondPressure: bondPressure,
                    volumePressure: volumePressure,
                    cyclePressure: cyclePressure,
                    shockPressure: shockPressure,
                    moneyEnergyChange:
                        moneyEnergyChange
                )

                continue
            }

            let neighborExhaustion =
                neighbors.reduce(0.0) {
                    total,
                    neighborIndex in

                    total +
                    currentCells[
                        neighborIndex
                    ].exhaustion

                } / Double(neighbors.count)

            let neighborStress =
                neighbors.reduce(0.0) {
                    total,
                    neighborIndex in

                    total +
                    currentCells[
                        neighborIndex
                    ].stress

                } / Double(neighbors.count)

            let neighborEnergy =
                neighbors.reduce(0.0) {
                    total,
                    neighborIndex in

                    total +
                    currentCells[
                        neighborIndex
                    ].energy

                } / Double(neighbors.count)

            let neighborMomentum =
                neighbors.reduce(0.0) {
                    total,
                    neighborIndex in

                    total +
                    currentCells[
                        neighborIndex
                    ].momentum

                } / Double(neighbors.count)

            let contagion = clamp(
                0.50 * neighborExhaustion +
                0.30 * neighborStress +
                0.20 * (1.0 - neighborEnergy)
            )

            nextCells[index] = step(
                currentCells[index],
                contagion: contagion,
                neighborStress: neighborStress,
                neighborEnergy: neighborEnergy,
                neighborMomentum: neighborMomentum,
                moneyPressure: moneyPressure,
                inflationPressure: inflationPressure,
                taxationPressure: taxationPressure,
                economicGrowthPressure:
                    economicGrowthPressure,
                stockGrowthPressure:
                    stockGrowthPressure,
                stockSlowdownPressure:
                    stockSlowdownPressure,
                bondPressure: bondPressure,
                volumePressure: volumePressure,
                cyclePressure: cyclePressure,
                shockPressure: shockPressure,
                moneyEnergyChange:
                    moneyEnergyChange
            )
        }

        // Entire historical year updates simultaneously.
        cells = nextCells
    }

    // ============================================================
    // MARK: - Historical Frame
    // ============================================================

    private func makeHistoricalFrame(
        input: HistoricalCAInput,
        isCrashYear: Bool,
        moneyEnergyChange: Double,
        volumePressure: Double
    ) -> HistoricalCAFrame {

        let meanEnergy = mean(\.energy)
        let meanMomentum = mean(\.momentum)
        let meanExhaustion = mean(\.exhaustion)
        let meanStress = mean(\.stress)

        return HistoricalCAFrame(
            year: input.year,
            isCrashYear: isCrashYear,
            moneyEnergyChange: moneyEnergyChange,
            volumePressure: volumePressure,
            meanEnergy: meanEnergy,
            meanMomentum: meanMomentum,
            meanExhaustion: meanExhaustion,
            meanStress: meanStress,
            cells: cells
        )
    }

    // ============================================================
    // MARK: - Historical Sequence
    // ============================================================

    func analyzeHistoricalSequence(
        crashYear: HistoricalCAInput,
        priorYears: [HistoricalCAInput]
    ) -> MarketSimulationResult {

        reset()

        let orderedPriorYears =
            priorYears
                .filter {
                    $0.year < crashYear.year
                }
                .sorted {
                    $0.year < $1.year
                }

        // ========================================================
        // 1. Establish the initial historical condition
        // ========================================================

        /*
         Start with a neutral market-energy field.

         The first historical year then modifies this field.
         */

        initializeHistoricalGrid(
            initialEnergy: 0.50
        )

        // ========================================================
        // 2. Evolve every prior historical year
        // ========================================================

        for historicalYear in orderedPriorYears {

            runHistoricalYear(
                input: historicalYear
            )

            let moneyEnergy =
                moneySupplyEnergyChange(
                    growthM2:
                        historicalYear.growthM2
                )

            let volumePressure =
                normalize(
                    historicalYear.growthVolumePercent,
                    lowerBound: -50,
                    upperBound: 300
                )

            historicalFrames.append(
                makeHistoricalFrame(
                    input: historicalYear,
                    isCrashYear: false,
                    moneyEnergyChange:
                        moneyEnergy,
                    volumePressure:
                        volumePressure
                )
            )
        }

        // ========================================================
        // 3. Crash-year volume establishes crash-year condition
        // ========================================================

        let crashVolumePressure =
            normalize(
                crashYear.growthVolumePercent,
                lowerBound: -50,
                upperBound: 300
            )

        /*
         Do not reset the grid.

         The crash-year volume is applied to the accumulated
         historical cellular state.
         */

        applyCrashYearVolume(
            crashVolumePressure
        )

        // ========================================================
        // 4. Evolve the crash year
        // ========================================================

        runHistoricalYear(
            input: crashYear
        )

        let crashMoneyEnergy =
            moneySupplyEnergyChange(
                growthM2:
                    crashYear.growthM2
            )

        historicalFrames.append(
            makeHistoricalFrame(
                input: crashYear,
                isCrashYear: true,
                moneyEnergyChange:
                    crashMoneyEnergy,
                volumePressure:
                    crashVolumePressure
            )
        )

        // ========================================================
        // 5. Final statistics
        // ========================================================

        let moneyPressure = normalize(
            crashYear.growthM2,
            lowerBound: -5,
            upperBound: 20
        )

        let inflationPressure = normalize(
            crashYear.inflationPercent,
            lowerBound: -5,
            upperBound: 15
        )

        let excessTaxGrowth =
            crashYear.taxGrowthPercent -
            crashYear.economicGrowthPercent

        let taxationPressure = normalize(
            excessTaxGrowth,
            lowerBound: -5,
            upperBound: 15
        )

        let economicGrowthPressure = normalize(
            crashYear.economicGrowthPercent,
            lowerBound: -10,
            upperBound: 15
        )

        let stockGrowthPressure = normalize(
            crashYear.stockGrowthPercent,
            lowerBound: -50,
            upperBound: 100
        )

        let momentumChange =
            crashYear.stockGrowthPercent -
            crashYear.previousStockGrowthPercent

        let stockSlowdownPressure = normalize(
            -momentumChange,
            lowerBound: 0,
            upperBound: 30
        )

        let bondPressure = normalize(
            crashYear.bondYieldAvgPercent,
            lowerBound: 0,
            upperBound: 15
        )

        let volumePressure = normalize(
            crashYear.growthVolumePercent,
            lowerBound: -50,
            upperBound: 300
        )

        let cyclePressure = normalize(
            crashYear.crashInterval,
            lowerBound: 0,
            upperBound: 25
        )

        let shockPressure = normalize(
            crashYear.externalShockPercent,
            lowerBound: 0,
            upperBound: 100
        )

        let meanEnergy = mean(\.energy)
        let meanMomentum = mean(\.momentum)
        let meanExhaustion = mean(\.exhaustion)
        let meanStress = mean(\.stress)

        let criticalFraction = fraction {
            $0.state == .critical
        }

        let releaseFraction = fraction {
            $0.state == .crash
        }

        let usefulFuel = clamp(
            moneyPressure *
            meanEnergy *
            (1.0 - meanExhaustion)
        )

        let overdrivePressure = clamp(
            moneyPressure *
            inflationPressure
        )

        let equilibriumPressure =
            mean(\.equilibrium)

        let equilibriumInflection =
            mean(\.equilibriumInflection)

        let systemicRisk = clamp(
            0.20 * meanExhaustion +
            0.20 * meanStress +
            0.15 * criticalFraction +
            0.10 * releaseFraction +
            0.10 * (1.0 - meanEnergy) +
            0.10 * stockSlowdownPressure +
            0.10 * inflationPressure +
            0.05 * shockPressure
        )

        return MarketSimulationResult(
            year: crashYear.year,
            moneyPressure: moneyPressure,
            inflationPressure: inflationPressure,
            taxationPressure: taxationPressure,
            economicGrowthPressure:
                economicGrowthPressure,
            stockGrowthPressure:
                stockGrowthPressure,
            stockSlowdownPressure:
                stockSlowdownPressure,
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
            equilibriumPressure:
                equilibriumPressure,
            equilibriumInflection:
                equilibriumInflection,
            systemicRisk: systemicRisk,
            cells: cells
        )
    }

    // ============================================================
    // MARK: - Single-Year Compatibility
    // ============================================================

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

        let input = HistoricalCAInput(
            year: year,
            growthM2: growthM2,
            inflationPercent: inflationPercent,
            taxGrowthPercent: taxGrowthPercent,
            economicGrowthPercent:
                economicGrowthPercent,
            stockGrowthPercent:
                stockGrowthPercent,
            previousStockGrowthPercent:
                previousStockGrowthPercent,
            bondYieldAvgPercent:
                bondYieldAvgPercent,
            growthVolumePercent:
                growthVolumePercent,
            crashInterval:
                crashInterval,
            externalShockPercent:
                externalShockPercent
        )

        return analyzeHistoricalSequence(
            crashYear: input,
            priorYears: []
        )
    }

    // ============================================================
    // MARK: - Statistics
    // ============================================================

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
            / Double(cells.count)
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
