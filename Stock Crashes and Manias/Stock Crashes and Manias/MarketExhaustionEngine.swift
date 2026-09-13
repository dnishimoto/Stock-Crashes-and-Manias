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

//
//  MarketExhaustionEngine.swift
//  Stock Crashes and Manias
//
//  Full historical market-exhaustion model.
//
//  The model combines:
//
//  Historical crash intervals
//      ↓
//  Power-law equilibrium pressure
//      ↓
//  Historical/current volume pressure
//      ↓
//  Cellular automaton
//      ↓
//  Energy
//      ↓
//  Momentum
//      ↓
//  Financial potential
//      ↓
//  Liquidity / capital depletion
//      ↓
//  Exhaustion
//      ↓
//  Neighbor contagion
//      ↓
//  Dissipation
//      ↓
//  Stress
//      ↓
//  Market state
//      ↓
//  Systemic risk
//

import Foundation
import SwiftUI
import SceneKit
import Combine




// MARK: - Engine

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

    func step(
        equilibriumPressure: Double,
        volumePressure: Double
    ) {

        guard !cells.isEmpty else {
            return
        }

        // --------------------------------------------------------
        // IMPORTANT:
        //
        // Every cell reads from the same previous generation.
        // This prevents the left side of the grid from being
        // updated using partially updated cells from the right
        // side of the same generation.
        // --------------------------------------------------------

        let previousCells = cells

        let normalizedEquilibrium =
            bounded(
                equilibriumPressure
            )

        let normalizedVolume =
            bounded(
                volumePressure
            )

        let externalForcing =
            bounded(
                parameters.equilibriumWeight *
                    normalizedEquilibrium
                +
                parameters.volumeWeight *
                    normalizedVolume
            )

        for index in previousCells.indices {

            let previous =
                previousCells[index]

            // ----------------------------------------------------
            // 1. External market forcing
            // ----------------------------------------------------

            let forcing =
                externalForcing

            // ----------------------------------------------------
            // 2. Energy accumulation
            // ----------------------------------------------------

            let injectedEnergy =
                forcing *
                parameters.energyInjectionRate

            let retainedEnergy =
                previous.energy *
                parameters.energyRetention

            let newEnergy =
                retainedEnergy +
                injectedEnergy

            // ----------------------------------------------------
            // 3. Momentum
            // ----------------------------------------------------

            let directionalChange =
                newEnergy -
                previous.energy

            let newMomentum =
                previous.momentum *
                    parameters.momentumRetention
                +
                directionalChange *
                    parameters.momentumResponse

            // ----------------------------------------------------
            // 4. Financial potential
            // ----------------------------------------------------

            let energyPotential =
                newEnergy *
                parameters.potentialEnergyWeight

            let momentumPotential =
                abs(newMomentum) *
                parameters.potentialMomentumWeight

            let rawPotential =
                (
                    energyPotential +
                    momentumPotential
                ) *
                parameters.potentialGain

            let newFinancialPotential =
                bounded(
                    rawPotential
                )

            // ----------------------------------------------------
            // 5. Liquidity depletion
            // ----------------------------------------------------

            let liquidityPressure =
                newFinancialPotential *
                parameters.liquidityDepletionRate

            let newLiquidity =
                bounded(
                    previous.liquidity -
                    liquidityPressure
                )

            // ----------------------------------------------------
            // 6. Capital depletion
            // ----------------------------------------------------

            let capitalPressure =
                newFinancialPotential *
                parameters.capitalDepletionRate

            let newCapital =
                bounded(
                    previous.capital -
                    capitalPressure
                )

            // ----------------------------------------------------
            // 7. Resource exhaustion
            // ----------------------------------------------------

            let resourceDepletion =
                1.0 -
                (
                    0.50 * newLiquidity +
                    0.50 * newCapital
                )

            let exhaustionPressure =
                bounded(
                    resourceDepletion
                )

            let recovery =
                previous.exhaustion *
                parameters.exhaustionRecoveryRate

            let accumulatedExhaustion =
                previous.exhaustion -
                recovery +
                exhaustionPressure *
                    parameters.exhaustionAccumulationRate

            let newExhaustion =
                bounded(
                    accumulatedExhaustion
                )

            // ----------------------------------------------------
            // 8. Neighbor contagion
            // ----------------------------------------------------

            let neighborStress =
                averageNeighborStress(
                    index: index,
                    snapshot: previousCells
                )

            let newContagion =
                bounded(
                    neighborStress *
                    parameters.contagionRate
                )

            // ----------------------------------------------------
            // 9. Dissipation
            // ----------------------------------------------------

            let rawDissipation =
                previous.stress *
                parameters.dissipationRate

            let newDissipation =
                bounded(
                    rawDissipation
                )

            // ----------------------------------------------------
            // 10. Combined cellular stress
            // ----------------------------------------------------

            let rawStress =
                parameters.energyWeight *
                    bounded(newEnergy)
                +
                parameters.momentumWeight *
                    bounded(
                        abs(newMomentum)
                    )
                +
                parameters.potentialWeight *
                    newFinancialPotential
                +
                parameters.exhaustionWeight *
                    newExhaustion
                +
                parameters.contagionWeight *
                    newContagion
                -
                newDissipation

            // ----------------------------------------------------
            // 11. Stochastic perturbation
            // ----------------------------------------------------

            let noise =
                (
                    random.nextUnit() -
                    0.5
                ) *
                parameters.stochasticNoise

            let newStress =
                bounded(
                    rawStress + noise
                )

            // ----------------------------------------------------
            // 12. Discrete state transition
            // ----------------------------------------------------

            let newState =
                stateForStress(
                    newStress
                )

            // ----------------------------------------------------
            // 13. Commit next generation
            // ----------------------------------------------------

            cells[index].energy =
                bounded(newEnergy)

            cells[index].momentum =
                bounded(
                    abs(newMomentum)
                )

            cells[index].financialPotential =
                newFinancialPotential

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

        for _ in 0..<years {

            step(
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure
            )
        }
    }

    // MARK: - Run One Year

    func runYear(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) {

        step(
            equilibriumPressure:
                equilibriumPressure,
            volumePressure:
                volumePressure
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

        return bounded(
            cells.reduce(
                0.0
            ) {
                $0 + $1.momentum
            }
            /
            Double(cells.count)
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

            let values = [
                cell.energy,
                cell.momentum,
                cell.liquidity,
                cell.capital,
                cell.exhaustion,
                cell.stress,
                cell.financialPotential,
                cell.contagion,
                cell.dissipation
            ]

            for value in values {

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

// MARK: - Deterministic Random Generator

struct SplitMix64 {

    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {

        state &+= 0x9E3779B97F4A7C15

        var z = state

        z =
            (z ^ (z >> 30))
            &*
            0xBF58476D1CE4E5B9

        z =
            (z ^ (z >> 27))
            &*
            0x94D049BB133111EB

        return z ^ (z >> 31)
    }

    mutating func nextUnit() -> Double {

        let value =
            next()

        let normalized =
            Double(
                value >> 11
            )
            *
            (1.0 / 9007199254740992.0)

        return min(
            max(
                normalized,
                0.0
            ),
            0.9999999999999999
        )
    }
}
