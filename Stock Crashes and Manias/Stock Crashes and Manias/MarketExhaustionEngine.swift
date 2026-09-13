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
import SwiftUI
import SceneKit
import Combine

final class MarketExhaustionEngine {

    // ========================================================
    // MARK: - Historical Crash Records
    // ========================================================

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

    // ========================================================
    // MARK: - Cellular Automaton
    // ========================================================

    private(set) var cells: [MarketCell] = []

    let gridWidth: Int
    let gridHeight: Int

    // ========================================================
    // MARK: - Centralized CA Configuration
    // ========================================================

    var parameters: CAParameters

    // ========================================================
    // MARK: - Year-by-Year Risk History
    // ========================================================

    private(set) var yearlyRiskHistory: [YearlyRiskSnapshot] = []

    // ========================================================
    // MARK: - Random Generator
    // ========================================================

    private var random: CARandomGenerator

    // ========================================================
    // MARK: - Initialization
    // ========================================================

    init(
        gridWidth: Int = 20,
        gridHeight: Int = 12,
        parameters: CAParameters = CAParameters()
    ) {

        self.gridWidth = max(
            gridWidth,
            1
        )

        self.gridHeight = max(
            gridHeight,
            1
        )

        self.parameters =
            parameters.normalized()

        self.random =
            CARandomGenerator(
                seed: self.parameters.randomSeed
            )

        resetCells()
    }

    // ========================================================
    // MARK: - Historical Crash Intervals
    // ========================================================

    func crashIntervals() -> [Double] {

        guard crashRecords.count > 1 else {
            return []
        }

        return zip(
            crashRecords.dropFirst(),
            crashRecords
        ).compactMap {
            current,
            previous in

            let interval =
                Double(
                    current.year -
                    previous.year
                )

            return interval > 0
                ? interval
                : nil
        }
    }

    // ========================================================
    // MARK: - Power-Law Alpha
    // ========================================================

    func estimatePowerLawAlpha() -> Double {

        estimatePowerLawAlpha(
            upThroughCrashIndex:
                crashRecords.count - 1
        )
    }

    func estimatePowerLawAlpha(
        upThroughCrashIndex crashIndex: Int
    ) -> Double {

        guard
            crashIndex > 0,
            crashRecords.count > 1
        else {
            return 2.0
        }

        let lastIndex =
            min(
                crashIndex,
                crashRecords.count - 1
            )

        var intervals: [Double] = []

        for index in 1...lastIndex {

            let interval =
                Double(
                    crashRecords[index].year -
                    crashRecords[index - 1].year
                )

            if interval > 0 {
                intervals.append(interval)
            }
        }

        guard !intervals.isEmpty else {
            return 2.0
        }

        let xmin =
            max(
                intervals.min() ?? 1.0,
                1.0
            )

        let logarithmicSum =
            intervals.reduce(0.0) {
                partial,
                interval in

                partial +
                log(
                    max(
                        interval / xmin,
                        1.000001
                    )
                )
            }

        guard logarithmicSum > 0 else {
            return 2.0
        }

        let alpha =
            1.0 +
            Double(intervals.count) /
            logarithmicSum

        return min(
            max(
                alpha,
                1.01
            ),
            10.0
        )
    }

    // ========================================================
    // MARK: - Power-Law Pressure
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
            return 0
        }

        let xmin =
            max(
                intervals.min() ?? 1.0,
                1.0
            )

        let x =
            max(
                Double(yearsSinceCrash),
                xmin
            )

        let survivalProbability =
            pow(
                x / xmin,
                -(alpha - 1.0)
            )

        return min(
            max(
                1.0 -
                survivalProbability,
                0.0
            ),
            1.0
        )
    }

    // ========================================================
    // MARK: - Volume Pressure
    // ========================================================

    func calculateVolumePressure() -> Double {

        guard crashRecords.count >= 3 else {
            return 0
        }

        return volumePressure(
            recent:
                crashRecords[
                    crashRecords.count - 1
                ].volumeMillions,

            previous:
                crashRecords[
                    crashRecords.count - 2
                ].volumeMillions,

            older:
                crashRecords[
                    crashRecords.count - 3
                ].volumeMillions
        )
    }

    func calculateCurrentVolumePressure(
        points: [MarketVolumePoint]
    ) -> Double {

        guard points.count >= 3 else {
            return 0
        }

        let sorted =
            points.sorted {
                $0.date < $1.date
            }

        return volumePressure(
            recent:
                sorted[
                    sorted.count - 1
                ].volumeMillions,

            previous:
                sorted[
                    sorted.count - 2
                ].volumeMillions,

            older:
                sorted[
                    sorted.count - 3
                ].volumeMillions
        )
    }

    func historicalVolumePressure(
        crashIndex: Int
    ) -> Double {

        guard
            crashIndex > 0,
            crashIndex < crashRecords.count
        else {
            return 0
        }

        let recent =
            crashRecords[
                crashIndex
            ].volumeMillions

        let previous =
            crashRecords[
                crashIndex - 1
            ].volumeMillions

        let recentGrowth =
            (
                recent -
                previous
            ) /
            max(
                previous,
                1.0
            )

        guard crashIndex >= 2 else {

            return min(
                max(
                    0.7 *
                    max(
                        recentGrowth,
                        0
                    ),
                    0
                ),
                1
            )
        }

        let older =
            crashRecords[
                crashIndex - 2
            ].volumeMillions

        return volumePressure(
            recent:
                recent,
            previous:
                previous,
            older:
                older
        )
    }

    private func volumePressure(
        recent: Double,
        previous: Double,
        older: Double
    ) -> Double {

        let recentGrowth =
            (
                recent -
                previous
            ) /
            max(
                previous,
                1.0
            )

        let previousGrowth =
            (
                previous -
                older
            ) /
            max(
                older,
                1.0
            )

        let acceleration =
            recentGrowth -
            previousGrowth

        let growthComponent =
            min(
                max(
                    recentGrowth,
                    0
                ),
                1
            )

        let accelerationComponent =
            min(
                max(
                    acceleration * 4.0,
                    0
                ),
                1
            )

        return min(
            max(
                0.7 *
                growthComponent
                +
                0.3 *
                accelerationComponent,
                0
            ),
            1
        )
    }

    // ========================================================
    // MARK: - Initialize Cellular Automaton
    // ========================================================

    func resetCells() {

        yearlyRiskHistory.removeAll(
            keepingCapacity: true
        )

        // Re-seed the generator so a reset
        // follows the configured random seed.
        random =
            CARandomGenerator(
                seed:
                    parameters.randomSeed
            )

        cells = []

        cells.reserveCapacity(
            gridWidth *
            gridHeight
        )

        // ----------------------------------------------------
        // Enhancement 2:
        //
        // Give cells slightly different starting conditions.
        // ----------------------------------------------------

        for index in
            0..<(gridWidth * gridHeight)
        {

            let x =
                index %
                gridWidth

            let y =
                index /
                gridWidth

            let deterministicSpatial =
                spatialInitializationSignal(
                    x: x,
                    y: y
                )

            let randomVariation =
                random.centeredUnit() *
                parameters.spatialInitializationVariation

            let initialStress =
                min(
                    max(
                        deterministicSpatial +
                        randomVariation,
                        0
                    ),
                    parameters.risingThreshold *
                    0.75
                )

            cells.append(
                MarketCell(
                    stress:
                        initialStress,
                    state:
                        stateForStress(
                            initialStress
                        )
                   
                )
            )
        }
    }

    // ========================================================
    // MARK: - Spatial Initialization Signal
    // ========================================================

    private func spatialInitializationSignal(
        x: Int,
        y: Int
    ) -> Double {

        guard
            parameters.spatialInitializationVariation > 0
        else {
            return 0
        }

        let wave =
            sin(
                Double(x) * 0.73 +
                Double(y) * 1.17
            )

        return abs(wave) *
            parameters.spatialInitializationVariation
    }

    // ========================================================
    // MARK: - Neighbor Indices
    // ========================================================

    private func neighborIndices(
        for index: Int
    ) -> [Int] {

        let x =
            index %
            gridWidth

        let y =
            index /
            gridWidth

        var neighbors: [Int] = []

        for dy in -1...1 {

            for dx in -1...1 {

                if dx == 0 &&
                    dy == 0 {
                    continue
                }

                let nx =
                    x + dx

                let ny =
                    y + dy

                guard
                    nx >= 0,
                    nx < gridWidth,
                    ny >= 0,
                    ny < gridHeight
                else {
                    continue
                }

                neighbors.append(
                    ny *
                    gridWidth +
                    nx
                )
            }
        }

        return neighbors
    }

    // ========================================================
    // MARK: - Contagion
    // ========================================================

    private func contagionForCell(
        at index: Int
    ) -> Double {

        let neighbors =
            neighborIndices(
                for: index
            )

        guard !neighbors.isEmpty else {
            return 0
        }

        let totalStress =
            neighbors.reduce(0.0) {
                result,
                neighborIndex in

                result +
                cells[
                    neighborIndex
                ].stress
            }

        return min(
            max(
                totalStress /
                Double(
                    neighbors.count
                ),
                0
            ),
            1
        )
    }

    // ========================================================
    // MARK: - Cell Transition
    // ========================================================

    private func stateForStress(
        _ stress: Double
    ) -> MarketState {

        switch stress {

        case ..<parameters.risingThreshold:
            return .stable

        case ..<parameters.stressedThreshold:
            return .rising

        case ..<parameters.criticalThreshold:
            return .stressed

        case ..<parameters.crashThreshold:
            return .critical

        default:
            // Current MarketState uses .crashed
            // as the terminal CA state.
            return .crashed
        }
    }

    // ========================================================
    // MARK: - Spatial Signal
    // ========================================================

    private func spatialSignal(
        x: Int,
        y: Int
    ) -> Double {

        guard
            parameters.spatialSignalAmplitude > 0
        else {
            return 0
        }

        return abs(
            sin(
                Double(x) * 0.73 +
                Double(y) * 1.17
            )
        ) *
        parameters.spatialSignalAmplitude
    }

    // ========================================================
    // MARK: - Stochastic Noise
    // ========================================================

    private func stochasticNoise() -> Double {

        guard
            parameters.stochasticNoiseAmplitude > 0
        else {
            return 0
        }

        return random.centeredUnit() *
            parameters.stochasticNoiseAmplitude
    }

    // ========================================================
    // MARK: - Single CA Generation
    // ========================================================

    func step(
        equilibriumPressure: Double,
        volumePressure: Double
    ) {

        let normalizedEquilibrium =
            min(
                max(
                    equilibriumPressure,
                    0
                ),
                1
            )

        let normalizedVolume =
            min(
                max(
                    volumePressure,
                    0
                ),
                1
            )

        var nextCells =
            cells

        for index in
            cells.indices {

            let contagion =
                contagionForCell(
                    at: index
                )

            let x =
                index %
                gridWidth

            let y =
                index /
                gridWidth

            let pressure =
                parameters.equilibriumWeight *
                normalizedEquilibrium
                +
                parameters.volumeWeight *
                normalizedVolume
                +
                parameters.contagionWeight *
                contagion
                +
                spatialSignal(
                    x: x,
                    y: y
                )
                +
                stochasticNoise()

            let boundedPressure =
                min(
                    max(
                        pressure,
                        0
                    ),
                    1
                )

            nextCells[index] =
                MarketCell(
                    stress:
                        boundedPressure,
                    state:
                        stateForStress(
                            boundedPressure
                        )
                
                )
        }

        cells =
            nextCells
    }

    // ========================================================
    // MARK: - Multiple CA Generations
    // ========================================================

    func run(
        generations: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) {

        let count =
            max(
                generations,
                0
            )

        guard count > 0 else {
            return
        }

        for _ in 0..<count {

            step(
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure
            )
        }
    }

    // ========================================================
    // MARK: - Run One Calendar Year
    // ========================================================

    @discardableResult
    func runYear(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double,
        generationsPerYear: Int? = nil
    ) -> YearlyRiskSnapshot {

        let generations =
            max(
                generationsPerYear ??
                parameters.generationsPerYear,
                1
            )

        // Multiple internal generations occur
        // inside one calendar year.
        run(
            generations:
                generations,
            equilibriumPressure:
                equilibriumPressure,
            volumePressure:
                volumePressure
        )

        let snapshot =
            makeYearlyRiskSnapshot(
                year:
                    year,
                generationCount:
                    generations,
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure
            )

        yearlyRiskHistory.append(
            snapshot
        )

        return snapshot
    }

    // ========================================================
    // MARK: - Yearly Risk Snapshot
    // ========================================================

    private func makeYearlyRiskSnapshot(
        year: Int,
        generationCount: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) -> YearlyRiskSnapshot {

        let localStress =
            cellularStress()

        let critical =
            criticalCellFraction()

        let crash =
            crashCellFraction()

        let risk =
            systemicRisk(
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure
            )

        return YearlyRiskSnapshot(
            year:
                year,

            generationCount:
                generationCount,

            equilibriumPressure:
                equilibriumPressure,

            volumePressure:
                volumePressure,

            cellularStress:
                localStress,

            criticalFraction:
                critical,

            crashFraction:
                crash,

            systemicRisk:
                risk,

            riskLevel:
                riskLevel(risk),

            cells:
                cells
        )
    }

    // ========================================================
    // MARK: - Cellular Stress
    // ========================================================

    func cellularStress() -> Double {

        guard !cells.isEmpty else {
            return 0
        }

        return cells.reduce(0.0) {
            $0 +
            $1.stress
        }
        /
        Double(
            cells.count
        )
    }

    // ========================================================
    // MARK: - Critical Cell Fraction
    // ========================================================

    func criticalCellFraction() -> Double {

        guard !cells.isEmpty else {
            return 0
        }

        let count =
            cells.filter {

                $0.state == .critical ||
                $0.state == .crashed

            }.count

        return Double(count) /
            Double(cells.count)
    }

    // ========================================================
    // MARK: - Crashed Cell Fraction
    // ========================================================

    func crashCellFraction() -> Double {

        guard !cells.isEmpty else {
            return 0
        }

        let count =
            cells.filter {
                $0.state == .crashed
            }.count

        return Double(count) /
            Double(cells.count)
    }

    // ========================================================
    // MARK: - Systemic Risk
    // ========================================================

    func systemicRisk(
        equilibriumPressure: Double,
        volumePressure: Double
    ) -> Double {

        let localStress =
            cellularStress()

        let critical =
            criticalCellFraction()

        let crash =
            crashCellFraction()

        let equilibrium =
            min(
                max(
                    equilibriumPressure,
                    0
                ),
                1
            )

        let volume =
            min(
                max(
                    volumePressure,
                    0
                ),
                1
            )

        let risk =
            parameters.systemicEquilibriumWeight *
            equilibrium
            +
            parameters.systemicVolumeWeight *
            volume
            +
            parameters.systemicStressWeight *
            localStress
            +
            parameters.systemicCriticalWeight *
            critical
            +
            parameters.systemicCrashWeight *
            crash

        return min(
            max(
                risk,
                0
            ),
            1
        )
    }

    // ========================================================
    // MARK: - Risk Level
    // ========================================================

    func riskLevel(
        _ risk: Double
    ) -> String {

        let bounded =
            min(
                max(
                    risk,
                    0
                ),
                1
            )

        switch bounded {

        case ..<0.20:
            return "LOW"

        case ..<0.40:
            return "MODERATE"

        case ..<0.65:
            return "ELEVATED"

        case ..<0.80:
            return "HIGH"

        default:
            return "CRITICAL"
        }
    }

    // ========================================================
    // MARK: - Full Current Analysis
    // ========================================================

    @discardableResult
    func analyze(
        currentYear: Int,
        currentVolumePoints: [MarketVolumePoint] = []
    ) -> MarketRiskResult {

        resetCells()

        // --------------------------------------------------------
        // Find the most recent historical crash that existed at
        // the time being analyzed.
        //
        // IMPORTANT:
        // Never use crashRecords.last for a historical year.
        // Doing so leaks future information into the analysis.
        // --------------------------------------------------------

        let historicalCrashIndex: Int? =
            crashRecords.indices.last(where: {
                crashRecords[$0].year <= currentYear
            })

        let historicalCrashYear: Int =
            historicalCrashIndex.map {
                crashRecords[$0].year
            } ?? currentYear

        let yearsSinceCrash =
            max(
                currentYear - historicalCrashYear,
                0
            )

        // --------------------------------------------------------
        // Estimate alpha using ONLY crashes available at the
        // analysis date.
        //
        // This prevents 2008/2020/2022 from influencing a
        // 1907, 1929, or 1937 analysis.
        // --------------------------------------------------------

        let alpha: Double

        if let crashIndex = historicalCrashIndex {
            alpha = estimatePowerLawAlpha(
                upThroughCrashIndex:
                    crashIndex
            )
        } else {
            alpha = 2.0
        }

        // --------------------------------------------------------
        // Build the interval history available at this point.
        // --------------------------------------------------------

        let intervals: [Double]

        if let crashIndex = historicalCrashIndex,
           crashIndex > 0 {

            intervals =
                (1...crashIndex)
                .compactMap { index in

                    let interval =
                        Double(
                            crashRecords[index].year -
                            crashRecords[index - 1].year
                        )

                    return interval > 0
                        ? interval
                        : nil
                }

        } else {
            intervals = []
        }

        // --------------------------------------------------------
        // Power-law equilibrium pressure.
        //
        // This now uses the historical alpha and intervals
        // available at the requested year.
        // --------------------------------------------------------

        let equilibrium: Double

        if !intervals.isEmpty {

            equilibrium =
                powerLawPressure(
                    yearsSinceCrash:
                        yearsSinceCrash,
                    alpha:
                        alpha,
                    intervals:
                        intervals
                )

        } else {

            equilibrium = 0
        }

        // --------------------------------------------------------
        // Volume pressure.
        //
        // Current analysis:
        // use explicitly supplied current volume data.
        //
        // Historical analysis:
        // use the crash record that existed at that time.
        //
        // If there is no supplied current series, do NOT fall
        // through to calculateVolumePressure(), because that
        // would incorrectly use the final 2022 records.
        // --------------------------------------------------------

        let volume: Double

        if currentVolumePoints.count >= 3 {

            volume =
                calculateCurrentVolumePressure(
                    points:
                        currentVolumePoints
                )

        } else if let crashIndex = historicalCrashIndex {

            volume =
                historicalVolumePressure(
                    crashIndex:
                        crashIndex
                )

        } else {

            volume = 0
        }

        // --------------------------------------------------------
        // Run the cellular model for the requested year.
        // --------------------------------------------------------

        _ = runYear(
            year:
                currentYear,
            equilibriumPressure:
                equilibrium,
            volumePressure:
                volume
        )

        // --------------------------------------------------------
        // Extract resulting cellular state.
        // --------------------------------------------------------

        let localStress =
            cellularStress()

        let critical =
            criticalCellFraction()

        let crash =
            crashCellFraction()

        let risk =
            systemicRisk(
                equilibriumPressure:
                    equilibrium,
                volumePressure:
                    volume
            )

        let horizon =
            riskWindowHorizon(
                for:
                    risk
            )

        // --------------------------------------------------------
        // Return analysis.
        // --------------------------------------------------------

        return MarketRiskResult(
            currentYear:
                currentYear,

            yearsSinceCrash:
                yearsSinceCrash,

            alpha:
                alpha,

            equilibriumPressure:
                equilibrium,

            volumePressure:
                volume,

            cellularStress:
                localStress,

            criticalFraction:
                critical,

            crashFraction:
                crash,

            systemicRisk:
                risk,

            predictedWindowStart:
                currentYear + 1,

            predictedWindowEnd:
                currentYear + horizon,

            riskLevel:
                riskLevel(risk),

            yearlyRiskHistory:
                yearlyRiskHistory
        )
    }
    // ========================================================
    // MARK: - Historical Crash Analysis
    // ========================================================

    func analyzeHistoricalCrash(
        at crashIndex: Int
    ) -> HistoricalCrashAnalysis? {

        guard
            crashRecords.indices.contains(
                crashIndex
            )
        else {
            return nil
        }

        resetCells()

        let record =
            crashRecords[
                crashIndex
            ]

        // ----------------------------------------------------
        // Determine the interval since the previous crash.
        // ----------------------------------------------------

        let intervalYears: Int

        if crashIndex > 0 {

            intervalYears =
                max(
                    record.year -
                    crashRecords[
                        crashIndex - 1
                    ].year,
                    0
                )

        } else {

            intervalYears = 0
        }

        // ----------------------------------------------------
        // Estimate the power-law parameter using only the
        // historical crashes available through this point.
        // ----------------------------------------------------

        let alpha =
            estimatePowerLawAlpha(
                upThroughCrashIndex:
                    crashIndex
            )

        // ----------------------------------------------------
        // Build the historical interval series.
        // ----------------------------------------------------

        let intervals: [Double]

        if crashIndex > 0 {

            intervals =
                (1...crashIndex)
                .compactMap {
                    index in

                    let interval =
                        Double(
                            crashRecords[
                                index
                            ].year
                            -
                            crashRecords[
                                index - 1
                            ].year
                        )

                    return interval > 0
                        ? interval
                        : nil
                }

        } else {

            intervals = []
        }

        // ----------------------------------------------------
        // Historical volume pressure for this crash.
        // ----------------------------------------------------

        let volume =
            historicalVolumePressure(
                crashIndex:
                    crashIndex
            )

        // ----------------------------------------------------
        // Enhancement 5:
        //
        // Simulate every calendar year between crashes so
        // systemic risk can develop progressively.
        // ----------------------------------------------------

        let startYear =
            crashIndex > 0

            ? crashRecords[
                crashIndex - 1
            ].year + 1

            : record.year

        if startYear <= record.year {

            for year in
                startYear...record.year {

                let elapsed =
                    max(
                        year -
                        (
                            crashIndex > 0

                            ? crashRecords[
                                crashIndex - 1
                            ].year

                            : record.year
                        ),
                        0
                    )

                let yearlyEquilibrium =
                    powerLawPressure(
                        yearsSinceCrash:
                            elapsed,

                        alpha:
                            alpha,

                        intervals:
                            intervals
                    )

                _ = runYear(
                    year:
                        year,

                    equilibriumPressure:
                        yearlyEquilibrium,

                    volumePressure:
                        volume
                )
            }
        }

        // ----------------------------------------------------
        // Terminal state.
        // ----------------------------------------------------

        let localStress =
            cellularStress()

        let critical =
            criticalCellFraction()

        let crash =
            crashCellFraction()

        let terminalEquilibrium =
            powerLawPressure(
                yearsSinceCrash:
                    intervalYears,

                alpha:
                    alpha,

                intervals:
                    intervals
            )

        let risk =
            systemicRisk(
                equilibriumPressure:
                    terminalEquilibrium,

                volumePressure:
                    volume
            )

        let horizon =
            riskWindowHorizon(
                for:
                    risk
            )

        let previousCrashYear =
            crashIndex > 0

            ? crashRecords[
                crashIndex - 1
            ].year

            : record.year

        let result =
            MarketRiskResult(
                currentYear:
                    record.year,

                yearsSinceCrash:
                    intervalYears,

                alpha:
                    alpha,

                equilibriumPressure:
                    terminalEquilibrium,

                volumePressure:
                    volume,

                cellularStress:
                    localStress,

                criticalFraction:
                    critical,

                crashFraction:
                    crash,

                systemicRisk:
                    risk,

                predictedWindowStart:
                    max(
                        previousCrashYear + 1,
                        record.year - horizon
                    ),

                predictedWindowEnd:
                    record.year,

                riskLevel:
                    riskLevel(risk),

                yearlyRiskHistory:
                    yearlyRiskHistory
            )

        return HistoricalCrashAnalysis(
            year:
                record.year,

            intervalYears:
                intervalYears,

            result:
                result,

            cells:
                cells
        )
    }

    // ========================================================
    // MARK: - Risk Window
    // ========================================================

    private func riskWindowHorizon(
        for risk: Double
    ) -> Int {

        switch risk {

        case ..<0.20:
            return 10

        case ..<0.40:
            return 7

        case ..<0.65:
            return 5

        case ..<0.80:
            return 3

        default:
            return 2
        }
    }
}
