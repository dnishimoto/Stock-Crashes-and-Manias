import SwiftUI
import Foundation

struct ContentView: View {

    // MARK: - Selected Year
    @State private var historicalSimulationResults:
        [HistoricalSimulationResult] = []
    
    @State private var selectedYear = 2026
    

    // MARK: - 2026 / Current Scenario Inputs

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
    @State private var allYears: [Int] = []

    // MARK: - Engine

    @StateObject private var engine = MarketExhaustionEngine()

    @State private var result: MarketRiskResult?

    @State private var historicalAnalyses:
        [HistoricalCrashAnalysis] = []

    // MARK: - All Display Years

    func loadYears()
    {
        self.allYears = historicalAnalyses.map(\.year).sorted(by: >)
    }
   

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                LazyVStack(
                    alignment: .leading,
                    spacing: 20
                ) {

                    headerCard

                    ForEach(
                        allYears,
                        id: \.self
                    ) { year in
                        yearGroup(
                            year: year
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(
                "Stock Crashes and Manias"
            )
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {

                        runSimulation(
                            year: selectedYear
                        )

                    } label: {

                        Image(
                            systemName:
                                "arrow.clockwise"
                        )
                    }
                }
            }

            .onAppear {
                
                loadHistoricalMatrix()
                loadYears()
                
                runAllHistoricalYears()
                
                runSimulation(
                        year: selectedYear
                    )
            }
        }
    }
    // MARK: - Historical Simulation Result Card

    @ViewBuilder
    private func historicalSimulationResultCard(
        _ simulation: HistoricalSimulationResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            // -----------------------------------------
            // Simulation summary
            // -----------------------------------------

            VStack(
                alignment: .leading,
                spacing: 12
            ) {

                HStack {
                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {
                        Text(
                            "Historical \(simulation.year) Cellular Automaton"
                        )
                        .font(.headline)

                        Text(
                            "100 generations"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(
                        simulation.result.riskLevel.rawValue
                    )
                    .font(.headline)
                    .foregroundStyle(
                        riskColor(
                            simulation.result.systemicRisk
                        )
                    )
                }

                HStack {
                    metric(
                        title: "Equilibrium",
                        value:
                            percent(
                                simulation.result.equilibriumPressure
                            )
                    )

                    metric(
                        title: "Volume",
                        value:
                            percent(
                                simulation.result.volumePressure
                            )
                    )

                    metric(
                        title: "Cell Stress",
                        value:
                            percent(
                                simulation.result.cellularStress
                            )
                    )

                    metric(
                        title: "Systemic",
                        value:
                            percent(
                                simulation.result.systemicRisk
                            )
                    )
                }

                Divider()

                HStack {
                    metric(
                        title: "Critical",
                        value:
                            percent(
                                simulation.result.criticalFraction
                            )
                    )

                    metric(
                        title: "Crashed",
                        value:
                            percent(
                                simulation.result.crashFraction
                            )
                    )
                }
            }
            .padding()
            .background(
                .thinMaterial,
                in: RoundedRectangle(
                    cornerRadius: 16
                )
            )

            // -----------------------------------------
            // Final cellular automaton state
            // -----------------------------------------

            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                Text("Final CA State")
                    .font(.headline)

                Text(
                    "The lattice shown below is the final state produced by the historical simulation."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

                cellGrid(
                    cells: simulation.cells
                )

                stateLegendView
            }
            .padding()
            .background(
                .thinMaterial,
                in: RoundedRectangle(
                    cornerRadius: 16
                )
            )

            // -----------------------------------------
            // Historical propagation
            // -----------------------------------------

            if let analysis =
                historicalAnalyses.first(where: {
                    $0.year == simulation.year
                }),
               analysis.frames.count > 1 {

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Text("Propagation")
                        .font(.headline)

                    historicalFilmstrip(
                        frames: analysis.frames
                    )
                }
                .padding()
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 16
                    )
                )
            }

            // -----------------------------------------
            // Model pipeline
            // -----------------------------------------

            modelPipelineCard(
                year: simulation.year
            )
        }
    }

    @ViewBuilder
    private func yearGroup(year: Int) -> some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            yearSectionHeader(
                year: year,
                subtitle:
                    year == selectedYear
                    ? "Current simulation year"
                    : "Historical crash year"
            )

            if year == selectedYear {
                currentInformationCard
            } else {
                if let simulation =
                    historicalSimulationResults.first(where: {
                        $0.year == year
                    }) {

                    historicalSimulationResultCard(
                        simulation
                    )
                }
            }
        }
    }


    private func runAllHistoricalYears() {

        historicalSimulationResults.removeAll(
            keepingCapacity: true
        )

        for year in allYears {

            let scenario = scenarioForYear(year)

            let equilibriumPressure = min(
                max(
                    moneyPolicyChangeImpact,
                    0.0
                ),
                1.0
            )

            let volumePressure = min(
                max(
                    growthVolumePercent / 100.0,
                    0.0
                ),
                1.0
            )

            engine.resetCells()

            let simulationResult = engine.runYear(
                year: year,
                iterations: 100,
                equilibriumPressure: equilibriumPressure,
                volumePressure: volumePressure,
                scenario: scenario
            
            )

            let finalCells = engine.cells

            historicalSimulationResults.append(
                HistoricalSimulationResult(
                    year: year,
                    result: simulationResult,
                    cells: finalCells
                )
            )
        }
    }


    // MARK: - Year Header

    private func yearSectionHeader(
        year: Int,
        subtitle: String
    ) -> some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(
                    "\(year)"
                )
                .font(
                    .title2.bold()
                )

                Text(
                    subtitle
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }

            Spacer()

            if selectedYear == year {

                Text("SELECTED")
                    .font(
                        .caption2.bold()
                    )
                    .padding(
                        .horizontal,
                        8
                    )
                    .padding(
                        .vertical,
                        4
                    )
                    .background(
                        Color.accentColor.opacity(
                            0.15
                        ),
                        in: Capsule()
                    )
            }
        }
        .padding(
            .horizontal,
            4
        )
    }

    // MARK: - Information Card

    private var currentInformationCard: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            scenarioCard

            if let result {

                equilibriumCard(
                    result
                )

                cellularAutomatonCard

                localFinancialStructureCard

                contagionCard

                riskCard(
                    result
                )

                dynamicsCard
            }

            modelPipelineCard(
                year: selectedYear
            )
        }
    }

    // MARK: - Historical Information Card

    private func historicalYearInformationCard(
        _ analysis: HistoricalCrashAnalysis
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            historicalCrashPanel(
                analysis
            )

            modelPipelineCard(
                year: analysis.year
            )
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(
                "Market Exhaustion Model"
            )
            .font(.title2.bold())

            Text(
                "Historical stress → local instability → contagion → systemic transition"
            )
            .font(.subheadline)
            .foregroundStyle(
                .secondary
            )

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
            .foregroundStyle(
                .secondary
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Scenario Card

    private var scenarioCard: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "\(selectedYear) Scenario"
            )
            .font(.headline)

            Text(
                "Current market inputs"
            )
            .font(
                .subheadline.bold()
            )

            Divider()

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
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Scenario Value

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
            .foregroundStyle(
                .secondary
            )
        }
    }

    // MARK: - Equilibrium

    private func equilibriumCard(
        _ result: MarketRiskResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "Equilibrium / Momentum"
            )
            .font(.headline)

            HStack {

                metric(
                    title: "Equilibrium",
                    value:
                        percent(
                            result.equilibriumPressure
                        )
                )

                metric(
                    title: "Volume Pressure",
                    value:
                        percent(
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
            .foregroundStyle(
                .secondary
            )

            ProgressView(
                value:
                    bounded(
                        result.equilibriumPressure
                    )
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Cellular Automaton

    private var cellularAutomatonCard: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Cellular Automaton — 100 Generations"
            )
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
            .foregroundStyle(
                .secondary
            )

            cellGrid(
                cells: engine.cells
            )

            stateLegendView
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Historical Crash Panel

    private func historicalCrashPanel(
        _ analysis: HistoricalCrashAnalysis
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text(
                        "\(analysis.year) Crash-Year State"
                    )
                    .font(.headline)

                    Text(
                        "\(analysis.intervalYears) historical years analyzed"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }

                Spacer()

                Text(
                    analysis.result.riskLevel.rawValue
                )
                .font(.headline)
                .foregroundStyle(
                    riskColor(
                        analysis.result.systemicRisk
                    )
                )
            }

            HStack {

                metric(
                    title: "Equilibrium",
                    value:
                        percent(
                            analysis.result.equilibriumPressure
                        )
                )

                metric(
                    title: "Volume",
                    value:
                        percent(
                            analysis.result.volumePressure
                        )
                )

                metric(
                    title: "Cell Stress",
                    value:
                        percent(
                            analysis.result.cellularStress
                        )
                )

                metric(
                    title: "Systemic",
                    value:
                        percent(
                            analysis.result.systemicRisk
                        )
                )
            }

            Divider()

            Text(
                "Final CA State"
            )
            .font(
                .subheadline.bold()
            )

            cellGrid(
                cells: analysis.cells
            )

            stateLegendView

            if analysis.frames.count > 1 {

                Text(
                    "Propagation"
                )
                .font(
                    .subheadline.bold()
                )

                historicalFilmstrip(
                    frames: analysis.frames
                )
            }

            HStack {

                metric(
                    title: "Critical",
                    value:
                        percent(
                            analysis.result.criticalFraction
                        )
                )

                metric(
                    title: "Crashed",
                    value:
                        percent(
                            analysis.result.crashFraction
                        )
                )
            }
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Local Financial Structure

    private var localFinancialStructureCard: some View {

        let cells = engine.cells

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Local Financial Structure"
            )
            .font(.headline)

            financialMetric(
                "Liquidity Buffer",
                mean(
                    cells.map {
                        $0.liquidity
                    }
                )
            )

            financialMetric(
                "Capital Buffer",
                mean(
                    cells.map {
                        $0.capital
                    }
                )
            )

            financialMetric(
                "Fragility / Leverage",
                mean(
                    cells.map {
                        $0.fragility
                    }
                )
            )

            financialMetric(
                "Macro Exposure",
                mean(
                    cells.map {
                        $0.macroExposure
                    }
                )
            )

            financialMetric(
                "Recovery Capacity",
                mean(
                    cells.map {
                        $0.recoveryCapacity
                    }
                )
            )

            financialMetric(
                "Local Shock Susceptibility",
                mean(
                    cells.map {
                        $0.localShockSusceptibility
                    }
                )
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Financial Metric

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
                value:
                    bounded(value)
            )
        }
    }

    // MARK: - Contagion

    private var contagionCard: some View {

        let cells = engine.cells

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Contagion"
            )
            .font(.headline)

            HStack {

                metric(
                    title: "Mean Contagion",
                    value:
                        percent(
                            mean(
                                cells.map {
                                    $0.contagion
                                }
                            )
                        )
                )

                metric(
                    title: "Stressed",
                    value:
                        percent(
                            fraction(
                                cells
                            ) {
                                $0.state == .stressed
                            }
                        )
                )

                metric(
                    title: "Critical",
                    value:
                        percent(
                            fraction(
                                cells
                            ) {
                                $0.state == .critical
                            }
                        )
                )

                metric(
                    title: "Crashed",
                    value:
                        percent(
                            fraction(
                                cells
                            ) {
                                $0.state == .crashed
                            }
                        )
                )
            }

            Text(
                """
                Contagion is transmitted from neighboring market cells.
                Local vulnerability amplifies transmitted stress.
                """
            )
            .font(.footnote)
            .foregroundStyle(
                .secondary
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Risk

    private func riskCard(
        _ result: MarketRiskResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Emergent Systemic Stress"
            )
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

                Text(
                    result.riskLevel.rawValue
                )
                .font(.headline)
                .foregroundStyle(
                    riskColor(
                        result.systemicRisk
                    )
                )
            }

            ProgressView(
                value:
                    bounded(
                        result.systemicRisk
                    )
            )

            HStack {

                metric(
                    title: "Cellular Stress",
                    value:
                        percent(
                            result.cellularStress
                        )
                )

                metric(
                    title: "Critical Cells",
                    value:
                        percent(
                            result.criticalFraction
                        )
                )

                metric(
                    title: "Crashed Cells",
                    value:
                        percent(
                            result.crashFraction
                        )
                )
            }
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Dynamics

    private var dynamicsCard: some View {

        let cells = engine.cells

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Collective CA Dynamics"
            )
            .font(.headline)

            HStack {

                metric(
                    title: "Energy",
                    value:
                        percent(
                            mean(
                                cells.map {
                                    $0.energy
                                }
                            )
                        )
                )

                metric(
                    title: "Momentum",
                    value: percent(
                        mean(
                            cells.map { $0.momentum }
                        )
                    )
                )
            }

            HStack {

                metric(
                    title: "Exhaustion",
                    value:
                        percent(
                            mean(
                                cells.map {
                                    $0.exhaustion
                                }
                            )
                        )
                )

                metric(
                    title: "Stress",
                    value:
                        percent(
                            mean(
                                cells.map {
                                    $0.stress
                                }
                            )
                        )
                )

                metric(
                    title: "Potential",
                    value:
                        percent(
                            mean(
                                cells.map {
                                    $0.financialPotential
                                }
                            )
                        )
                )
            }
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // MARK: - Historical Filmstrip

    private func historicalFilmstrip(
        frames: [HistoricalCAFrame]
    ) -> some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(
                alignment: .top,
                spacing: 10
            ) {

                ForEach(frames) { frame in

                    VStack(
                        spacing: 4
                    ) {

                        miniCellGrid(
                            cells: frame.cells
                        )
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 4
                            )
                            .stroke(
                                frame.isCrashYear
                                    ? Color.purple
                                    : Color.clear,
                                lineWidth: 2
                            )
                        )

                        Text(
                            frame.isCrashYear
                                ? "\(frame.year) · CRASH"
                                : "\(frame.year)"
                        )
                        .font(.caption2)
                        .foregroundStyle(
                            frame.isCrashYear
                                ? Color.purple
                                : Color.secondary
                        )
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Mini Grid

    private func miniCellGrid(
        cells: [MarketCell],
        size: CGFloat = 90
    ) -> some View {

        let width = max(
            Int(
                sqrt(
                    Double(
                        max(
                            cells.count,
                            1
                        )
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
                        spacing: 1
                    ),
                count: width
            ),
            spacing: 1
        ) {

            ForEach(cells) { cell in

                Rectangle()
                    .fill(
                        cellColor(
                            cell.state
                        )
                    )
                    .aspectRatio(
                        1,
                        contentMode: .fit
                    )
            }
        }
        .frame(
            width: size,
            height: size
        )
    }

    // MARK: - Full Grid

    private func cellGrid(
        cells: [MarketCell]
    ) -> some View {

        let width = max(
            Int(
                sqrt(
                    Double(
                        max(
                            cells.count,
                            1
                        )
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

    // MARK: - Pipeline

    private func modelPipelineCard(
        year: Int
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(
                "\(year) Model Pipeline"
            )
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
                The cellular automaton provides the evolving local and
                collective state for \(year). The crash interval is
                metadata rather than the mechanism that determines when
                cells fail.
                """
            )
            .font(.footnote)
            .foregroundStyle(
                .secondary
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

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

    // MARK: - State Legend

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

        HStack(
            spacing: 3
        ) {

            Circle()
                .fill(color)
                .frame(
                    width: 7,
                    height: 7
                )

            Text(title)
        }
    }

    // MARK: - Cell Color

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

    // MARK: - Risk Color

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

    // MARK: - Metric

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
                .foregroundStyle(
                    .secondary
                )
        }
        .frame(
            maxWidth: .infinity
        )
    }

    // MARK: - Run Selected Year

    private func rerunSelectedYear() {

        runSimulation(
            year: selectedYear
        )
    }

    private func runSimulation(
        year: Int
    ) {

        let scenario =
            scenarioForYear(
                year
            )

        let equilibriumPressure =
            min(
                max(
                    moneyPolicyChangeImpact,
                    0.0
                ),
                1.0
            )

        let volumePressure =
            min(
                max(
                    growthVolumePercent / 100.0,
                    0.0
                ),
                1.0
            )

        engine.resetCells()

        /*
         IMPORTANT:

         The engine currently needs a year-aware run method.

         The desired call is:

         result = engine.run(
             iterations: 100,
             year: year,
             equilibriumPressure: equilibriumPressure,
             volumePressure: volumePressure,
             scenario: scenario
         )

         Add `year: Int` to MarketExhaustionEngine.run().
        */

        result = engine.runYear(
            year:selectedYear,
            iterations: 100,
            equilibriumPressure:
                equilibriumPressure,
            volumePressure:
                volumePressure,
            scenario:
                scenario
        )
    }

    // MARK: - Scenario For Year

    private func scenarioForYear(
        _ year: Int
    ) -> MarketScenario {

        if year == selectedYear {

            return MarketScenario(

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
        }

        /*
         Historical years are represented by
         historicalAnalyses.

         The engine should ultimately provide the
         HistoricalYear inputs for this year rather
         than using the 2026 inputs.

         Until that engine interface is exposed,
         return the existing scenario structure.
        */

        return MarketScenario(

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
    }

    // MARK: - Historical Data

    private func loadHistoricalMatrix() {

        historicalAnalyses =
            engine.analyzeAllHistoricalCrashes()
    }

    // MARK: - Helpers

    private func bounded(
        _ value: Double
    ) -> Double {

        guard value.isFinite else {
            return 0
        }

        return min(
            max(
                value,
                0
            ),
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
        ) / Double(
            values.count
        )
    }

    private func fraction(
        _ cells: [MarketCell],
        where predicate:
            (MarketCell) -> Bool
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

#Preview {
    ContentView()
}
