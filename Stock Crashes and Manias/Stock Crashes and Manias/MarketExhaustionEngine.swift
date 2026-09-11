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

    // ========================================================
    // MARK: Grid
    // ========================================================

    let gridWidth: Int
    let gridHeight: Int

    private(set) var cells: [MarketCell] = []

    /// One frame for every historical year.
    ///
    /// This is the canonical historical visualization path.
    private(set) var historicalFrames: [HistoricalCAFrame] = []

    // ========================================================
    // MARK: State Thresholds
    // ========================================================

    private let risingThreshold = 0.20
    private let stressedThreshold = 0.40

    /// IMPORTANT:
    /// 0.65 is ONLY a stress classification boundary.
    /// It is never assigned as exhaustion.
    private let criticalStressThreshold = 0.65

    private let releaseStressThreshold = 0.85
    private let energyReleaseThreshold = 0.08

    // ========================================================
    // MARK: Cellular Automaton Parameters
    // ========================================================

    private let contagionRate = 0.20
    private let stressContagionRate = 0.12

    private let energyTransferRate = 0.06
    private let dissipationRate = 0.08

    private let exhaustionEnergyLossRate = 0.12
    private let pressureEnergyLossRate = 0.10

    private let momentumContagionRate = 0.08

    // ========================================================
    // MARK: Exhaustion Weights
    // ========================================================
    // must total to 1
    private let inflationWeight = 0.15
    private let taxationWeight = 0.15
    private let stockSlowdownWeight = 0.20
    private let monetaryPolicyWeight = 0.15
    private let bankingCreditWeight = 0.35
    // ========================================================
    // MARK: Initialization
    // ========================================================

    init(
        gridWidth: Int = 10,
        gridHeight: Int = 10
    ) {
        self.gridWidth = max(gridWidth, 1)
        self.gridHeight = max(gridHeight, 1)

        reset()
    }

    // ========================================================
    // MARK: Normalize
    // ========================================================

    private func normalize(
        _ value: Double,
        min lower: Double,
        max upper: Double
    ) -> Double {

        guard value.isFinite,
              lower.isFinite,
              upper.isFinite,
              upper > lower
        else {
            return 0
        }

        return clamp(
            (value - lower) / (upper - lower)
        )
    }

    // ========================================================
    // MARK: Clamp
    // ========================================================

    private func clamp(
        _ value: Double,
        min lower: Double = 0,
        max upper: Double = 1
    ) -> Double {

        guard value.isFinite else {
            return lower
        }

        return Swift.min(
            Swift.max(value, lower),
            upper
        )
    }

    // ========================================================
    // MARK: Money Supply → Energy
    // ========================================================

    private func moneySupplyEnergyChange(
        growthM2: Double
    ) -> Double {

        guard growthM2.isFinite else {
            return 0
        }

        if growthM2 >= 0 {

            return clamp(
                growthM2 / 20.0,
                min: 0,
                max: 1
            )
        }

        return -clamp(
            abs(growthM2) / 20.0,
            min: 0,
            max: 1
        )
    }

    // ========================================================
    // MARK: Reset
    // ========================================================

    func reset() {

        cells = Array(
            repeating: MarketCell(
                id: UUID(),
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
            ),
            count: gridWidth * gridHeight
        )

        historicalFrames.removeAll()

        for index in cells.indices {

            cells[index] = MarketCell(
                id: UUID(),
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
        }
    }

    // ========================================================
    // MARK: Initialize Historical Grid
    // ========================================================

    /// The FIRST prior historical year begins here.
    ///
    /// This is deliberately the only baseline initialization.
    /// Every subsequent historical year inherits the previous
    /// generation's cells.
    func initializeHistoricalGrid(
        initialEnergy: Double = 0.50
    ) {
        let baselineEnergy = clamp(initialEnergy)

        cells = (0 ..< gridWidth * gridHeight).map { _ in
            MarketCell(
                id: UUID(),
                energy: baselineEnergy,
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

    private func normalizeSigned(
        _ value: Double,
        min lower: Double,
        max upper: Double
    ) -> Double {
        guard value.isFinite,
              lower.isFinite,
              upper.isFinite,
              upper > lower
        else {
            return 0
        }

        let midpoint = (lower + upper) / 2.0
        let halfRange = (upper - lower) / 2.0

        guard halfRange > 0 else {
            return 0
        }

        return clamp(
            (value - midpoint) / halfRange,
            min: -1,
            max: 1
        )
    }
    private func applyCrashYearVolume(
        _ volumePressure: Double
    ) {

        let targetEnergy = clamp(volumePressure)

        for index in cells.indices {

            let existingEnergy = clamp(
                cells[index].energy
            )

            let newEnergy =
                0.50 * existingEnergy +
                0.50 * targetEnergy

            cells[index].energy = clamp(newEnergy)

            cells[index].state = stateFor(
                energy: cells[index].energy,
                stress: cells[index].stress
            )
        }
    }

    // ========================================================
    // MARK: Neighbor Indices
    // ========================================================

    private func neighborIndices(
        for index: Int
    ) -> [Int] {

        guard index >= 0,
              index < cells.count
        else {
            return []
        }

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

    // ========================================================
    // MARK: State Classification
    // ========================================================

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

    // ========================================================
    // MARK: CA Step
    // ========================================================


    private func step(
        current: MarketCell,
        contagion: Double,
        neighborStress: Double,
        neighborEnergy: Double,
        neighborMomentum: Double,
        moneyPressure: Double,
        moneyPolicyChangePressure: Double,
        policyDirectionalForce: Double,
        bankingCreditStressPressure: Double,
        bankingPolicyInteraction: Double,
        financialAttractorPressure: Double,
        directionalFinancialForce: Double,
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

        // ========================================================
        // MARK: Normalize / Clamp Financial Inputs
        // ========================================================

        let bankingStress = clamp(
            bankingCreditStressPressure
        )

        let policyMagnitude = clamp(
            moneyPolicyChangePressure
        )

        let policyDirection = clamp(
            policyDirectionalForce,
            min: -1,
            max: 1
        )

        let policyInteraction = clamp(
            bankingPolicyInteraction
        )

        let financialAttractor = clamp(
            financialAttractorPressure
        )

        let directionalFinancial = clamp(
            directionalFinancialForce,
            min: -1,
            max: 1
        )

        // ========================================================
        // MARK: Inflation-Driven Exhaustion
        // ========================================================

        let inflationExhaustion = normalize(
            inflationPressure *
            (1.0 + 0.60 * moneyPressure),
            min: 0,
            max: 1.60
        )

        // ========================================================
        // MARK: Taxation Exhaustion
        // ========================================================

        let taxationExhaustion = clamp(
            taxationPressure
        )

        // ========================================================
        // MARK: Stock-Growth Slowdown Exhaustion
        // ========================================================

        let stockGrowthExhaustion = clamp(
            stockSlowdownPressure
        )

        // ========================================================
        // MARK: Banking / Credit Fragility
        //
        // Banking stress is a STATE variable.
        //
        // It does not automatically mean the cell crashes.
        //
        // Instead, it makes the cell more sensitive to:
        //
        // - policy intervention
        // - existing stress
        // - exhaustion
        // - neighbor contagion
        //
        // This distinction is important.
        // ========================================================

        let bankingCreditFragility = clamp(
            bankingStress
        )

        // ========================================================
        // MARK: Financial Attractor
        //
        // Banking stress = destabilizing state.
        //
        // Policy magnitude = forcing strength.
        //
        // Their interaction = nonlinear attractor force.
        //
        // Existing local stress amplifies the effect.
        // ========================================================

        let localFinancialAmplification = clamp(
            0.40 * current.stress
            +
            0.30 * current.exhaustion
            +
            0.20 * clamp(
                1.0 - current.energy
            )
            +
            0.10 * clamp(
                contagion
            )
        )

        let nonlinearFinancialAttractor = clamp(
            financialAttractor
            *
            (
                0.50
                +
                0.50 * localFinancialAmplification
            )
        )

        // ========================================================
        // MARK: Policy Direction
        //
        // Policy does NOT directly become crash pressure.
        //
        // Instead, it changes the direction of the trajectory.
        //
        // Positive direction = expansionary/easing direction.
        //
        // Negative direction = contractionary/tightening direction.
        //
        // Banking stress increases the sensitivity of the system
        // to that policy direction.
        // ========================================================

        let policyTrajectoryForce = clamp(
            directionalFinancial
            *
            (
                0.50
                +
                0.50 * bankingStress
            ),
            min: -1,
            max: 1
        )

        // ========================================================
        // MARK: Internal Exhaustion
        //
        // Monetary policy is intentionally NOT included here as
        // a simple additive exhaustion term.
        //
        // Banking stress contributes as financial fragility.
        //
        // The nonlinear financial attractor enters separately
        // below so that policy + banking interaction is preserved.
        // ========================================================

        let internalExhaustion = clamp(
            inflationWeight *
            inflationExhaustion

            +

            taxationWeight *
            taxationExhaustion

            +

            stockSlowdownWeight *
            stockGrowthExhaustion

            +

            bankingCreditWeight *
            bankingCreditFragility

            +

            0.10 *
            nonlinearFinancialAttractor
        )

        // ========================================================
        // MARK: Crash-Cycle Exhaustion
        // ========================================================

        let intervalExhaustion = clamp(
            0.15 * cyclePressure
        )

        // ========================================================
        // MARK: Historical Pressure
        //
        // General macroeconomic pressure.
        //
        // Banking stress is deliberately kept out of this
        // generic bucket because it has its own nonlinear path.
        // ========================================================

        let historicalPressure = clamp(
            0.15 * moneyPressure

            +

            0.15 * inflationPressure

            +

            0.10 * taxationPressure

            +

            0.10 * economicGrowthPressure

            +

            0.15 * stockGrowthPressure

            +

            0.15 * stockSlowdownPressure

            +

            0.05 * bondPressure

            +

            0.05 * volumePressure

            +

            0.05 * cyclePressure

            +

            0.05 * shockPressure
        )

        // ========================================================
        // MARK: Monetary Energy
        // ========================================================

        let monetaryEnergyBoost = clamp(
            moneyEnergyChange,
            min: -1,
            max: 1
        )

        // ========================================================
        // MARK: Momentum Drive
        //
        // Normal macro momentum plus the directional financial
        // force.
        //
        // This is where monetary policy changes trajectory.
        //
        // It is NOT treated as a one-way crash pressure.
        // ========================================================

        let baseMomentumDrive = clamp(
            0.25 * moneyPressure

            +

            0.20 * stockGrowthPressure

            +

            0.15 * economicGrowthPressure

            +

            0.10 * volumePressure

            +

            0.10 * clamp(
                current.momentum,
                min: -1,
                max: 1
            )

            +

            0.10 * clamp(
                neighborMomentum,
                min: -1,
                max: 1
            )
        )

        // Financial policy direction is allowed to move the
        // trajectory in either direction.
        let financialMomentumDrive = clamp(
            0.15 * policyTrajectoryForce
            +
            0.10 * directionalFinancial
        )

        let momentumDrive = clamp(
            baseMomentumDrive
            +
            financialMomentumDrive,
            min: -1,
            max: 1
        )

        // ========================================================
        // MARK: Equilibrium Pressure
        // ========================================================

        let equilibriumPressure = clamp(
            0.40 * stockSlowdownPressure

            +

            0.20 * inflationExhaustion

            +

            0.15 * taxationExhaustion

            +

            0.10 * bondPressure

            +

            0.05 * volumePressure

            +

            0.05 * cyclePressure

            +

            0.05 * neighborStress

            +

            0.10 * bankingStress

            +

            0.10 * nonlinearFinancialAttractor
        )

        // ========================================================
        // MARK: Equilibrium Inflection
        // ========================================================

        let equilibriumInflection = clamp(
            equilibriumPressure -
            momentumDrive
        )

        // ========================================================
        // MARK: Neighbor Contagion
        //
        // Neighbor instability spreads spatially.
        //
        // Banking stress does not simply overwrite every cell.
        //
        // Instead, the existing contagion becomes more powerful
        // when the financial attractor is active.
        // ========================================================

        let exhaustionContagion =
            contagionRate *
            clamp(contagion)

        let stressContagion =
            stressContagionRate *
            clamp(neighborStress)

        let neighborEnergyDepletion = clamp(
            1.0 - clamp(neighborEnergy)
        )

        let depletionContagion =
            0.15 * neighborEnergyDepletion

        let baseContagion = clamp(
            exhaustionContagion
            +
            stressContagion
            +
            depletionContagion
        )

        // ========================================================
        // Financial Contagion Amplifier
        //
        // High banking stress + active policy forcing causes
        // already-existing contagion to propagate more strongly.
        //
        // This is the spatial component of the attractor.
        // ========================================================

        let financialContagionAmplifier = clamp(
            1.0
            +
            0.50 * bankingStress
            +
            0.50 * policyInteraction
            +
            0.50 * nonlinearFinancialAttractor
        )

        let contagionExhaustion = clamp(
            baseContagion *
            financialContagionAmplifier
        )

        // ========================================================
        // MARK: Local Exhaustion
        //
        // The financial attractor contributes to local exhaustion
        // only after interacting with the existing CA state.
        // ========================================================

        let localExhaustion =
            0.70 * internalExhaustion
            + 0.15 * contagionExhaustion
            + 0.05 * historicalPressure
            + 0.05 * intervalExhaustion
            + 0.03 * equilibriumInflection
            + 0.02 * nonlinearFinancialAttractor

        // ========================================================
        // MARK: Energy Transfer Between Neighboring Cells
        // ========================================================

        let energyGradient =
            clamp(neighborEnergy) -
            clamp(current.energy)

        let energyTransfer =
            energyTransferRate *
            energyGradient

        // ========================================================
        // MARK: Financial Energy Effect
        //
        // Monetary policy can either add or remove directional
        // energy depending on its sign.
        //
        // Banking stress determines how strongly the system
        // responds to that forcing.
        //
        // This is deliberately bounded.
        // ========================================================

        let financialEnergyEffect = clamp(
            0.05 *
            policyTrajectoryForce
            *
            (
                0.50
                +
                0.50 * bankingStress
            ),
            min: -0.05,
            max: 0.05
        )

        // ========================================================
        // MARK: Energy Dissipation
        // ========================================================

        let dissipation = clamp(
            dissipationRate

            +

            exhaustionEnergyLossRate *
            localExhaustion

            +

            pressureEnergyLossRate *
            historicalPressure

            +

            0.05 *
            contagionExhaustion

            +

            0.03 *
            nonlinearFinancialAttractor,

            min: 0,
            max: 0.40
        )

        // ========================================================
        // MARK: Next Energy
        // ========================================================

        let nextEnergy = clamp(
            current.energy

            +

            monetaryEnergyBoost

            +

            energyTransfer

            +

            financialEnergyEffect

            -

            dissipation
        )

        // ========================================================
        // MARK: Energy Depletion
        // ========================================================

        let energyDepletion = clamp(
            1.0 - nextEnergy
        )

        // ========================================================
        // MARK: Total Exhaustion
        //
        // IMPORTANT:
        //
        // Exhaustion emerges from interacting pressures.
        //
        // It is NOT assigned from the 0.65 critical threshold.
        //
        // The financial attractor enters only after banking stress,
        // policy forcing, local instability, and contagion interact.
        // ========================================================

        let totalExhaustion = clamp(
            0.70 * localExhaustion
            + 0.10 * energyDepletion
            + 0.10 * contagionExhaustion
            + 0.05 * equilibriumInflection
            + 0.03 * shockPressure
            + 0.02 * nonlinearFinancialAttractor
        )

        // ========================================================
        // MARK: Stress
        //
        // Financial fragility becomes particularly important
        // here, but still interacts with the CA state.
        // ========================================================

        let financialStressResponse = clamp(
            bankingStress *
            (
                0.50
                +
                0.50 * nonlinearFinancialAttractor
            )
        )

        let nextStress = clamp(
            0.30 * totalExhaustion

            +

            0.20 * contagionExhaustion

            +

            0.15 * equilibriumInflection

            +

            0.15 * energyDepletion

            +

            0.05 * bondPressure

            +

            0.05 * shockPressure

            +

            0.10 * financialStressResponse
        )

        // ========================================================
        // MARK: Momentum
        //
        // Monetary policy changes direction.
        //
        // Tightening can push momentum downward.
        //
        // Easing can push momentum upward.
        //
        // Banking stress increases sensitivity to the policy
        // forcing term.
        // ========================================================

        let monetaryMomentumEffect =
            0.08 * monetaryEnergyBoost

        let financialMomentumEffect =
            0.12 * policyTrajectoryForce

            +

            0.08 * directionalFinancial

        let momentumGain =
            0.12 * momentumDrive

            +

            monetaryMomentumEffect

            +

            financialMomentumEffect

        // --------------------------------------------------------
        // Momentum loss
        // --------------------------------------------------------

        let momentumLoss =
            0.10 * totalExhaustion

            +

            0.08 * equilibriumInflection

            +

            0.05 * energyDepletion

            +

            0.05 * nonlinearFinancialAttractor

        // ========================================================
        // Neighbor Momentum Effect
        // ========================================================

        let neighborMomentumEffect =
            momentumContagionRate *
            (
                clamp(
                    neighborMomentum,
                    min: -1,
                    max: 1
                )

                -

                clamp(
                    current.momentum,
                    min: -1,
                    max: 1
                )
            )

        // ========================================================
        // MARK: Financial Momentum Feedback
        //
        // When banking stress is high, the policy direction has
        // greater influence on the cell's trajectory.
        //
        // This creates sensitivity without making the policy
        // variable an automatic crash trigger.
        // ========================================================

        let financialMomentumFeedback = clamp(
            policyDirection
            *
            bankingStress
            *
            (
                0.05
                +
                0.05 * current.stress
                +
                0.05 * contagionExhaustion
            ),
            min: -0.15,
            max: 0.15
        )

        // ========================================================
        // MARK: Next Momentum
        // ========================================================

        let nextMomentum = clamp(
            current.momentum

            +

            momentumGain

            -

            momentumLoss

            +

            neighborMomentumEffect

            +

            financialMomentumFeedback,

            min: -1,
            max: 1
        )

        let nextMomentumChange =
            nextMomentum -
            current.momentum

        // ========================================================
        // MARK: Final Cell State
        // ========================================================

        let nextState = stateFor(
            energy: nextEnergy,
            stress: nextStress
        )

        // ========================================================
        // MARK: Return
        // ========================================================

        return MarketCell(
            id: current.id,
            energy: nextEnergy,
            momentum: nextMomentum,
            momentumChange: nextMomentumChange,
            equilibrium: equilibriumPressure,
            equilibriumInflection: equilibriumInflection,
            inflationExhaustion: inflationExhaustion,
            taxationExhaustion: taxationExhaustion,
            stockGrowthExhaustion: stockGrowthExhaustion,
            contagionExhaustion: contagionExhaustion,
            intervalExhaustion: intervalExhaustion,
            internalExhaustion: internalExhaustion,
            exhaustion: totalExhaustion,
            stress: nextStress,
            state: nextState
        )
    }



    // ========================================================
    // MARK: Run Historical Year
    // ========================================================

    @discardableResult
    private func runHistoricalYear(
        _ input: HistoricalCAInput,
        isCrashYear: Bool
    ) -> HistoricalCAFrame {

        // --------------------------------------------------------
        // Normalize historical inputs
        // --------------------------------------------------------

        let moneyPressure = normalize(
            input.growthM2,
            min: -5,
            max: 20
        )

        // --------------------------------------------------------
        // BANKING / CREDIT STRESS
        //
        // This is a STATE / FRAGILITY variable.
        //
        // Historical rating is assumed to be 0...5.
        //
        // 0 = no meaningful banking/credit stress
        // 5 = extreme banking/credit stress
        //
        // Unlike monetary policy, this variable does not have
        // direction. Higher values mean greater financial
        // fragility.
        // --------------------------------------------------------

        let bankingCreditStressPressure = normalize(
            input.bankingCreditStressRating,
            min: 0,
            max: 5
        )

        let moneyPolicyDirection = normalizeSigned(
            input.moneyPolicyChangeImpact,
            min: -6,
            max: 6
        )

        let moneyPolicyChangePressure = abs(
            moneyPolicyDirection
        )

        let bankingPolicyInteraction = clamp(
            bankingCreditStressPressure *
            moneyPolicyChangePressure
        )

        let policyDirectionalForce = clamp(
            moneyPolicyDirection,
            min: -1,
            max: 1
        )


        // --------------------------------------------------------
        // FINANCIAL ATTRACTOR FORCE
        //
        // Banking stress establishes the unstable state.
        //
        // Policy magnitude determines how strongly the system is
        // being forced.
        //
        // Their interaction becomes disproportionately important
        // when banking stress is already elevated.
        // --------------------------------------------------------

        let financialAttractorPressure = clamp(
            0.50 * bankingCreditStressPressure
            +
            0.20 * bankingPolicyInteraction
            +
            0.30 * abs(policyDirectionalForce)
        )

        // --------------------------------------------------------
        // DIRECTIONAL FINANCIAL FORCE
        //
        // Preserve the policy sign so tightening and loosening
        // produce different trajectories.
        //
        // Banking stress amplifies the directional effect.
        // --------------------------------------------------------

        let directionalFinancialForce = clamp(
            policyDirectionalForce *
            (
                0.50
                +
                0.50 * bankingCreditStressPressure
            )
        )

        // --------------------------------------------------------
        // Other normalized historical inputs
        // --------------------------------------------------------

        let inflationPressure = normalize(
            input.inflationPercent,
            min: -5,
            max: 15
        )

        let excessTaxGrowth =
            input.taxGrowthPercent -
            input.economicGrowthPercent

        let taxationPressure = normalize(
            excessTaxGrowth,
            min: -5,
            max: 15
        )

        let economicGrowthPressure = normalize(
            input.economicGrowthPercent,
            min: -10,
            max: 15
        )

        let stockGrowthPressure = normalize(
            input.stockGrowthPercent,
            min: -50,
            max: 100
        )

        // --------------------------------------------------------
        // Stock-growth slowdown
        // --------------------------------------------------------

        let momentumChange =
            input.stockGrowthPercent -
            input.previousStockGrowthPercent

        let stockSlowdownPressure = normalize(
            -momentumChange,
            min: 0,
            max: 30
        )

        let bondPressure = normalize(
            input.bondYieldAvgPercent,
            min: 0,
            max: 15
        )

        let volumePressure = normalize(
            input.growthVolumePercent,
            min: -50,
            max: 300
        )

        let cyclePressure = normalize(
            input.crashInterval,
            min: 0,
            max: 25
        )

        let shockPressure = normalize(
            input.externalShockPercent,
            min: 0,
            max: 100
        )

        let moneyEnergyChange = moneySupplyEnergyChange(
            growthM2: input.growthM2
        )

        // --------------------------------------------------------
        // IMPORTANT:
        //
        // All cells in this generation are calculated from the
        // SAME previous generation.
        //
        // We never read partially updated nextCells.
        // --------------------------------------------------------

        let currentCells = cells
        var nextCells = currentCells

        for index in currentCells.indices {

            let current = currentCells[index]

            let neighbors = neighborIndices(for: index)

            // ----------------------------------------------------
            // Isolated cell
            // ----------------------------------------------------

            if neighbors.isEmpty {

                nextCells[index] = step(
                    current: current,
                    contagion: 0,
                    neighborStress: 0,
                    neighborEnergy: current.energy,
                    neighborMomentum: current.momentum,
                    moneyPressure: moneyPressure,
                    moneyPolicyChangePressure: moneyPolicyChangePressure,
                    policyDirectionalForce: policyDirectionalForce,
                    bankingCreditStressPressure: bankingCreditStressPressure,
                    bankingPolicyInteraction: bankingPolicyInteraction,
                    financialAttractorPressure: financialAttractorPressure,
                    directionalFinancialForce: directionalFinancialForce,
                    inflationPressure: inflationPressure,
                    taxationPressure: taxationPressure,
                    economicGrowthPressure: economicGrowthPressure,
                    stockGrowthPressure: stockGrowthPressure,
                    stockSlowdownPressure: stockSlowdownPressure,
                    bondPressure: bondPressure,
                    volumePressure: volumePressure,
                    cyclePressure: cyclePressure,
                    shockPressure: shockPressure,
                    moneyEnergyChange: moneyEnergyChange
                )

                continue
            }

            // ----------------------------------------------------
            // Neighbor averages
            // ----------------------------------------------------

            let neighborCells = neighbors.map {
                currentCells[$0]
            }

            let neighborExhaustion =
                MarketExhaustionEngine.mean(
                    neighborCells.map(\.exhaustion)
                )

            let neighborStress =
                MarketExhaustionEngine.mean(
                    neighborCells.map(\.stress)
                )

            let neighborEnergy =
                MarketExhaustionEngine.mean(
                    neighborCells.map(\.energy)
                )

            let neighborMomentum =
                MarketExhaustionEngine.mean(
                    neighborCells.map(\.momentum)
                )

            // ----------------------------------------------------
            // Neighbor contagion
            //
            // Exhausted neighbors, stressed neighbors, and
            // depleted neighbors increase susceptibility.
            //
            // The financial attractor is intentionally NOT simply
            // added here. Instead, it modulates the propagation
            // of existing instability.
            // ----------------------------------------------------

            let baseContagion = clamp(
                0.50 * neighborExhaustion
                +
                0.30 * neighborStress
                +
                0.20 * clamp(
                    1.0 - neighborEnergy
                )
            )

            // ----------------------------------------------------
            // Financially amplified contagion
            //
            // Existing local instability is amplified when the
            // banking/policy system is already near the attractor.
            //
            // This gives the CA spatial propagation rather than
            // making banking stress an independent global crash
            // switch.
            // ----------------------------------------------------

            let financialContagionAmplifier = clamp(
                baseContagion *
                (
                    0.50
                    +
                    0.50 * financialAttractorPressure
                )
            )

            let contagion = clamp(
                baseContagion
                +
                financialContagionAmplifier *
                bankingCreditStressPressure
            )

            // ----------------------------------------------------
            // Calculate the new state from ONLY the previous
            // generation.
            // ----------------------------------------------------

            nextCells[index] = step(
                current: current,
                contagion: contagion,
                neighborStress: neighborStress,
                neighborEnergy: neighborEnergy,
                neighborMomentum: neighborMomentum,
                moneyPressure: moneyPressure,
                moneyPolicyChangePressure: moneyPolicyChangePressure,
                policyDirectionalForce: policyDirectionalForce,
                bankingCreditStressPressure: bankingCreditStressPressure,
                bankingPolicyInteraction: bankingPolicyInteraction,
                financialAttractorPressure: financialAttractorPressure,
                directionalFinancialForce: directionalFinancialForce,
                inflationPressure: inflationPressure,
                taxationPressure: taxationPressure,
                economicGrowthPressure: economicGrowthPressure,
                stockGrowthPressure: stockGrowthPressure,
                stockSlowdownPressure: stockSlowdownPressure,
                bondPressure: bondPressure,
                volumePressure: volumePressure,
                cyclePressure: cyclePressure,
                shockPressure: shockPressure,
                moneyEnergyChange: moneyEnergyChange
            )
        }

        // --------------------------------------------------------
        // Commit the complete generation at once.
        // --------------------------------------------------------

        cells = nextCells

        // --------------------------------------------------------
        // Preserve this year's complete state.
        // --------------------------------------------------------

        return makeHistoricalFrame(
            input: input,
            isCrashYear: isCrashYear,
            moneyEnergyChange: moneyEnergyChange,
            volumePressure: volumePressure
        )
    }


    // ============================================================
    // MARK: Make Historical Frame
    // ============================================================

    private func makeHistoricalFrame(
        input: HistoricalCAInput,
        isCrashYear: Bool,
        moneyEnergyChange: Double,
        volumePressure: Double
    ) -> HistoricalCAFrame {

        HistoricalCAFrame(
            year: input.year,
            isCrashYear: isCrashYear,
            moneyEnergyChange: moneyEnergyChange,
            volumePressure: volumePressure,
            cells: cells
        )
    }


    // ============================================================
    // MARK: Historical Sequence
    // ============================================================

    @discardableResult
    func analyzeHistoricalSequence(
        priorYears: [HistoricalCAInput],
        crashYear: HistoricalCAInput
    ) -> MarketSimulationResult {

        // --------------------------------------------------------
        // Start completely fresh.
        // --------------------------------------------------------

        reset()

        // --------------------------------------------------------
        // FIRST PRIOR YEAR:
        //
        // Every cell begins at neutral energy = 0.50.
        //
        // This happens ONCE.
        // --------------------------------------------------------

        initializeHistoricalGrid(
            initialEnergy: 0.50
        )

        // --------------------------------------------------------
        // Sort and restrict prior years.
        // --------------------------------------------------------

        let orderedPriorYears =
            priorYears
                .filter {
                    $0.year < crashYear.year
                }
                .sorted {
                    $0.year < $1.year
                }

        // --------------------------------------------------------
        // Historical accumulation
        //
        // Each year starts from the cells produced by the
        // previous year.
        // --------------------------------------------------------

        for historicalYear in orderedPriorYears {

            let frame = runHistoricalYear(
                historicalYear,
                isCrashYear: false
            )

            historicalFrames.append(frame)
        }

        // --------------------------------------------------------
        // Crash-year volume enters AFTER the historical
        // sequence has accumulated.
        //
        // It modifies the existing energy rather than
        // replacing the historical state.
        // --------------------------------------------------------

        let crashVolumePressure = normalize(
            crashYear.growthVolumePercent,
            min: -50,
            max: 300
        )

        applyCrashYearVolume(
            crashVolumePressure
        )

        // --------------------------------------------------------
        // Now evolve the crash year itself.
        // --------------------------------------------------------

        let crashFrame = runHistoricalYear(
            crashYear,
            isCrashYear: true
        )

        historicalFrames.append(crashFrame)

        // --------------------------------------------------------
        // Final crash-year statistics
        // --------------------------------------------------------

        let finalCells = cells

        let finalMeanEnergy =
            MarketExhaustionEngine.mean(
                finalCells.map(\.energy)
            )

        let finalMeanMomentum =
            MarketExhaustionEngine.mean(
                finalCells.map(\.momentum)
            )

        let finalMeanExhaustion =
            MarketExhaustionEngine.mean(
                finalCells.map(\.exhaustion)
            )

        let finalMeanStress =
            MarketExhaustionEngine.mean(
                finalCells.map(\.stress)
            )

        let criticalFraction =
            fraction(
                finalCells
            ) {
                $0.state == .critical
            }

        let releaseFraction =
            fraction(
                finalCells
            ) {
                $0.state == .crash
            }

        // --------------------------------------------------------
        // Final normalized input pressures
        // --------------------------------------------------------

        let moneyPressure = normalize(
            crashYear.growthM2,
            min: -5,
            max: 20
        )

        let bankingCreditStressPressure = normalize(
            crashYear.bankingCreditStressRating,
            min: 0,
            max: 5
        )

        let moneyPolicyDirection = clamp(
            normalize(
                crashYear.moneyPolicyChangeImpact,
                min: -6,
                max: 6
            )
        )

        let moneyPolicyChangePressure = abs(
            moneyPolicyDirection
        )

        let bankingPolicyInteraction = clamp(
            bankingCreditStressPressure *
            moneyPolicyChangePressure
        )

        let financialAttractorPressure = clamp(
            0.50 * bankingCreditStressPressure
            +
            0.20 * bankingPolicyInteraction
            +
            0.30 * abs(moneyPolicyDirection)
        )

        let directionalFinancialForce = clamp(
            moneyPolicyDirection *
            (
                0.50
                +
                0.50 * bankingCreditStressPressure
            )
        )

        let inflationPressure = normalize(
            crashYear.inflationPercent,
            min: -5,
            max: 15
        )

        let excessTaxGrowth =
            crashYear.taxGrowthPercent -
            crashYear.economicGrowthPercent

        let taxationPressure = normalize(
            excessTaxGrowth,
            min: -5,
            max: 15
        )

        let economicGrowthPressure = normalize(
            crashYear.economicGrowthPercent,
            min: -10,
            max: 15
        )

        let stockGrowthPressure = normalize(
            crashYear.stockGrowthPercent,
            min: -50,
            max: 100
        )

        let momentumChange =
            crashYear.stockGrowthPercent -
            crashYear.previousStockGrowthPercent

        let stockSlowdownPressure = normalize(
            -momentumChange,
            min: 0,
            max: 30
        )

        let bondPressure = normalize(
            crashYear.bondYieldAvgPercent,
            min: 0,
            max: 15
        )

        let volumePressure = normalize(
            crashYear.growthVolumePercent,
            min: -50,
            max: 300
        )

        let cyclePressure = normalize(
            crashYear.crashInterval,
            min: 0,
            max: 25
        )

        let shockPressure = normalize(
            crashYear.externalShockPercent,
            min: 0,
            max: 100
        )

        // --------------------------------------------------------
        // Aggregate equilibrium
        //
        // Banking stress is included as a structural financial
        // condition.
        //
        // Policy is NOT treated as ordinary crash pressure.
        // Its directional effect enters momentumDrive.
        // --------------------------------------------------------

        let equilibriumPressure = clamp(
            0.30 * stockSlowdownPressure
            +
            0.15 * inflationPressure
            +
            0.10 * taxationPressure
            +
            0.10 * bondPressure
            +
            0.05 * volumePressure
            +
            0.05 * cyclePressure
            +
            0.10 * finalMeanStress
            +
            0.15 * bankingCreditStressPressure
        )

        // --------------------------------------------------------
        // Momentum / trajectory drive
        //
        // Monetary policy changes direction here.
        //
        // Expansionary and contractionary policy therefore do
        // NOT have identical effects.
        // --------------------------------------------------------

        let momentumDrive = clamp(
            0.20 * moneyPressure
            +
            0.20 * stockGrowthPressure
            +
            0.10 * economicGrowthPressure
            +
            0.10 * volumePressure
            +
            0.10 * finalMeanMomentum
            +
            0.15 * directionalFinancialForce
            +
            0.15 * financialAttractorPressure
        )

        let equilibriumInflection = clamp(
            equilibriumPressure -
            momentumDrive
        )

        // --------------------------------------------------------
        // Systemic risk
        //
        // Banking stress is included directly because it
        // represents financial fragility.
        //
        // The attractor also contributes because simultaneous
        // financial stress and strong policy intervention can
        // destabilize the trajectory.
        // --------------------------------------------------------

        let systemicRisk = clamp(
            0.15 * finalMeanExhaustion
            +
            0.15 * finalMeanStress
            +
            0.15 * criticalFraction
            +
            0.10 * releaseFraction
            +
            0.10 * clamp(
                1.0 - finalMeanEnergy
            )
            +
            0.10 * stockSlowdownPressure
            +
            0.05 * inflationPressure
            +
            0.05 * shockPressure
            +
            0.10 * bankingCreditStressPressure
            +
            0.05 * bankingPolicyInteraction
        )

        // --------------------------------------------------------
        // Useful fuel / overdrive
        // --------------------------------------------------------

        let usefulFuel = clamp(
            finalMeanEnergy *
            (1.0 - finalMeanExhaustion)
        )

        let overdrivePressure = clamp(
            finalMeanEnergy *
            finalMeanMomentum *
            (
                finalMeanExhaustion +
                finalMeanStress
            )
        )

        // --------------------------------------------------------
        // Return result
        // --------------------------------------------------------

        return MarketSimulationResult(
            year: crashYear.year,
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
            meanEnergy: finalMeanEnergy,
            meanMomentum: finalMeanMomentum,
            meanExhaustion: finalMeanExhaustion,
            meanStress: finalMeanStress,
            criticalFraction: criticalFraction,
            releaseFraction: releaseFraction,
            usefulFuel: usefulFuel,
            overdrivePressure: overdrivePressure,
            equilibriumPressure: equilibriumPressure,
            equilibriumInflection: equilibriumInflection,
            systemicRisk: systemicRisk,
            cells: finalCells
        )
    }


   
    // ========================================================
    // MARK: Single-Year Compatibility
    // ========================================================

    @discardableResult
    func analyze(
        year: Int,
        growthM2: Double,
        moneyPolicyChangeImpact: Double,
        bankingCreditStressRating: Double,
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
            moneyPolicyChangeImpact: moneyPolicyChangeImpact,
            bankingCreditStressRating: bankingCreditStressRating,
            inflationPercent: inflationPercent,
            taxGrowthPercent: taxGrowthPercent,
            economicGrowthPercent: economicGrowthPercent,
            stockGrowthPercent: stockGrowthPercent,
            previousStockGrowthPercent: previousStockGrowthPercent,
            bondYieldAvgPercent: bondYieldAvgPercent,
            growthVolumePercent: growthVolumePercent,
            crashInterval: crashInterval,
            externalShockPercent: externalShockPercent
        )

        return analyzeHistoricalSequence(
            priorYears: [],
            crashYear: input
        )
    }

    // ========================================================
    // MARK: Mean
    // ========================================================

    static func mean(
        _ values: [Double]
    ) -> Double {

        guard !values.isEmpty else {
            return 0
        }

        let finiteValues =
            values.filter(\.isFinite)

        guard !finiteValues.isEmpty else {
            return 0
        }

        return finiteValues.reduce(
            0,
            +
        ) / Double(finiteValues.count)
    }

    // ========================================================
    // MARK: Fraction
    // ========================================================

    private func fraction(
        _ cells: [MarketCell],
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

