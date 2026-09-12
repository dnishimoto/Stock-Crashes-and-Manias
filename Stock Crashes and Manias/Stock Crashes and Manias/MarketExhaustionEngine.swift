/*
 
 The cellular automaton works because it treats a market as an evolving system rather than as a collection of independent numbers. The simulation begins with the historical years leading up to a crash, and each year changes the condition of the cells so the market carries a memory of what happened before instead of starting from the same state every time. Money-supply changes can add or remove financial energy and momentum, while inflation, taxation, stock-market slowdown, banking weakness, bond pressure, policy changes, trading volume, economic conditions, and external shocks create different forms of pressure or instability. These conditions are not simply added together at the end; they change the cells, and those changed cells become the starting point for the next year. When the crash year arrives, its trading volume creates an additional disturbance to the historically developed system rather than erasing its history. The cells then interact with their neighbors, allowing energy, momentum, stress, exhaustion, and financial potential to influence nearby regions. This is important because financial problems can spread: a stressed or exhausted area can make neighboring areas more vulnerable, creating contagion that can gradually move through the system. At the same time, energy is consumed through dissipation, while financial pressure, exhaustion, contagion, and depletion can increase stress. The model separates energy from exhaustion, because a market can have plenty of activity and financial energy while simultaneously becoming increasingly strained underneath. As energy is consumed, depletion rises, which can increase exhaustion and stress and create a feedback loop in which instability produces conditions that generate even more instability. Financial potential adds another layer by representing accumulated local vulnerability, while differences in potential between neighboring cells create gradients that can influence momentum and contagion. Every generation is calculated synchronously, meaning every cell looks at the same previous state before all cells advance together, preventing the order of calculation from artificially affecting the result. Eventually, some cells may become critical because stress becomes very high, while others may reach the crash or release condition because their remaining energy becomes extremely low. In this way, the model does not simply declare that a crash happens because one economic variable reached a predetermined value; instead, the crash emerges from the interaction of historical conditions, monetary changes, economic pressure, financial fragility, energy consumption, exhaustion, stress, neighboring relationships, contagion, and feedback. In simple terms, the model works like a forest that has been getting progressively drier for years: the historical economy determines how dry the forest becomes, financial conditions determine where it is vulnerable, neighboring cells allow the disturbance to spread, and energy depletion determines how much capacity remains to resist the disturbance. The value of the cellular automaton is therefore its ability to represent how a financial system can gradually build hidden vulnerability and then experience a nonlinear transition from stability to widespread instability as its internal conditions interact.


 The cellular automaton begins by processing the historical years leading up to a market crash in chronological order. Each prior year contributes its economic conditions to the evolving cellular system, allowing the market to enter the crash period with a history rather than starting every simulation from the same state. Money-supply changes provide one of the principal energy inputs to the system: positive monetary growth can increase available financial energy and momentum, while negative monetary changes reduce the energy available to the cellular system. These yearly conditions are not simply added together as a final score. Instead, each year's forcing changes the cellular state, and that altered state becomes the starting condition for the following year. Historical memory is therefore carried through the evolving energy, momentum, exhaustion, stress, financial potential, and neighboring relationships of the cells.

 After the historical buildup has been processed, the crash year's trading volume establishes the initial crash-year disturbance. The crash-year volume is normalized and applied to the historically evolved cellular state rather than replacing that history. Higher crash-year volume creates a stronger disturbance and reduces the available energy associated with the crash-year initialization, while the historically accumulated state remains present. The crash-year volume therefore acts as the bridge between the preceding historical buildup and the crash-year cellular evolution. The other crash-year economic variables are subsequently applied through the normal cellular dynamics, allowing inflation, taxation, economic growth, stock growth, stock-growth slowdown, bond yields, trading volume, crash-cycle pressure, banking and credit conditions, monetary policy changes, financial-attractor effects, and external shocks to influence the already initialized system.

 Once the crash-year cellular condition has been established, the economic inputs are converted into normalized forcing variables. These variables represent different forms of monetary energy, economic pressure, market momentum, financial fragility, equilibrium imbalance, and external disturbance. Positive economic and monetary conditions can provide momentum or energy to the system, while adverse conditions can increase pressure, exhaustion, and energy consumption. Economic growth and stock growth can contribute to market momentum and activity, while stock-growth slowdown, inflation, taxation pressure, banking and credit fragility, bond pressure, and other adverse conditions can contribute to financial exhaustion. This distinction allows the model to represent a market that can simultaneously possess substantial energy and momentum while also accumulating increasing internal pressure.

 Each cell then interacts with the surrounding cells in the grid. The cellular neighborhood provides a local representation of market interconnectedness. A cell can be influenced by the energy, momentum, stress, exhaustion, and financial potential of its neighbors. Energy moves between neighboring cells when differences in available energy exist, allowing financial activity to propagate spatially through the grid. Momentum can likewise be influenced by neighboring momentum, allowing locally strong or weak market movement to affect surrounding cells. Because every cell reads from the same previous generation, these interactions are calculated synchronously rather than allowing one cell's newly calculated state to immediately alter another cell during the same generation.

 Contagion emerges from these neighboring interactions. A cell becomes increasingly susceptible to instability when its own exhaustion is elevated, when surrounding cells exhibit greater stress, or when neighboring energy becomes depleted. Banking and financial conditions can amplify contagion that already exists, but the cellular contagion mechanism is not intended to create instability from nothing. Instead, an existing disturbance can become amplified as it encounters increasingly stressed or depleted neighboring regions. In this way, a localized financial disturbance can spread through the cellular system and progressively involve a larger portion of the market.

 Financial potential provides an additional state variable describing accumulated financial resistance or instability within the cellular field. It is influenced by internal exhaustion, depleted energy, financial fragility, equilibrium imbalance, and existing contagion. Differences between a cell's financial potential and the potential of its neighbors form a potential gradient. That gradient represents a local imbalance in the financial field and can influence momentum and contagion. The financial-potential mechanism therefore provides another pathway through which local differences can affect neighboring cells rather than treating every region of the market as experiencing identical conditions.

 The cellular system also distinguishes between market energy and market exhaustion. Available energy represents the remaining capacity of a cell to sustain activity, while exhaustion represents the condition produced by economic forcing and endogenous cellular interactions. Exhaustion is generated from internal economic pressure together with contagion, historical pressure, energy depletion, equilibrium imbalance, external shocks, and financial-field instability. It is therefore not assigned directly from a predetermined critical value. The critical stress thresholds are classification boundaries used to determine the state of a cell; they do not force exhaustion to equal the threshold. Exhaustion is consequently a state variable produced by the interaction of the model's economic inputs and its cellular dynamics.

 As each generation evolves, energy is consumed through dissipation. Dissipation increases as local exhaustion, financial potential, historical pressure, contagion, and financial-attractor effects increase. Monetary energy changes can add or remove energy, while neighboring energy differences allow energy to move through the grid. Financial forces can also influence energy through the cell's existing momentum. The resulting energy is bounded within the model's normalized range, preventing the cellular state from becoming physically or numerically unbounded. As energy falls, energy depletion increases, and that depletion becomes another source of instability. The system therefore creates a feedback relationship in which financial pressure can consume energy, depleted energy can increase stress and exhaustion, and increasing instability can cause still more energy to be dissipated.

 Stress is calculated separately from exhaustion. Stress incorporates the resulting exhaustion together with contagion, equilibrium imbalance, energy depletion, bond pressure, external shocks, and the financial stress response associated with banking and credit fragility. This separation is important because a cell can have substantial exhaustion without immediately being classified as critical, while a cell experiencing severe energy depletion or strong systemic pressure can move toward a failure state. Stress therefore represents the cell's current degree of instability, whereas exhaustion represents a broader condition generated by the interaction of economic forcing and cellular feedback.

 Each cell progresses through defined states according to its resulting stress and remaining energy. At low stress the cell remains stable. As stress rises it enters the rising condition, followed by the stressed condition and then the critical condition. A cell enters the crash or release condition when stress reaches the release threshold or when its remaining energy falls below the severe-depletion threshold. This creates two distinct pathways to failure. The first is a stress-driven pathway in which economic pressure, contagion, equilibrium imbalance, depletion, and financial fragility progressively push the cell toward criticality. The second is an energy-depletion pathway in which available energy becomes sufficiently low to trigger release even if the cell has not independently reached the highest stress threshold.

 The cellular automaton advances one complete generation at a time. At the beginning of each generation, the current cellular grid is preserved as the previous state. Every cell reads its own state and the states of its neighbors from that unchanged previous generation. It then calculates its next energy, momentum, exhaustion, stress, financial potential, and state. No cell sees another cell's partially updated values during that generation. After every cell has completed its calculation, the entire next-generation grid is committed simultaneously. The newly committed state then becomes the previous generation for the next iteration. This synchronous update rule ensures that the cellular behavior represents simultaneous market interaction rather than an arbitrary update order.

 The process is repeated across the required number of historical years and cellular generations. During this evolution, monetary energy, economic pressure, market momentum, financial potential, energy transfer, contagion, dissipation, depletion, exhaustion, equilibrium imbalance, and stress continually interact. A period of monetary expansion can initially increase available energy and momentum, while the same market can simultaneously accumulate financial pressure and fragility. As economic conditions change, the balance between energy, momentum, exhaustion, and stress can shift. Local disturbances can then propagate through neighboring cells, creating larger regions of instability. The crash is therefore not represented as a single external event imposed on an otherwise unchanged grid; it is represented as the result of a cellular state that has evolved through historical conditions and interacting feedback mechanisms.

 At the end of the simulation, the final cellular state is aggregated across the entire grid. Mean energy describes the average remaining financial energy, while mean momentum describes the overall directional activity of the system. Mean exhaustion describes the average exhaustion generated across the cells, and mean stress describes the average systemic stress. Mean financial potential provides a measure of the accumulated financial-field instability. The fractions of critical and crash-or-release cells show how widely severe instability has spread through the grid. Energy depletion measures how much of the system's available energy has been consumed. Additional measures such as equilibrium pressure, equilibrium inflection, useful fuel, overdrive pressure, effective financial mass, financial path force, contagion, and nonlinear financial-attractor strength provide additional descriptions of the final cellular condition.

 Systemic risk is then derived primarily from the state actually produced by the cellular automaton rather than repeatedly adding the same raw economic variables after the simulation has finished. Mean exhaustion, mean stress, critical-cell concentration, crash-or-release-cell concentration, energy depletion, and financial potential form the principal components of the final systemic-risk measure. The resulting crash behavior is therefore intended to emerge from the historical economic buildup, monetary energy changes, crash-year volume disturbance, economic forcing, financial-field effects, neighboring interactions, contagion, energy dissipation, depletion, exhaustion, and stress evolution. The model does not assign a predetermined exhaustion value to produce a crash. Instead, exhaustion and systemic instability are generated as state variables through the repeated interaction of historical forcing and the cellular system, allowing different historical crash periods to enter their final state through different evolutionary pathways.




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
