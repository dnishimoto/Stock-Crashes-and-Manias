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




// ============================================================
// MARK: - Market Exhaustion Engine
// ============================================================

final class MarketExhaustionEngine {

    // ========================================================
    // MARK: Grid
    // ========================================================

    let gridWidth: Int
    let gridHeight: Int

    private(set) var cells: [MarketCell] = []
    private(set) var historicalFrames: [HistoricalCAFrame] = []

    // ========================================================
    // MARK: State Thresholds
    // ========================================================

    private let risingThreshold = 0.20
    private let stressedThreshold = 0.40
    private let criticalStressThreshold = 0.65

    private let releaseStressThreshold = 0.85
    private let energyReleaseThreshold = 0.08

    // ========================================================
    // MARK: Cellular Dynamics
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

    private let inflationWeight = 0.15
    private let taxationWeight = 0.15
    private let stockSlowdownWeight = 0.20
    private let bankingCreditWeight = 0.40
    private let financialAttractorWeight = 0.10

    // ========================================================
    // MARK: Initialization
    // ========================================================

    init(
        gridWidth: Int = 20,
        gridHeight: Int = 20
    ) {
        self.gridWidth = max(1, gridWidth)
        self.gridHeight = max(1, gridHeight)

        reset()
    }

    // ========================================================
    // MARK: Reset
    // ========================================================

    func reset() {

        cells.removeAll(keepingCapacity: true)
        historicalFrames.removeAll(keepingCapacity: true)

        let count = gridWidth * gridHeight

        cells = (0..<count).map { _ in
            MarketCell()
        }
    }

    // ========================================================
    // MARK: Initialize Historical Grid
    // ========================================================

    func initializeHistoricalGrid(
        initialEnergy: Double = 0.50
    ) {

        let energy = clamp(
            initialEnergy,
            min: 0.0,
            max: 1.0
        )

        cells = (0..<(gridWidth * gridHeight)).map { _ in

            MarketCell(
                energy: energy,
                momentum: 0.0,
                exhaustion: 0.0,
                stress: 0.0,
                financialPotential: 0.0,
                state: .stable
            )
        }
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
            return 0.0
        }

        return clamp(
            (value - lower) / (upper - lower),
            min: 0.0,
            max: 1.0
        )
    }

    // ========================================================
    // MARK: Signed Normalize
    // ========================================================

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
            return 0.0
        }

        let midpoint = (lower + upper) / 2.0
        let halfRange = (upper - lower) / 2.0

        guard halfRange > 0 else {
            return 0.0
        }

        return clamp(
            (value - midpoint) / halfRange,
            min: -1.0,
            max: 1.0
        )
    }

    // ========================================================
    // MARK: Clamp
    // ========================================================

    private func clamp(
        _ value: Double,
        min lower: Double = 0.0,
        max upper: Double = 1.0
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
    // MARK: Mean
    // ========================================================

    private func mean(
        _ values: [Double]
    ) -> Double {

        let finiteValues = values.filter {
            $0.isFinite
        }

        guard !finiteValues.isEmpty else {
            return 0.0
        }

        return finiteValues.reduce(
            0.0,
            +
        ) / Double(finiteValues.count)
    }

    // ========================================================
    // MARK: Neighbors
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
    ) -> MarketState {

        if energy <= energyReleaseThreshold
            || stress >= releaseStressThreshold {

            return .released
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
    // MARK: Money Supply Energy Change
    // ========================================================

    private func moneySupplyEnergyChange(
        from growthM2: Double
    ) -> Double {

        // ±20% M2 growth range maps to approximately ±1
        // financial-energy forcing.

        return normalizeSigned(
            growthM2,
            min: -20.0,
            max: 20.0
        )
    }

    // ========================================================
    // MARK: Crash-Year Volume Initialization
    // ========================================================

    private func applyCrashYearVolume(
        _ volumePressure: Double
    ) {

        let normalizedVolume = clamp(
            volumePressure
        )

        for index in cells.indices {

            let current = cells[index]

            // Crash-year volume establishes an initial
            // disturbance without completely replacing
            // the accumulated historical state.

            let newEnergy = clamp(
                0.50 * current.energy
                + 0.50 * (1.0 - normalizedVolume)
            )

            let newStress = clamp(
                current.stress
                + 0.20 * normalizedVolume
            )

            cells[index].energy = newEnergy
            cells[index].stress = newStress
        }
    }

    // ========================================================
    // MARK: Step
    // ========================================================

    func step(
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
    ) {

        // ----------------------------------------------------
        // Synchronous CA update
        // ----------------------------------------------------
        //
        // Every cell reads exclusively from currentCells.
        // No cell can see a partially updated neighbor.

        let currentCells = cells
        var nextCells = currentCells

        for index in currentCells.indices {

            let current = currentCells[index]

            let neighbors = neighborIndices(
                for: index
            )

            let neighborCells = neighbors.map {
                currentCells[$0]
            }

            let neighborEnergy = mean(
                neighborCells.map {
                    $0.energy
                }
            )

            let neighborMomentum = mean(
                neighborCells.map {
                    $0.momentum
                }
            )

            let neighborStress = mean(
                neighborCells.map {
                    $0.stress
                }
            )

            let neighborExhaustion = mean(
                neighborCells.map {
                    $0.exhaustion
                }
            )

            let neighborPotential = mean(
                neighborCells.map {
                    $0.financialPotential
                }
            )

            // ------------------------------------------------
            // Normalize incoming values
            // ------------------------------------------------

            let money = clamp(
                moneyPressure
            )

            let bankingStress = clamp(
                bankingCreditStressPressure
            )

            let policyMagnitude = clamp(
                moneyPolicyChangePressure
            )

            let policyDirection = clamp(
                policyDirectionalForce,
                min: -1.0,
                max: 1.0
            )

            let policyInteraction = clamp(
                bankingPolicyInteraction
            )

            let financialAttractor = clamp(
                financialAttractorPressure
            )

            let directionalFinancial = clamp(
                directionalFinancialForce,
                min: -1.0,
                max: 1.0
            )

            // ------------------------------------------------
            // Macro exhaustion inputs
            // ------------------------------------------------

            let inflationExhaustion = normalize(
                inflationPressure
                    * (1.0 + 0.60 * money),
                min: 0.0,
                max: 1.60
            )

            let taxationExhaustion = clamp(
                taxationPressure
            )

            let stockGrowthExhaustion = clamp(
                stockSlowdownPressure
            )

            let bankingCreditFragility = bankingStress

            // ------------------------------------------------
            // Existing local financial amplification
            // ------------------------------------------------

            let localFinancialAmplification = clamp(
                0.40 * current.stress
                + 0.30 * current.exhaustion
                + 0.20 * (1.0 - current.energy)
                + 0.10 * neighborStress
            )

            // ------------------------------------------------
            // Nonlinear financial attractor
            // ------------------------------------------------

            let nonlinearFinancialAttractor = clamp(
                financialAttractor
                * (
                    0.50
                    + 0.50 * localFinancialAmplification
                )
            )

            // ------------------------------------------------
            // Financial Gravity:
            // Effective Financial Mass
            // ------------------------------------------------
            //
            // Banking/credit fragility behaves like effective
            // financial mass. It increases sensitivity to
            // existing financial forces.

            let effectiveFinancialMass = clamp(
                bankingCreditFragility
            )

            // ------------------------------------------------
            // Financial Gravity:
            // Signed Path Force
            // ------------------------------------------------

            let effectivePolicyForce = clamp(
                policyDirection
                    * (
                        1.0
                        + 0.75 * effectiveFinancialMass
                    ),
                min: -1.0,
                max: 1.0
            )

            let effectiveDirectionalForce = clamp(
                directionalFinancial
                    * (
                        1.0
                        + 0.50 * effectiveFinancialMass
                    ),
                min: -1.0,
                max: 1.0
            )

            let financialPathForce = clamp(
                0.65 * effectivePolicyForce
                + 0.35 * effectiveDirectionalForce,
                min: -1.0,
                max: 1.0
            )

            // ------------------------------------------------
            // Historical pressure
            // ------------------------------------------------

            let historicalPressure = clamp(
                0.15 * money
                + 0.15 * inflationPressure
                + 0.10 * taxationPressure
                + 0.10 * economicGrowthPressure
                + 0.15 * stockGrowthPressure
                + 0.15 * stockSlowdownPressure
                + 0.05 * bondPressure
                + 0.05 * volumePressure
                + 0.05 * cyclePressure
                + 0.05 * shockPressure
            )

            // ------------------------------------------------
            // Internal exhaustion
            // ------------------------------------------------
            //
            // 15% inflation
            // 15% taxation
            // 20% stock slowdown
            // 40% banking/credit fragility
            // 10% nonlinear financial attractor

            let internalExhaustion = clamp(
                inflationWeight
                    * inflationExhaustion
                + taxationWeight
                    * taxationExhaustion
                + stockSlowdownWeight
                    * stockGrowthExhaustion
                + bankingCreditWeight
                    * bankingCreditFragility
                + financialAttractorWeight
                    * nonlinearFinancialAttractor
            )

            // ------------------------------------------------
            // Financial potential
            // ------------------------------------------------
            //
            // Potential represents accumulated resistance /
            // instability in the financial field.

            let baseContagionBeforePotential = clamp(
                0.20 * current.exhaustion
                + 0.12 * neighborStress
                + 0.15 * (1.0 - neighborEnergy)
            )

            let equilibriumPressure = clamp(
                0.30 * stockGrowthExhaustion
                + 0.15 * inflationExhaustion
                + 0.10 * taxationExhaustion
                + 0.10 * bondPressure
                + 0.05 * volumePressure
                + 0.05 * cyclePressure
                + 0.05 * neighborStress
                + 0.10 * bankingCreditFragility
                + 0.10 * nonlinearFinancialAttractor
            )

            // ------------------------------------------------
            // Base momentum drive
            // ------------------------------------------------

            let baseMomentumDrive =
                0.25 * money
                + 0.20 * stockGrowthPressure
                + 0.15 * economicGrowthPressure
                + 0.10 * volumePressure
                + 0.10 * current.momentum
                + 0.10 * neighborMomentum

            // ------------------------------------------------
            // Financial potential
            // ------------------------------------------------

            let financialPotential = clamp(
                0.40 * internalExhaustion
                + 0.20 * (1.0 - current.energy)
                + 0.15 * effectiveFinancialMass
                + 0.15 * clamp(
                    equilibriumPressure
                    - baseMomentumDrive
                )
                + 0.10 * baseContagionBeforePotential
            )

            // ------------------------------------------------
            // Potential gradient
            // ------------------------------------------------

            let potentialGradient = clamp(
                neighborPotential - financialPotential,
                min: -1.0,
                max: 1.0
            )

            // ------------------------------------------------
            // Equilibrium inflection
            // ------------------------------------------------
            //
            // Positive values indicate that pressure exceeds
            // the current financial trajectory.

            let preliminaryMomentumDrive = clamp(
                baseMomentumDrive
                + 0.10 * financialPathForce
                + 0.10 * potentialGradient,
                min: -1.0,
                max: 1.0
            )

            let equilibriumInflection = clamp(
                equilibriumPressure
                    - preliminaryMomentumDrive
            )

            // ------------------------------------------------
            // Contagion
            // ------------------------------------------------
            //
            // Banking fragility amplifies existing contagion.
            // It does not create contagion from zero.

            let exhaustionContagion = clamp(
                0.20 * current.exhaustion
            )

            let stressContagion = clamp(
                0.12 * neighborStress
            )

            let depletionContagion = clamp(
                0.15 * (1.0 - neighborEnergy)
            )

            let baseContagion = clamp(
                exhaustionContagion
                + stressContagion
                + depletionContagion
            )

            let financialContagionAmplifier = clamp(
                1.0
                + 0.50 * effectiveFinancialMass
                + 0.50 * policyInteraction
                + 0.50 * financialAttractor
                + 0.50 * abs(potentialGradient),
                min: 1.0,
                max: 3.0
            )

            let contagion = clamp(
                baseContagion
                    * financialContagionAmplifier
            )

            // ------------------------------------------------
            // Local exhaustion
            // ------------------------------------------------
            //
            // Internal exhaustion remains the dominant
            // contributor.
            //
            // Potential gradient is used as a field-instability
            // contribution rather than double-counting the
            // attractor.

            let contagionExhaustion = clamp(
                contagion
            )

            let intervalExhaustion = clamp(
                0.15 * cyclePressure
            )

            let localExhaustion = clamp(
                0.70 * internalExhaustion
                + 0.15 * contagionExhaustion
                + 0.05 * historicalPressure
                + 0.05 * intervalExhaustion
                + 0.03 * equilibriumInflection
                + 0.02 * abs(potentialGradient)
            )

            // ------------------------------------------------
            // Energy transfer
            // ------------------------------------------------

            let energyTransfer = clamp(
                energyTransferRate
                    * (neighborEnergy - current.energy),
                min: -energyTransferRate,
                max: energyTransferRate
            )

            // ------------------------------------------------
            // Monetary energy
            // ------------------------------------------------

            let monetaryEnergyBoost = clamp(
                moneyEnergyChange,
                min: -1.0,
                max: 1.0
            )

            // ------------------------------------------------
            // Financial force → energy
            // ------------------------------------------------
            //
            // Force acts on moving financial energy.
            // Banking fragility increases sensitivity.

            let financialEnergyEffect = clamp(
                0.06
                    * financialPathForce
                    * current.momentum
                    * (
                        0.50
                        + 0.50 * effectiveFinancialMass
                    ),
                min: -0.06,
                max: 0.06
            )

            // ------------------------------------------------
            // Dissipation
            // ------------------------------------------------

            let dissipation = clamp(
                0.06
                + 0.10 * localExhaustion
                + 0.08 * financialPotential
                + 0.08 * historicalPressure
                + 0.05 * contagionExhaustion
                + 0.03 * nonlinearFinancialAttractor,
                min: 0.0,
                max: 0.40
            )

            // ------------------------------------------------
            // Next energy
            // ------------------------------------------------

            let nextEnergy = clamp(
                current.energy
                + monetaryEnergyBoost
                + energyTransfer
                + financialEnergyEffect
                - dissipation
            )

            let energyDepletion = clamp(
                1.0 - nextEnergy
            )

            // ------------------------------------------------
            // Total exhaustion
            // ------------------------------------------------

            let totalExhaustion = clamp(
                0.70 * localExhaustion
                + 0.10 * energyDepletion
                + 0.10 * contagionExhaustion
                + 0.05 * equilibriumInflection
                + 0.03 * shockPressure
                + 0.02 * financialPotential
            )

            // ------------------------------------------------
            // Stress
            // ------------------------------------------------

            let financialStressResponse = clamp(
                effectiveFinancialMass
                    * (
                        0.50
                        + 0.50
                            * nonlinearFinancialAttractor
                    )
            )

            let nextStress = clamp(
                0.30 * totalExhaustion
                + 0.20 * contagionExhaustion
                + 0.15 * equilibriumInflection
                + 0.15 * energyDepletion
                + 0.05 * bondPressure
                + 0.05 * shockPressure
                + 0.10 * financialStressResponse
            )

            // ------------------------------------------------
            // Momentum
            // ------------------------------------------------

            let momentumDrive = clamp(
                baseMomentumDrive
                + 0.10 * financialPathForce
                + 0.10 * potentialGradient,
                min: -1.0,
                max: 1.0
            )

            let monetaryMomentumEffect =
                0.08 * monetaryEnergyBoost

            let financialMomentumEffect =
                0.10 * financialPathForce

            let momentumGain =
                0.12 * momentumDrive
                + monetaryMomentumEffect
                + financialMomentumEffect

            let momentumLoss =
                0.10 * totalExhaustion
                + 0.08 * equilibriumInflection
                + 0.05 * energyDepletion
                + 0.07 * financialPotential

            let neighborMomentumEffect =
                momentumContagionRate
                    * (neighborMomentum - current.momentum)

            let financialMomentumFeedback = clamp(
                financialPathForce
                    * effectiveFinancialMass
                    * (
                        0.05
                        + 0.05 * current.stress
                        + 0.05 * contagionExhaustion
                    ),
                min: -0.15,
                max: 0.15
            )

            let nextMomentum = clamp(
                current.momentum
                + momentumGain
                - momentumLoss
                + neighborMomentumEffect
                + financialMomentumFeedback,
                min: -1.0,
                max: 1.0
            )

            // ------------------------------------------------
            // Next state
            // ------------------------------------------------

            let nextState = stateFor(
                energy: nextEnergy,
                stress: nextStress
            )

            // ------------------------------------------------
            // Store next cell
            // ------------------------------------------------

            nextCells[index].energy = nextEnergy
            nextCells[index].momentum = nextMomentum
            nextCells[index].exhaustion = totalExhaustion
            nextCells[index].stress = nextStress
            nextCells[index].financialPotential =
                financialPotential
            nextCells[index].state = nextState
        }

        // ----------------------------------------------------
        // Commit simultaneously
        // ----------------------------------------------------

        cells = nextCells
    }

    // ========================================================
    // MARK: Historical Year
    // ========================================================

    func runHistoricalYear(
        input: HistoricalCAInput,
        isCrashYear: Bool = false
    ) {

        let moneyPressure = normalize(
            input.growthM2,
            min: -5.0,
            max: 20.0
        )

        let bankingCreditStressPressure = normalize(
            input.bankingCreditStressRating,
            min: 0.0,
            max: 5.0
        )

        let moneyPolicyDirection = normalizeSigned(
            input.moneyPolicyChangeImpact,
            min: -6.0,
            max: 6.0
        )

        let moneyPolicyChangePressure =
            abs(moneyPolicyDirection)

        let bankingPolicyInteraction = clamp(
            bankingCreditStressPressure
                * moneyPolicyChangePressure
        )

        let policyDirectionalForce = clamp(
            moneyPolicyDirection,
            min: -1.0,
            max: 1.0
        )

        let financialAttractorPressure = clamp(
            0.25 * bankingCreditStressPressure
            + 0.60 * bankingPolicyInteraction
            + 0.15 * moneyPolicyChangePressure
        )

        let directionalFinancialForce = clamp(
            policyDirectionalForce
                * (
                    0.50
                    + 0.50 * bankingCreditStressPressure
                ),
            min: -1.0,
            max: 1.0
        )

        let inflationPressure = normalize(
            input.inflationPercent,
            min: -5.0,
            max: 15.0
        )

        let taxationPressure = normalize(
            input.taxGrowthPercent
                - input.economicGrowthPercent,
            min: -5.0,
            max: 15.0
        )

        let economicGrowthPressure = normalize(
            input.economicGrowthPercent,
            min: -10.0,
            max: 15.0
        )

        let stockGrowthPressure = normalize(
            input.stockGrowthPercent,
            min: -50.0,
            max: 100.0
        )

        let stockSlowdownPressure = normalize(
            -(
                input.stockGrowthPercent
                - input.previousStockGrowthPercent
            ),
            min: 0.0,
            max: 30.0
        )

        let bondPressure = normalize(
            input.growthBondPercent,
            min: 0.0,
            max: 15.0
        )

        let volumePressure = normalize(
            input.growthVolumePercent,
            min: -50.0,
            max: 300.0
        )

        let cyclePressure = normalize(
            input.cyclePressurePercent,
            min: 0.0,
            max: 25.0
        )

        let shockPressure = normalize(
            input.shockPressurePercent,
            min: 0.0,
            max: 100.0
        )

        let moneyEnergyChange =
            moneySupplyEnergyChange(
                from: input.growthM2
            )

        step(
            moneyPressure: moneyPressure,
            moneyPolicyChangePressure:
                moneyPolicyChangePressure,
            policyDirectionalForce:
                policyDirectionalForce,
            bankingCreditStressPressure:
                bankingCreditStressPressure,
            bankingPolicyInteraction:
                bankingPolicyInteraction,
            financialAttractorPressure:
                financialAttractorPressure,
            directionalFinancialForce:
                directionalFinancialForce,
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
            moneyEnergyChange:
                moneyEnergyChange
        )

        historicalFrames.append(
            makeHistoricalFrame(
                year: input.year,
                isCrashYear: isCrashYear,
                moneyEnergyChange:
                    moneyEnergyChange,
                volumePressure:
                    volumePressure
            )
        )
    }

    // ========================================================
    // MARK: Historical Frame
    // ========================================================

    private func makeHistoricalFrame(
        year: Int,
        isCrashYear: Bool,
        moneyEnergyChange: Double,
        volumePressure: Double
    ) -> HistoricalCAFrame {

        HistoricalCAFrame(
            year: year,
            isCrashYear: isCrashYear,
            moneyEnergyChange: moneyEnergyChange,
            volumePressure: volumePressure,
            cells: cells
        )
    }

    // ========================================================
    // MARK: Analyze Historical Sequence
    // ========================================================

    func analyzeHistoricalSequence(
        priorYears: [HistoricalCAInput],
        crashYear: HistoricalCAInput
    ) -> HistoricalCAResult {

        reset()

        initializeHistoricalGrid(
            initialEnergy: 0.50
        )

        historicalFrames.removeAll(
            keepingCapacity: true
        )

        let sortedPriorYears = priorYears
            .filter {
                $0.year < crashYear.year
            }
            .sorted {
                $0.year < $1.year
            }

        // ----------------------------------------------------
        // Accumulate historical conditions.
        // ----------------------------------------------------

        for year in sortedPriorYears {

            runHistoricalYear(
                input: year,
                isCrashYear: false
            )
        }

        // ----------------------------------------------------
        // Crash-year volume initialization.
        // ----------------------------------------------------
        //
        // Volume establishes an initial crash-year disturbance.
        // The crash-year itself is then processed normally.

        let crashVolumePressure = normalize(
            crashYear.growthVolumePercent,
            min: -50.0,
            max: 300.0
        )

        applyCrashYearVolume(
            crashVolumePressure
        )

        runHistoricalYear(
            input: crashYear,
            isCrashYear: true
        )

        // ----------------------------------------------------
        // Aggregate final CA state.
        // ----------------------------------------------------

        let finalMeanEnergy = mean(
            cells.map {
                $0.energy
            }
        )

        let finalMeanMomentum = mean(
            cells.map {
                $0.momentum
            }
        )

        let finalMeanExhaustion = mean(
            cells.map {
                $0.exhaustion
            }
        )

        let finalMeanStress = mean(
            cells.map {
                $0.stress
            }
        )

        let finalMeanFinancialPotential = mean(
            cells.map {
                $0.financialPotential
            }
        )

        let criticalFraction = fraction(
            of: cells
        ) {
            $0.state == .critical
        }

        let releaseFraction = fraction(
            of: cells
        ) {
            $0.state == .released
        }

        let energyDepletion = clamp(
            1.0 - finalMeanEnergy
        )

        // ----------------------------------------------------
        // Crash-year normalized inputs
        // ----------------------------------------------------

        let inflationPressure = normalize(
            crashYear.inflationPercent,
            min: -5.0,
            max: 15.0
        )

        let stockSlowdown = normalize(
            -(
                crashYear.stockGrowthPercent
                - crashYear.previousStockGrowthPercent
            ),
            min: 0.0,
            max: 30.0
        )

        let shockPressure = normalize(
            crashYear.shockPressurePercent,
            min: 0.0,
            max: 100.0
        )

        let bankingStress = normalize(
            crashYear.bankingCreditStressRating,
            min: 0.0,
            max: 5.0
        )

        // ----------------------------------------------------
        // Policy direction
        // ----------------------------------------------------

        let moneyPolicyDirection = normalizeSigned(
            crashYear.moneyPolicyChangeImpact,
            min: -6.0,
            max: 6.0
        )

        let moneyPolicyChangePressure =
            abs(moneyPolicyDirection)

        let bankingPolicyInteraction = clamp(
            bankingStress
                * moneyPolicyChangePressure
        )

        let policyDirectionalForce = clamp(
            moneyPolicyDirection,
            min: -1.0,
            max: 1.0
        )

        let financialAttractorPressure = clamp(
            0.25 * bankingStress
            + 0.60 * bankingPolicyInteraction
            + 0.15 * moneyPolicyChangePressure
        )

        let directionalFinancialForce = clamp(
            policyDirectionalForce
                * (
                    0.50
                    + 0.50 * bankingStress
                ),
            min: -1.0,
            max: 1.0
        )

        // ----------------------------------------------------
        // Equilibrium
        // ----------------------------------------------------

        let bondPressure = normalize(
            crashYear.growthBondPercent,
            min: 0.0,
            max: 15.0
        )

        let volumePressure = normalize(
            crashYear.growthVolumePercent,
            min: -50.0,
            max: 300.0
        )

        let cyclePressure = normalize(
            crashYear.cyclePressurePercent,
            min: 0.0,
            max: 25.0
        )

        let taxationPressure = normalize(
            crashYear.taxGrowthPercent
                - crashYear.economicGrowthPercent,
            min: -5.0,
            max: 15.0
        )

        let equilibriumPressure = clamp(
            0.30 * stockSlowdown
            + 0.15 * inflationPressure
            + 0.10 * taxationPressure
            + 0.10 * bondPressure
            + 0.05 * volumePressure
            + 0.05 * cyclePressure
            + 0.10 * finalMeanStress
            + 0.10 * bankingStress
            + 0.05 * financialAttractorPressure
        )

        let aggregateMomentumDrive = clamp(
            0.20 * normalize(
                crashYear.growthM2,
                min: -5.0,
                max: 20.0
            )
            + 0.20 * normalize(
                crashYear.stockGrowthPercent,
                min: -50.0,
                max: 100.0
            )
            + 0.10 * normalize(
                crashYear.economicGrowthPercent,
                min: -10.0,
                max: 15.0
            )
            + 0.10 * volumePressure
            + 0.10 * finalMeanMomentum
            + 0.15 * directionalFinancialForce
            + 0.15 * financialAttractorPressure
        )

        let equilibriumInflection = clamp(
            equilibriumPressure
                - aggregateMomentumDrive
        )

        // ----------------------------------------------------
        // Useful fuel
        // ----------------------------------------------------

        let usefulFuel = clamp(
            finalMeanEnergy
                * (1.0 - finalMeanExhaustion)
        )

        // ----------------------------------------------------
        // Overdrive pressure
        // ----------------------------------------------------

        let overdrivePressure = clamp(
            finalMeanEnergy
                * finalMeanMomentum
                * (
                    finalMeanExhaustion
                    + finalMeanStress
                ),
            min: -1.0,
            max: 1.0
        )

        // ----------------------------------------------------
        // Emergent systemic risk
        // ----------------------------------------------------
        //
        // The final systemic-risk score is deliberately based
        // primarily on the state produced by the CA.
        //
        // Raw macro variables affect the CA upstream.
        // They are not repeatedly counted here.
        //
        // 25% exhaustion
        // 20% stress
        // 20% critical cells
        // 15% released cells
        // 10% energy depletion
        // 10% financial potential
        //
        // Total = 100%.

        let systemicRisk = clamp(
            0.25 * finalMeanExhaustion
            + 0.20 * finalMeanStress
            + 0.20 * criticalFraction
            + 0.15 * releaseFraction
            + 0.10 * energyDepletion
            + 0.10 * finalMeanFinancialPotential
        )

        // ----------------------------------------------------
        // Financial-gravity / cellular-automaton detail
        // ----------------------------------------------------

        let potentialGradient =
            aggregatePotentialGradient()

        // "Local" exhaustion surfaces the worst single cell,
        // as distinct from the grid-wide mean.

        let localExhaustion = cells
            .map { $0.exhaustion }
            .max() ?? finalMeanExhaustion

        // "Total" exhaustion is a system-wide composite that
        // also weighs how far exhaustion has already spread
        // into critical/release cells, rather than a plain
        // average.

        let totalExhaustion = clamp(
            0.60 * finalMeanExhaustion
            + 0.25 * criticalFraction
            + 0.15 * releaseFraction
        )

        // Effective financial mass mirrors the per-cell
        // definition used during step(): banking/credit
        // fragility behaves like mass.

        let effectiveFinancialMass = bankingStress

        // Aggregate nonlinear financial attractor, following
        // the same shape as the per-cell version but driven by
        // the grid-wide financial potential.

        let nonlinearFinancialAttractor = clamp(
            financialAttractorPressure
                * (
                    0.50
                    + 0.50 * finalMeanFinancialPotential
                )
        )

        let contagion = clamp(
            0.50 * finalMeanExhaustion
            + 0.30 * finalMeanStress
            + 0.20 * potentialGradient
        )

        return HistoricalCAResult(
            crashYear: crashYear.year,

            meanEnergy: finalMeanEnergy,
            meanMomentum: finalMeanMomentum,
            meanExhaustion: finalMeanExhaustion,
            meanStress: finalMeanStress,
            meanFinancialPotential:
                finalMeanFinancialPotential,

            criticalFraction: criticalFraction,
            releaseFraction: releaseFraction,

            energyDepletion: energyDepletion,
            stockSlowdown: stockSlowdown,
            inflationPressure: inflationPressure,
            shockPressure: shockPressure,

            bankingStress: bankingStress,
            bankingPolicyInteraction:
                bankingPolicyInteraction,

            equilibriumPressure: equilibriumPressure,
            equilibriumInflection:
                equilibriumInflection,

            usefulFuel: usefulFuel,
            overdrivePressure: overdrivePressure,
            systemicRisk: systemicRisk,

            finalEnergy: finalMeanEnergy,
            finalMomentum: finalMeanMomentum,

            financialPotential: finalMeanFinancialPotential,
            potentialGradient: potentialGradient,

            localExhaustion: localExhaustion,
            totalExhaustion: totalExhaustion,

            effectiveFinancialMass: effectiveFinancialMass,
            financialPathForce: directionalFinancialForce,

            contagion: contagion,
            nonlinearFinancialAttractor:
                nonlinearFinancialAttractor,

            cells: cells
        )
    }

    // ========================================================
    // MARK: Single-Year Compatibility API
    // ========================================================

    func analyze(
        input: HistoricalCAInput
    ) -> HistoricalCAResult {

        analyzeHistoricalSequence(
            priorYears: [],
            crashYear: input
        )
    }

    // ========================================================
    // MARK: Aggregate Potential Gradient
    // ========================================================
    //
    // Averages, across the final grid, the magnitude of each
    // cell's financial-potential difference from its
    // neighborhood mean. This is the aggregate analogue of the
    // per-cell `potentialGradient` computed during step().

    private func aggregatePotentialGradient() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let gradients = cells.indices.map { index -> Double in

            let neighborPotential = mean(
                neighborIndices(for: index).map {
                    cells[$0].financialPotential
                }
            )

            return abs(
                neighborPotential
                    - cells[index].financialPotential
            )
        }

        return clamp(
            mean(gradients)
        )
    }

    // ========================================================
    // MARK: Fraction
    // ========================================================

    private func fraction(
        of cells: [MarketCell],
        where predicate: (MarketCell) -> Bool
    ) -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let count = cells.reduce(
            0
        ) { partialResult, cell in

            partialResult
                + (predicate(cell) ? 1 : 0)
        }

        return Double(count)
            / Double(cells.count)
    }
}
