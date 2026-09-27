//
//  ContentView.swift
//  Stock Crashes and Manias
//
//  Historical market data
//  Optimism → Momentum → Equilibrium → Power Law → Cellular Automaton
//

import SwiftUI
import Foundation

// ============================================================
// MARK: - Content View
// ============================================================

struct ContentView: View {

    // ========================================================
    // MARK: - Current Scenario
    // ========================================================

    @State private var selectedYear = 2026

    @State private var growthM2 = 5.0
    @State private var moneyPolicyChangeImpact = 0.62
    @State private var bankingCreditStressRating = 2.0
    @State private var inflationPercent = 3.0
    @State private var taxGrowthPercent = 5.0
    @State private var economicGrowthPercent = 3.0
    @State private var stockGrowthPercent = 12.0
    @State private var previousStockGrowthPercent = 20.0
    @State private var bondYieldAvgPercent = 4.5
    @State private var growthVolumePercent = 10.0
    @State private var crashInterval = 6.0
    @State private var externalShockPercent = 0.0

    // ========================================================
    // MARK: - Engine
    // ========================================================

    @StateObject private var engine = MarketExhaustionEngine()

    @State private var result: MarketRiskResult?

    @State private var historicalAnalyses: [HistoricalCrashAnalysis] = []

    // ========================================================
    // MARK: - Body
    // ========================================================

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    headerCard

                    scenarioCard

                    currentScenarioSection

                    historicalSection

                    historicalMatrixCard

                    modelSummaryCard
                }
                .padding()
            }
            .navigationTitle("Stock Crashes and Manias")
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {

                        runSimulation()

                    } label: {

                        Image(
                            systemName: "arrow.clockwise"
                        )
                    }
                }
            }
            .onAppear {

                runSimulation()

                loadHistoricalMatrix()
            }
        }
    }

    // ========================================================
    // MARK: - Header
    // ========================================================

    private var headerCard: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text("Market Exhaustion Model")
                .font(.title2.bold())

            Text(
                "Historical stress → local instability → contagion → systemic transition"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Divider()

            Text(
                """
                The cellular automaton is the primary dynamic component.
                Historical and current market information act as external
                stressors. Each cell has persistent local financial
                properties, so cells respond differently to the same
                external pressure.
                """
            )
            .font(.footnote)

            Text(
                """
                Initial failures generate contagion. Neighboring cells
                can therefore become stressed, critical, or crashed even
                when they were not directly subjected to the original
                shock.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Scenario Card
    // ========================================================

    private var scenarioCard: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("Current Scenario")
                .font(.headline)

            Text("Simulation Year: \(selectedYear)")
                .font(.subheadline.bold())

            Divider()

            Text("External Market Inputs")
                .font(.subheadline.bold())

            scenarioValue(
                "M2 Growth",
                value: growthM2,
                suffix: "%"
            )

            scenarioValue(
                "Inflation",
                value: inflationPercent,
                suffix: "%"
            )

            scenarioValue(
                "Tax Growth",
                value: taxGrowthPercent,
                suffix: "%"
            )

            scenarioValue(
                "Economic Growth",
                value: economicGrowthPercent,
                suffix: "%"
            )

            scenarioValue(
                "Stock Growth",
                value: stockGrowthPercent,
                suffix: "%"
            )

            scenarioValue(
                "Previous Stock Growth",
                value: previousStockGrowthPercent,
                suffix: "%"
            )

            scenarioValue(
                "Average Bond Yield",
                value: bondYieldAvgPercent,
                suffix: "%"
            )

            scenarioValue(
                "Volume Growth",
                value: growthVolumePercent,
                suffix: "%"
            )

            scenarioValue(
                "Bank / Credit Stress",
                value: bankingCreditStressRating,
                suffix: ""
            )

            scenarioValue(
                "Policy Impact",
                value: moneyPolicyChangeImpact,
                suffix: ""
            )

            scenarioValue(
                "External Shock",
                value: externalShockPercent,
                suffix: "%"
            )

            scenarioValue(
                "Crash Interval",
                value: crashInterval,
                suffix: " years"
            )

            Button {

                runSimulation()

            } label: {

                Text("Run Simulation")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Scenario Value
    // ========================================================

    private func scenarioValue(
        _ title: String,
        value: Double,
        suffix: String
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(
                String(
                    format: "%.2f",
                    value
                ) + suffix
            )
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
    }

    // ========================================================
    // MARK: - Current Scenario
    // ========================================================

    private var currentScenarioSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("Current Cellular-Automaton State")
                .font(.title3.bold())

            if let result {

                equilibriumCard(result)

                cellularAutomatonCard

                localFinancialStructureCard

                contagionCard

                riskCard(result)

                dynamicsCard
            }
        }
    }

    // ========================================================
    // MARK: - Equilibrium
    // ========================================================

    private func equilibriumCard(
        _ result: MarketRiskResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text("Equilibrium / Momentum")
                .font(.headline)

            HStack {

                metric(
                    title: "Equilibrium",
                    value: percent(
                        result.equilibriumPressure
                    )
                )

                metric(
                    title: "Volume Pressure",
                    value: percent(
                        result.volumePressure
                    )
                )
            }

            Divider()

            Text(
                """
                Equilibrium is treated as a state variable describing
                compression between continued expansion and increasing
                internal market stress. It is not a fixed crash timer.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            ProgressView(
                value: bounded(
                    result.equilibriumPressure
                )
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Cellular Automaton
    // ========================================================

    private var cellularAutomatonCard: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Cellular Automaton")
                .font(.headline)

            Text(
                """
                The 32 × 32 lattice evolves synchronously. Each cell
                retains its own liquidity buffer, capital buffer,
                fragility, macro exposure, recovery capacity and
                local shock susceptibility.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            cellGrid(
                cells: engine.cells
            )

            stateLegendView
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Cell Grid
    // ========================================================

    private func cellGrid(
        cells: [MarketCell]
    ) -> some View {

        let width = max(
            Int(
                sqrt(
                    Double(
                        max(cells.count, 1)
                    )
                )
            ),
            1
        )

        return LazyVGrid(

            columns: Array(
                repeating:
                    GridItem(
                        .flexible(),
                        spacing: 2
                    ),
                count: width
            ),

            spacing: 2

        ) {

            ForEach(cells) { cell in

                RoundedRectangle(
                    cornerRadius: 2
                )
                .fill(
                    cellColor(
                        cell.state
                    )
                )
                .overlay {

                    RoundedRectangle(
                        cornerRadius: 2
                    )
                    .stroke(
                        Color.primary.opacity(
                            cell.state == .stable
                            ? 0.04
                            : 0.12
                        ),
                        lineWidth: 0.25
                    )
                }
                .aspectRatio(
                    1,
                    contentMode: .fit
                )
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .aspectRatio(
            1,
            contentMode: .fit
        )
    }

    // ========================================================
    // MARK: - Local Financial Structure
    // ========================================================

    private var localFinancialStructureCard: some View {

        let cells = engine.cells

        let averageLiquidity =
            mean(
                cells.map {
                    $0.liquidity
                }
            )

        let averageCapital =
            mean(
                cells.map {
                    $0.capital
                }
            )

        let averageFragility =
            mean(
                cells.map {
                    $0.fragility
                }
            )

        let averageMacroExposure =
            mean(
                cells.map {
                    $0.macroExposure
                }
            )

        let averageRecovery =
            mean(
                cells.map {
                    $0.recoveryCapacity
                }
            )

        let averageShockSensitivity =
            mean(
                cells.map {
                    $0.localShockSusceptibility
                }
            )

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Local Financial Structure")
                .font(.headline)

            Text(
                """
                These properties are persistent characteristics of
                individual cells. They determine why some cells fail
                earlier than others when the same market stress reaches
                them.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            financialMetric(
                "Liquidity Buffer",
                averageLiquidity
            )

            financialMetric(
                "Capital Buffer",
                averageCapital
            )

            financialMetric(
                "Fragility / Leverage",
                averageFragility
            )

            financialMetric(
                "Macro Exposure",
                averageMacroExposure
            )

            financialMetric(
                "Recovery Capacity",
                averageRecovery
            )

            financialMetric(
                "Local Shock Susceptibility",
                averageShockSensitivity
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Financial Metric
    // ========================================================

    private func financialMetric(
        _ title: String,
        _ value: Double
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            HStack {

                Text(title)

                Spacer()

                Text(
                    percent(value)
                )
                .monospacedDigit()
            }

            ProgressView(
                value: bounded(value)
            )
        }
    }

    // ========================================================
    // MARK: - Contagion
    // ========================================================

    private var contagionCard: some View {

        let cells = engine.cells

        let meanContagion =
            mean(
                cells.map {
                    $0.contagion
                }
            )

        let stressed =
            fraction(
                cells
            ) {
                $0.state == .stressed
            }

        let critical =
            fraction(
                cells
            ) {
                $0.state == .critical
            }

        let crashed =
            fraction(
                cells
            ) {
                $0.state == .crashed
            }

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Contagion")
                .font(.headline)

            HStack {

                metric(
                    title: "Mean Contagion",
                    value: percent(
                        meanContagion
                    )
                )

                metric(
                    title: "Stressed",
                    value: percent(
                        stressed
                    )
                )

                metric(
                    title: "Critical",
                    value: percent(
                        critical
                    )
                )

                metric(
                    title: "Crashed",
                    value: percent(
                        crashed
                    )
                )
            }

            Text(
                """
                Contagion is transmitted from neighboring market cells.
                Rising, stressed, critical and crashed cells contribute
                different amounts of pressure, with local vulnerability
                amplifying the transmitted stress.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Risk
    // ========================================================

    private func riskCard(
        _ result: MarketRiskResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Emergent Systemic Stress")
                .font(.headline)

            HStack {

                Text(
                    percent(
                        result.systemicRisk
                    )
                )
                .font(
                    .title.bold()
                )
                .monospacedDigit()

                Spacer()

                Text(result.riskLevel.rawValue)
                    .font(.headline)
                    .foregroundStyle(riskColor(result.systemicRisk))
            }

            ProgressView(
                value: bounded(
                    result.systemicRisk
                )
            )

            HStack {

                metric(
                    title: "Cellular Stress",
                    value: percent(
                        result.cellularStress
                    )
                )

                metric(
                    title: "Critical Cells",
                    value: percent(
                        result.criticalFraction
                    )
                )

                metric(
                    title: "Crashed Cells",
                    value: percent(
                        result.crashFraction
                    )
                )
            }

            Text(
                """
                Systemic risk is an emergent summary of the cellular
                state. It is not calculated from a fixed crash interval
                and should not be interpreted as a probability.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - CA Dynamics
    // ========================================================

    private var dynamicsCard: some View {

        let cells = engine.cells

        let meanEnergy =
            mean(
                cells.map {
                    $0.energy
                }
            )

        let meanMomentum =
            mean(
                cells.map {
                    $0.momentum
                }
            )

        let meanExhaustion =
            mean(
                cells.map {
                    $0.exhaustion
                }
            )

        let meanStress =
            mean(
                cells.map {
                    $0.stress
                }
            )

        let meanPotential =
            mean(
                cells.map {
                    $0.financialPotential
                }
            )

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Collective CA Dynamics")
                .font(.headline)

            HStack {

                metric(
                    title: "Energy",
                    value: percent(
                        meanEnergy
                    )
                )

                metric(
                    title: "Momentum",
                    value: percent(
                        meanMomentum
                    )
                )
            }

            HStack {

                metric(
                    title: "Exhaustion",
                    value: percent(
                        meanExhaustion
                    )
                )

                metric(
                    title: "Stress",
                    value: percent(
                        meanStress
                    )
                )

                metric(
                    title: "Potential",
                    value: percent(
                        meanPotential
                    )
                )
            }

            Text(
                """
                These collective quantities describe the internal state
                of the lattice. The important signal is the transition
                in the distribution and spatial organization of cells,
                not simply the value of one global input.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Historical Section
    // ========================================================

    private var historicalSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Text(
                "Historical Crash-Year Analysis"
            )
            .font(.title2.bold())

            Text(
                """
                Historical market data provide external stress conditions
                to the cellular automaton. Each historical crash period
                is evaluated using its own preceding years, preventing
                information from one historical period from leaking into
                another.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            ForEach(
                historicalAnalyses,
                id: \.id
            ) { analysis in

                historicalCrashPanel(
                    analysis
                )
            }
        }
    }

    // ========================================================
    // MARK: - Historical Crash Panel
    // ========================================================

    private func historicalCrashPanel(
        _ analysis: HistoricalCrashAnalysis
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                VStack(
                    alignment: .leading
                ) {

                    Text(
                        "Crash Year \(analysis.year)"
                    )
                    .font(.title3.bold())

                    Text(
                        "Historical CA state"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text(String(describing: analysis.result.riskLevel))
                    .font(.headline)

            }

            HStack {

                metric(
                    title: "Equilibrium",
                    value: percent(
                        analysis.result.equilibriumPressure
                    )
                )

                metric(
                    title: "Volume",
                    value: percent(
                        analysis.result.volumePressure
                    )
                )

                metric(
                    title: "Cell Stress",
                    value: percent(
                        analysis.result.cellularStress
                    )
                )

                metric(
                    title: "Systemic",
                    value: percent(
                        analysis.result.systemicRisk
                    )
                )
            }

            cellGrid(
                cells: analysis.cells
            )

            HStack {

                metric(
                    title: "Critical",
                    value: percent(
                        analysis.result.criticalFraction
                    )
                )

                metric(
                    title: "Crashed",
                    value: percent(
                        analysis.result.crashFraction
                    )
                )
            }
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Historical Matrix
    // ========================================================

    private var historicalMatrixCard: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Historical Equilibrium / Power-Law Matrix"
            )
            .font(.headline)

            Text(
                """
                This matrix shows the historical inputs and model-derived
                quantities used to initialize the CA stress dynamics.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            ScrollView(
                .horizontal,
                showsIndicators: true
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    matrixHeader

                    ForEach(
                        historicalAnalyses,
                        id: \.id
                    ) { analysis in

                        matrixRow(
                            analysis
                        )
                    }
                }
                .font(
                    .system(
                        size: 11,
                        design: .monospaced
                    )
                )
            }
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Matrix Header
    // ========================================================

    private var matrixHeader: some View {

        HStack(spacing: 0) {

            matrixText("Crash", width: 60)

            matrixText("Equilibrium", width: 90)

            matrixText("Volume", width: 75)

            matrixText("Stress", width: 75)

            matrixText("Critical", width: 75)

            matrixText("Crash", width: 75)

            matrixText("Systemic", width: 75)

            matrixText("Risk", width: 90)
        }
    }

    // ========================================================
    // MARK: - Matrix Row
    // ========================================================

    private func matrixRow(
        _ analysis: HistoricalCrashAnalysis
    ) -> some View {

        HStack(spacing: 0) {

            matrixText(
                "\(analysis.year)",
                width: 60
            )

            matrixText(
                percent(
                    analysis.result.equilibriumPressure
                ),
                width: 90
            )

            matrixText(
                percent(
                    analysis.result.volumePressure
                ),
                width: 75
            )

            matrixText(
                percent(
                    analysis.result.cellularStress
                ),
                width: 75
            )

            matrixText(
                percent(
                    analysis.result.criticalFraction
                ),
                width: 75
            )

            matrixText(
                percent(
                    analysis.result.crashFraction
                ),
                width: 75
            )

            matrixText(
                percent(
                    analysis.result.systemicRisk
                ),
                width: 75
            )

            matrixText(
                String(describing: analysis.result.riskLevel),
                width: 90
            )
        }
        .padding(.vertical, 4)
    }

    // ========================================================
    // MARK: - Matrix Text
    // ========================================================

    private func matrixText(
        _ text: String,
        width: CGFloat
    ) -> some View {

        Text(text)
            .frame(
                width: width,
                alignment: .trailing
            )
    }

    // ========================================================
    // MARK: - Model Summary
    // ========================================================

    private var modelSummaryCard: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text("Model Pipeline")
                .font(.headline)

            pipelineStep(
                1,
                "Historical market data"
            )

            pipelineStep(
                2,
                "Macro / banking / credit stress"
            )

            pipelineStep(
                3,
                "External stressor enters the CA"
            )

            pipelineStep(
                4,
                "Persistent local liquidity and capital buffers"
            )

            pipelineStep(
                5,
                "Fragility, leverage and macro exposure modify response"
            )

            pipelineStep(
                6,
                "Local shock susceptibility creates heterogeneous failures"
            )

            pipelineStep(
                7,
                "Failed cells generate neighbor contagion"
            )

            pipelineStep(
                8,
                "Recovery capacity determines whether stress dissipates"
            )

            pipelineStep(
                9,
                "Collective spatial patterns emerge"
            )

            pipelineStep(
                10,
                "Equilibrium → nonlinear amplification → instability → systemic transition"
            )

            Divider()

            Text(
                """
                The crash interval is therefore metadata rather than the
                mechanism that determines when cells fail. The cellular
                automaton provides the evolving local and collective state.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // ========================================================
    // MARK: - Pipeline Step
    // ========================================================

    private func pipelineStep(
        _ number: Int,
        _ text: String
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 8
        ) {

            Text(
                "\(number)."
            )
            .fontWeight(.bold)
            .frame(
                width: 24,
                alignment: .leading
            )

            Text(text)
        }
        .font(.footnote)
    }

    // ========================================================
    // MARK: - State Legend
    // ========================================================

    private var stateLegendView: some View {

        HStack {

            stateLegend(
                "Stable",
                .gray
            )

            stateLegend(
                "Rising",
                .blue
            )

            stateLegend(
                "Stressed",
                .orange
            )

            stateLegend(
                "Critical",
                .red
            )

            stateLegend(
                "Crashed",
                .purple
            )
        }
        .font(.caption2)
    }

    private func stateLegend(
        _ title: String,
        _ color: Color
    ) -> some View {

        HStack(spacing: 3) {

            Circle()
                .fill(color)
                .frame(
                    width: 7,
                    height: 7
                )

            Text(title)
        }
    }

    // ========================================================
    // MARK: - Cell Color
    // ========================================================

    private func cellColor(
        _ state: MarketState
    ) -> Color {

        switch state {

        case .stable:
            return .gray

        case .rising:
            return .blue

        case .stressed:
            return .orange

        case .critical:
            return .red

        case .crashed:
            return .purple
        }
    }

    // ========================================================
    // MARK: - Risk Color
    // ========================================================

    private func riskColor(
        _ value: Double
    ) -> Color {

        switch value {

        case 0..<0.20:
            return .green

        case 0.20..<0.40:
            return .blue

        case 0.40..<0.65:
            return .orange

        case 0.65..<0.80:
            return .red

        default:
            return .purple
        }
    }

    // ========================================================
    // MARK: - Metric
    // ========================================================

    private func metric(
        title: String,
        value: String
    ) -> some View {

        VStack {

            Text(value)
                .font(.headline)
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity
        )
    }

    // ========================================================
    // MARK: - Simulation
    // ========================================================

    private func runSimulation() {

        let parameters =
            MarketParameters()

        let scenario =
            MarketScenario(
                moneySupplyChangePercent:
                    growthM2,

                inflationPercent:
                    inflationPercent,

                taxationGrowthPercent:
                    taxGrowthPercent,

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

        _ = scenario

        /*
         The current engine owns the canonical CA evolution.

         It resets the heterogeneous lattice, advances the CA
         synchronously, calculates the collective state and returns
         MarketRiskResult.

         The macro inputs above are retained as scenario controls.
         When the engine's scenario-aware analyze/runYear interface
         is used, these values become the external forcing terms.
        */

       
    }

    // ========================================================
    // MARK: - Historical Matrix
    // ========================================================

    private func loadHistoricalMatrix() {

        historicalAnalyses =
            engine.analyzeAllHistoricalCrashes()
    }

    // ========================================================
    // MARK: - Helpers
    // ========================================================

    private func bounded(
        _ value: Double
    ) -> Double {

        guard value.isFinite else {
            return 0
        }

        return min(
            max(value, 0),
            1
        )
    }

    private func percent(
        _ value: Double
    ) -> String {

        String(
            format: "%.1f%%",
            bounded(value) * 100
        )
    }

    private func mean(
        _ values: [Double]
    ) -> Double {

        guard !values.isEmpty else {
            return 0
        }

        return values.reduce(
            0,
            +
        ) / Double(values.count)
    }

    private func fraction(
        _ cells: [MarketCell],
        where predicate: (MarketCell) -> Bool
    ) -> Double {

        guard !cells.isEmpty else {
            return 0
        }

        let count =
            cells.filter(
                predicate
            ).count

        return Double(count) /
            Double(cells.count)
    }
}

// ============================================================
// MARK: - Preview
// ============================================================

#Preview {
    ContentView()
}
