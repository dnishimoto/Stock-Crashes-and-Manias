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

    // The UI is based on MarketRiskResult, the engine's single
    // canonical result type shared by current and historical
    // analysis.
    @State private var result =
        ContentView.defaultResult()

    @State private var historicalAnalyses:
        [HistoricalAnalysis] = []

    // One canonical CA engine.
    private let engine =
        MarketExhaustionEngine()

    private let historicalEngine =
        HistoricalMarketEngine()

    // ========================================================
    // MARK: All Crash Results
    // ========================================================

    private var allCrashResults: [
        (
            period: HistoricalCrashPeriod,
            result: MarketRiskResult,
            cells: [MarketCell]
        )
    ] {

        historicalEngine.periods.compactMap { period in

            let result = historicalEngine.caAnalysis(
                for: period,
                using: engine
            )

            let cells = engine.cells

            return (
                period: period,
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
                            historical crash year. This allows exploration of how the
                            model behaves at historical crash points.
                            """
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                        ForEach(
                            allCrashResults,
                            id: \.period.id
                        ) { entry in

                            historicalCrashPanel(
                                analysis:
                                    historicalEngine.analysis(
                                        for: entry.period
                                    ),
                                result:
                                    entry.result,
                                cells:
                                    entry.cells
                            )
                        }
                    }

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
    // MARK: Current Scenario Section
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
                        "Model state for crash year \(analysis.crashYear) using current scenario parameters"
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
                    title: "Alpha",
                    value:
                        String(
                            format: "%.2f",
                            result.alpha
                        )
                )

                metric(
                    title: "Years Since Crash",
                    value:
                        "\(result.yearsSinceCrash)"
                )
            }

            Text(
                "Equilibrium is the point where market expansion begins "
                + "losing momentum, while volume pressure reflects trading-"
                + "volume expansion feeding into the cellular automaton. "
                + "Cellular stress and the power-law alpha describe how "
                + "close the system is to a critical release."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            Text(
                "The historical power-law coefficient remains a separate "
                + "historical-model parameter. It is not interpreted as "
                + "a crash probability."
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
                "Each cell represents a local market state carrying "
                + "energy, momentum, equilibrium, exhaustion and stress. "
                + "Neighboring cells allow local stress and exhaustion "
                + "to propagate through the modeled market."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

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

                ForEach(
                    cells
                ) { cell in

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

            HStack {

                Text(
                    result.riskLevel
                )
                .font(.title3.bold())
                .foregroundStyle(
                    riskColor(
                        result.systemicRisk
                    )
                )

                Spacer()

                Text(
                    percent(
                        result.systemicRisk
                    )
                )
                .font(.title3.bold())
                .monospacedDigit()
            }

            ProgressView(
                value:
                    min(
                        max(
                            result.systemicRisk,
                            0.0
                        ),
                        1.0
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
                    title: "Critical",
                    value:
                        percent(
                            result.criticalFraction
                        )
                )

                metric(
                    title: "Crashed",
                    value:
                        percent(
                            result.crashFraction
                        )
                )
            }

            HStack {

                metric(
                    title: "Alpha",
                    value:
                        String(
                            format: "%.2f",
                            result.alpha
                        )
                )

                metric(
                    title: "Years Since Crash",
                    value:
                        "\(result.yearsSinceCrash)"
                )

                metric(
                    title: "Window",
                    value:
                        "\(result.predictedWindowStart)–\(result.predictedWindowEnd)"
                )
            }

            Text(
                "Systemic risk is an emergent cellular-automaton signal "
                + "derived from cellular stress, critical-cell "
                + "concentration and crashed cells. It is not calculated "
                + "directly from any single historical input."
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
                + "cellular-automaton risk."
            )

            Text(
                "Equilibrium: \(percent(result.equilibriumPressure)) • "
                + "Power law: \(percent(analysis.powerLaw))"
            )

            Text(
                "Cellular stress: \(percent(result.cellularStress)) • "
                + "Critical: \(percent(result.criticalFraction)) • "
                + "Crashed: \(percent(result.crashFraction))"
            )

            Text(
                "Systemic risk: \(percent(result.systemicRisk)) "
                + "(\(result.riskLevel)) • Window: "
                + "\(result.predictedWindowStart)–\(result.predictedWindowEnd)"
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
                "The engine currently derives its analysis from the "
                + "simulation year and its own historical crash records. "
                + "The macro inputs below are not yet wired into that "
                + "calculation."
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
                    format: "%.1f%@",
                    value,
                    suffix
                )
            )
            .monospacedDigit()
            .foregroundStyle(.secondary)
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
                    max(
                        0,
                        min(
                            1,
                            result.equilibriumPressure
                        )
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
                "Each cell carries a local market state. Neighboring "
                + "cells transmit stress and exhaustion, driving the "
                + "critical and crashed fractions shown below."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

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

                ForEach(
                    engine.cells
                ) { cell in

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
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 16
            )
        )
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

            HStack {

                Text(
                    result.riskLevel
                )
                .font(.title.bold())
                .foregroundStyle(
                    riskColor(
                        result.systemicRisk
                    )
                )

                Spacer()

                Text(
                    percent(
                        result.systemicRisk
                    )
                )
                .font(.title2.bold())
            }

            ProgressView(
                value:
                    min(
                        max(
                            result.systemicRisk,
                            0.0
                        ),
                        1.0
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
                    title: "Critical",
                    value:
                        percent(
                            result.criticalFraction
                        )
                )

                metric(
                    title: "Crashed",
                    value:
                        percent(
                            result.crashFraction
                        )
                )
            }

            HStack {

                metric(
                    title: "Alpha",
                    value:
                        String(
                            format: "%.2f",
                            result.alpha
                        )
                )

                metric(
                    title: "Years Since Crash",
                    value:
                        "\(result.yearsSinceCrash)"
                )

                metric(
                    title: "Window",
                    value:
                        "\(result.predictedWindowStart)–\(result.predictedWindowEnd)"
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
    // MARK: Summary
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
    // MARK: Percent
    // ========================================================

    private func percent(
        _ value: Double
    ) -> String {

        String(
            format: "%.1f%%",
            value * 100
        )
    }

    // ========================================================
    // MARK: Run Simulation
    // ========================================================

    private func runSimulation() {

        // The canonical engine now exposes a single
        // analyze(currentYear:) entry point returning
        // MarketRiskResult. It no longer accepts the manual
        // macro inputs below directly — see the note on
        // scenarioCard.
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
            historicalEngine.periods.map {

                historicalEngine.analysis(
                    for: $0
                )
            }
    }

    // ========================================================
    // MARK: Default Result
    // ========================================================

    private static func defaultResult()
        -> MarketRiskResult {

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
