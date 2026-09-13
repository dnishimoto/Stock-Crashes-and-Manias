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
    // MARK: Fixed Current Scenario
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
    // MARK: Canonical Results
    // ========================================================

    @State private var result = ContentView.defaultResult()

    @State private var historicalAnalyses: [HistoricalAnalysis] = []

    // One canonical CA engine.
    private let engine = MarketExhaustionEngine()

    private let historicalEngine = HistoricalMarketEngine()

    // ========================================================
    // MARK: Historical CA Rows
    // ========================================================

    private var historicalCARows: [HistoricalCARow] {

        historicalEngine.periods.compactMap { period in

            let result = historicalEngine.caAnalysis(
                for: period,
                using: engine
            )

            let analysis = historicalEngine.analysis(
                for: period
            )

            let cells = engine.cells

            return HistoricalCARow(
                period: period,
                analysis: analysis,
                result: result,
                cells: cells
            )
        }
    }

    // ========================================================
    // MARK: Body
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
            .navigationTitle(
                "Stock Crashes and Manias"
            )
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {
                        runSimulation()
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

                runSimulation()
            }
        }
    }

    // ========================================================
    // MARK: Historical Section
    // ========================================================

    private var historicalSection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Text(
                "Historical Crash-Year Analysis with Current Scenario Parameters"
            )
            .font(.title2.bold())

            Text(
                """
                Each historical crash year is evaluated using the current
                scenario inputs except that the year is replaced by the
                historical crash year. The cellular automaton is evaluated
                from the historical context selected by the engine.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            ForEach(historicalCARows) { row in

                historicalCrashPanel(
                    analysis: row.analysis,
                    result: row.result,
                    cells: row.cells
                )
            }
        }
    }

    // ========================================================
    // MARK: Historical Crash Panel
    // ========================================================

    @ViewBuilder
    private func historicalCrashPanel(
        analysis: HistoricalAnalysis,
        result: MarketRiskResult,
        cells: [MarketCell]
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
                        "Crash Year \(analysis.crashYear)"
                    )
                    .font(.title3.bold())

                    Text(
                        "Model state for crash year \(analysis.crashYear)"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text(
                    percent(
                        analysis.powerLaw
                    )
                )
                .font(
                    .headline.monospacedDigit()
                )
            }

            historicalPowerLawCard(
                analysis: analysis,
                result: result
            )

            historicalCellularAutomatonCard(
                cells: cells
            )

            historicalRiskCard(
                result: result
            )

            historicalYearSummaryCard(
                analysis: analysis,
                result: result
            )
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 18
            )
        )
    }

    // ========================================================
    // MARK: Historical Power Law
    // ========================================================

    private func historicalPowerLawCard(
        analysis: HistoricalAnalysis,
        result: MarketRiskResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Equilibrium & Power Law"
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

                metric(
                    title: "Power Law",
                    value:
                        percent(
                            analysis.powerLaw
                        )
                )
            }

            Divider()

            HStack {

                metric(
                    title: "Cellular Stress",
                    value:
                        percent(
                            result.cellularStress
                        )
                )

              
                metric(
                    title: "Risk",
                    value:
                        percent(
                            result.systemicRisk
                        )
                )
            }

            Text(
                "Equilibrium is the point where market expansion begins "
                + "losing momentum, while volume pressure reflects trading "
                + "volume expansion feeding into the cellular automaton. "
                + "Cellular stress and power-law behavior describe the "
                + "system's modeled proximity to a critical release."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            Text(
                "The historical power-law coefficient is a model parameter. "
                + "It is not interpreted as a crash probability."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            Color.secondary.opacity(0.06),
            in: RoundedRectangle(
                cornerRadius: 12
            )
        )
    }

    // ========================================================
    // MARK: Historical Cellular Automaton
    // ========================================================

    private func historicalCellularAutomatonCard(
        cells: [MarketCell]
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Cellular Automaton"
            )
            .font(.headline)

            Text(
                "Each cell carries local energy, momentum, exhaustion, "
                + "stress and financial potential. Neighboring cells "
                + "allow local conditions to propagate through the "
                + "modeled market."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            cellGrid(
                cells: cells
            )

            stateLegendView
        }
        .padding()
        .background(
            Color.secondary.opacity(0.06),
            in: RoundedRectangle(
                cornerRadius: 12
            )
        )
    }

    // ========================================================
    // MARK: Historical Risk
    // ========================================================

    private func historicalRiskCard(
        result: MarketRiskResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Emergent Systemic Risk"
            )
            .font(.headline)

            riskHeader(
                result: result
            )

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


              
            }


            Text(
                "Systemic risk is an emergent cellular-automaton signal "
                + "derived from cellular stress, critical-cell concentration "
                + "and crashed cells. It is not calculated directly from "
                + "any single historical input."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            Text(
                "This is an exploratory systems-dynamics signal, not a "
                + "probability that a market crash will occur."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            Color.secondary.opacity(0.06),
            in: RoundedRectangle(
                cornerRadius: 12
            )
        )
    }

    // ========================================================
    // MARK: Historical Year Summary
    // ========================================================

    private func historicalYearSummaryCard(
        analysis: HistoricalAnalysis,
        result: MarketRiskResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(
                "Crash-Year Model Summary"
            )
            .font(.headline)

            Text(
                "For \(analysis.crashYear), the model combines "
                + "historical monetary and market expansion with "
                + "momentum, equilibrium, power-law behavior and "
                + "cellular-automaton dynamics."
            )

            Text(
                "Equilibrium: "
                + percent(result.equilibriumPressure)
                + " • Power law: "
                + percent(analysis.powerLaw)
            )

          

         
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding()
        .background(
            Color.secondary.opacity(0.06),
            in: RoundedRectangle(
                cornerRadius: 12
            )
        )
    }

    // ========================================================
    // MARK: Header
    // ========================================================

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
                "Fuel → momentum → equilibrium → exhaustion → release"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Divider()

            Text(
                "The model treats rapid monetary and market expansion as fuel. "
                + "The important signal is not time alone, but the point where "
                + "additional fuel produces less momentum and equilibrium begins "
                + "to turn toward exhaustion."
            )
            .font(.footnote)
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // ========================================================
    // MARK: Scenario
    // ========================================================

    private var scenarioCard: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "Current Scenario"
            )
            .font(.headline)

            Text(
                "Simulation Year: \(selectedYear)"
            )
            .font(.subheadline.bold())

            Divider()

            Text(
                "Model Inputs"
            )
            .font(.subheadline.bold())

            Text(
                "The current engine derives its canonical analysis from "
                + "the simulation year and historical crash records. "
                + "The macro inputs below remain displayed as scenario "
                + "context until they are explicitly connected to the "
                + "engine."
            )
            .font(.caption)
            .foregroundStyle(.secondary)

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
                "Crash Interval",
                value: crashInterval,
                suffix: " years"
            )

            scenarioValue(
                "External Shock",
                value: externalShockPercent,
                suffix: "%"
            )

            Button {

                runSimulation()

            } label: {

                Text(
                    "Run Simulation"
                )
                .frame(
                    maxWidth: .infinity
                )
            }
            .buttonStyle(
                .borderedProminent
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

    // ========================================================
    // MARK: Scenario Value
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
                    format: "%.1f",
                    value
                ) + suffix
            )
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
    }

    // ========================================================
    // MARK: Current Scenario
    // ========================================================

    private var currentScenarioSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "Current Scenario Result"
            )
            .font(.title3.bold())

            equilibriumCard

            cellularAutomatonCard

            riskCard
        }
    }

    // ========================================================
    // MARK: Current Equilibrium
    // ========================================================

    private var equilibriumCard: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "Equilibrium Turn in Momentum"
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

            Text(
                "Equilibrium is the model's estimate of the point where "
                + "market expansion begins losing momentum. Volume pressure "
                + "reflects trading-volume expansion feeding into the "
                + "cellular automaton alongside it."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            HStack {

                Text(
                    "Current equilibrium"
                )

                Spacer()

                Text(
                    percent(
                        result.equilibriumPressure
                    )
                )
                .font(.title.bold())
            }

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

    // ========================================================
    // MARK: Current Cellular Automaton
    // ========================================================

    private var cellularAutomatonCard: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Cellular Automaton"
            )
            .font(.headline)

            Text(
                "Each cell carries a local market state. Energy, momentum, "
                + "exhaustion, stress and financial potential evolve through "
                + "local neighbor interactions."
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
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // ========================================================
    // MARK: Cell Grid
    // ========================================================

    private func cellGrid(
        cells: [MarketCell]
    ) -> some View {

        LazyVGrid(
            columns:
                Array(
                    repeating:
                        GridItem(
                            .flexible(),
                            spacing: 2
                        ),
                    count: 20
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
    }

    // ========================================================
    // MARK: State Legend
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

    // ========================================================
    // MARK: Current Risk
    // ========================================================

    private var riskCard: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Systemic Risk"
            )
            .font(.headline)

            riskHeader(
                result: result
            )

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

               
            }


            Text(
                "Exploratory cellular-automaton signal. "
                + "It is not a probability that a crash will occur."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // ========================================================
    // MARK: Risk Header
    // ========================================================

    private func riskHeader(
        result: MarketRiskResult
    ) -> some View {

        HStack {


            Text(
                percent(
                    result.systemicRisk
                )
            )
            .font(.title2.bold())
            .monospacedDigit()
        }
    }

    // ========================================================
    // MARK: Historical Matrix
    // ========================================================

    private var historicalMatrixCard: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(
                "Historical Equilibrium Matrix"
            )
            .font(.headline)

            Text(
                "Each row applies the historical equilibrium "
                + "calculation to the years immediately preceding a crash."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            ScrollView(
                .horizontal,
                showsIndicators: true
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    matrixHeader

                    ForEach(
                        historicalAnalyses
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
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // ========================================================
    // MARK: Matrix Header
    // ========================================================

    private var matrixHeader: some View {

        HStack(spacing: 0) {

            matrixText(
                "Crash",
                width: 55
            )

            matrixText(
                "M2%",
                width: 60
            )

            matrixText(
                "Infl%",
                width: 60
            )

            matrixText(
                "Bond%",
                width: 60
            )

            matrixText(
                "Vol%",
                width: 65
            )

            matrixText(
                "Opt",
                width: 55
            )

            matrixText(
                "Momentum",
                width: 75
            )

            matrixText(
                "TURN",
                width: 65
            )

            matrixText(
                "EQUILIBRIUM",
                width: 100
            )

            matrixText(
                "POWER",
                width: 75
            )
        }
    }

    // ========================================================
    // MARK: Matrix Row
    // ========================================================

    private func matrixRow(
        _ analysis: HistoricalAnalysis
    ) -> some View {

        HStack(spacing: 0) {

            matrixText(
                "\(analysis.crashYear)",
                width: 55
            )

            matrixText(
                percent(
                    analysis.m2Growth
                ),
                width: 60
            )

            matrixText(
                percent(
                    analysis.inflation
                ),
                width: 60
            )

            matrixText(
                percent(
                    analysis.bondYield
                ),
                width: 60
            )

            matrixText(
                percent(
                    analysis.stockVolumeGrowth
                ),
                width: 65
            )

            matrixText(
                percent(
                    analysis.optimism
                ),
                width: 55
            )

            matrixText(
                percent(
                    analysis.momentum
                ),
                width: 75
            )

            matrixText(
                percent(
                    analysis.momentumTurn
                ),
                width: 65
            )

            Text(
                percent(
                    analysis.equilibrium
                )
            )
            .font(.headline)
            .frame(
                width: 100,
                alignment: .trailing
            )

            matrixText(
                percent(
                    analysis.powerLaw
                ),
                width: 75
            )
        }
        .padding(.vertical, 4)
        .background(
            analysis.equilibrium >= 0.65
            ? Color.red.opacity(0.12)
            : Color.clear
        )
    }

    // ========================================================
    // MARK: Matrix Text
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
    // MARK: Model Summary
    // ========================================================

    private var modelSummaryCard: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(
                "Model Summary"
            )
            .font(.headline)

            Text(
                "1. Money supply growth supplies potential fuel."
            )

            Text(
                "2. Stock growth and volume indicate how strongly "
                + "the fuel is being converted into market momentum."
            )

            Text(
                "3. Equilibrium occurs when momentum begins losing "
                + "acceleration while pressure continues increasing."
            )

            Text(
                "4. Inflation, taxation pressure and stock-growth "
                + "slowdown increase internal exhaustion."
            )

            Text(
                "5. The cellular automaton spreads local exhaustion "
                + "through neighboring market cells."
            )

            Text(
                "6. Crash interval is a weak cycle contributor, "
                + "not a prediction clock."
            )

            Text(
                "7. Financial potential represents the modeled "
                + "local resistance or accumulated market pressure."
            )
        }
        .font(.footnote)
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    // ========================================================
    // MARK: Metric
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
    // MARK: State Legend
    // ========================================================

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
    // MARK: Cell Color
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
    // MARK: Risk Color
    // ========================================================

    private func riskColor(
        _ value: Double
    ) -> Color {

        switch value {

        case 0..<0.40:
            return .green

        case 0.40..<0.65:
            return .orange

        case 0.65..<0.80:
            return .red

        default:
            return .purple
        }
    }

    // ========================================================
    // MARK: Bounded Value
    // ========================================================

    private func bounded(
        _ value: Double
    ) -> Double {

        guard value.isFinite else {
            return 0.0
        }

        return min(
            max(
                value,
                0.0
            ),
            1.0
        )
    }

    // ========================================================
    // MARK: Percent
    // ========================================================

    private func percent(
        _ value: Double
    ) -> String {

        String(
            format: "%.1f%%",
            value * 100.0
        )
    }

    // ========================================================
    // MARK: Run Simulation
    // ========================================================

    private func runSimulation() {

        result =
            engine.analyze(
                currentYear:
                    selectedYear
            )
    }

    // ========================================================
    // MARK: Historical Matrix
    // ========================================================

    private func loadHistoricalMatrix() {

        historicalAnalyses =
            historicalEngine.periods.map { period in

                historicalEngine.analysis(
                    for: period
                )
            }
    }

    // ========================================================
    // MARK: Default Result
    // ========================================================

    private static func defaultResult()
        -> MarketRiskResult
    {

        MarketExhaustionEngine().analyze(
            currentYear: 2026
        )
    }
}

// ============================================================
// MARK: - Preview
// ============================================================

#Preview {

    ContentView()
}
