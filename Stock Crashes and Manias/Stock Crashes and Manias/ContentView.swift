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
// MARK: Content View
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

    @State private var result =
        ContentView.defaultResult()

    @State private var historicalAnalyses:
        [HistoricalAnalysis] = []

    private let engine =
        MarketExhaustionEngine()

    private let historicalEngine =
        HistoricalMarketEngine()

    // ========================================================
    // MARK: All Crash Results
    //
    // Every historical crash year is evaluated using the
    // current fixed scenario parameters.
    //
    // Each result also captures the complete cellular-automaton
    // history leading into that crash year.
    // ========================================================

    private var allCrashResults:
        [(
            period: HistoricalCrashPeriod,
            result: HistoricalCAResult,
            cells: [MarketCell],
            historicalFrames: [HistoricalCAFrame]
        )] {

        historicalEngine.periods
            .sorted { $0.crashYear < $1.crashYear }
            .map { period in

                let result = historicalEngine.caAnalysis(
                    for: period,
                    using: engine
                )

                // caAnalysis() leaves the engine containing the
                // historical CA sequence. Capture it before the
                // engine is reused for the next crash period.
                let frames = engine.historicalFrames

                // The CA result does not contain cells.
                // The engine owns the final CA cells.
                let cells = engine.cells

                return (
                    period: period,
                    result: result,
                    cells: cells,
                    historicalFrames: frames
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

                    // ------------------------------------------------
                    // Current scenario
                    // ------------------------------------------------

                    currentScenarioSection

                    // ------------------------------------------------
                    // Historical crash-year panels
                    // ------------------------------------------------

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
                                analysis: historicalEngine.analysis(
                                    for: entry.period
                                ),
                                result: entry.result,
                                cells: entry.cells,
                                historicalFrames: entry.historicalFrames
                            )
                        }
                    }

                    // ------------------------------------------------
                    // Historical matrix
                    // ------------------------------------------------

                    historicalMatrixCard

                    modelSummaryCard

                    //.disclaimerCard
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
                            systemName: "arrow.clockwise"
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

            Text("Current Scenario Result")
                .font(.title3.bold())

            equilibriumCard
            energyCard
            exhaustionCard
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
        result: HistoricalCAResult,
        cells: [MarketCell],
        historicalFrames: [HistoricalCAFrame]
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

            historicalEnergyCard(
                result: result
            )

            historicalExhaustionCard(
                result: result
            )

            historicalCellularAutomatonCard(
                result: result
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

    // ========================================================
    // MARK: Historical Financial Gravity
    // ========================================================

    private func historicalPowerLawCard(
        analysis: HistoricalAnalysis,
        result: HistoricalCAResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Financial Gravity & Equilibrium")
                .font(.headline)

            HStack {

                metric(
                    title: "Equilibrium",
                    value: percent(
                        result.equilibriumPressure
                    )
                )

                metric(
                    title: "Inflection",
                    value: percent(
                        result.equilibriumInflection
                    )
                )

                metric(
                    title: "Power Law",
                    value: percent(
                        analysis.powerLaw
                    )
                )
            }

            Divider()

            HStack {

                metric(
                    title: "Potential",
                    value: percent(
                        result.financialPotential
                    )
                )

                metric(
                    title: "Gradient",
                    value: percent(
                        abs(result.potentialGradient)
                    )
                )

                metric(
                    title: "Contagion",
                    value: percent(
                        result.contagion
                    )
                )
            }

            HStack {

                metric(
                    title: "Policy Force",
                    value: percent(
                        abs(result.financialPathForce)
                    )
                )

                metric(
                    title: "Banking Mass",
                    value: percent(
                        result.effectiveFinancialMass
                    )
                )

                metric(
                    title: "Interaction",
                    value: percent(
                        result.bankingPolicyInteraction
                    )
                )
            }

            Text(
                "The financial-gravity interpretation treats banking and "
                + "credit fragility as effective financial mass. Policy "
                + "changes provide directional force, while financial "
                + "potential creates a resistance field. Neighboring "
                + "potential differences contribute to contagion and "
                + "system-wide propagation."
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
    // MARK: Historical Energy
    // ========================================================

    // ========================================================
    // MARK: Historical Energy & Momentum
    // ========================================================

    private func historicalEnergyCard(
        result: MarketSimulationResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Financial Energy & Path")
                .font(.headline)

            HStack {

                metric(
                    title: "Energy",
                    value: percent(
                        result.finalEnergy
                    )
                )

                metric(
                    title: "Momentum",
                    value: percent(
                        result.finalMomentum
                    )
                )

                metric(
                    title: "Useful Fuel",
                    value: percent(
                        result.usefulFuel
                    )
                )
            }

            Divider()

            HStack {

                metric(
                    title: "Path Force",
                    value: percent(
                        abs(result.financialPathForce)
                    )
                )

                metric(
                    title: "Energy Depletion",
                    value: percent(
                        result.energyDepletion
                    )
                )

                metric(
                    title: "Potential",
                    value: percent(
                        result.financialPotential
                    )
                )
            }

            Text(
                "Money and credit provide financial energy. "
                + "Policy direction supplies force along the financial path, "
                + "while momentum describes the resulting trajectory. "
                + "Financial potential represents accumulated systemic "
                + "resistance rather than a direct crash signal."
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
    // MARK: Historical Exhaustion
    // ========================================================

    // ========================================================
    // MARK: Historical Exhaustion
    // ========================================================

    private func historicalExhaustionCard(
        result: MarketSimulationResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Exhaustion & Resistance")
                .font(.headline)

            HStack {

                metric(
                    title: "Mean",
                    value: percent(
                        result.meanExhaustion
                    )
                )

                metric(
                    title: "Local",
                    value: percent(
                        result.localExhaustion
                    )
                )

                metric(
                    title: "Total",
                    value: percent(
                        result.totalExhaustion
                    )
                )
            }

            ProgressView(
                value: max(
                    0,
                    min(
                        1,
                        result.totalExhaustion
                    )
                )
            )

            HStack {

                metric(
                    title: "Banking Stress",
                    value: percent(
                        result.bankingStress
                    )
                )

                metric(
                    title: "Financial Mass",
                    value: percent(
                        result.effectiveFinancialMass
                    )
                )

                metric(
                    title: "Attractor",
                    value: percent(
                        result.nonlinearFinancialAttractor
                    )
                )
            }

            HStack {
                Text("Exhaustion state")

                Spacer()

                Text(
                    exhaustionLabel(
                        result.totalExhaustion
                    )
                )
                .font(.subheadline.bold())
            }

            Text(
                "Exhaustion measures declining ability to convert "
                + "financial energy into additional momentum. Banking and "
                + "credit fragility acts as effective financial mass, "
                + "increasing the system's sensitivity to force, contagion "
                + "and accumulated financial potential."
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
        result: MarketSimulationResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Cellular Automaton")
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
                columns: Array(
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
                    result.cells
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
                    "Release",
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

    // ========================================================
    // MARK: Historical Systemic Risk
    // ========================================================

    private func historicalRiskCard(
        result: MarketSimulationResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Emergent Systemic Risk")
                .font(.headline)

            HStack {

                Text(
                        "\(result.systemicRisk)"
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
                value: min(
                    max(
                        result.systemicRisk,
                        0.0
                    ),
                    1.0
                )
            )

            HStack {

                metric(
                    title: "Exhaustion",
                    value: percent(
                        result.meanExhaustion
                    )
                )

                metric(
                    title: "Critical",
                    value: percent(
                        result.criticalFraction
                    )
                )

                metric(
                    title: "Release",
                    value: percent(
                        result.releaseFraction
                    )
                )
            }

            HStack {

                metric(
                    title: "Stress",
                    value: percent(
                        result.meanStress
                    )
                )

                metric(
                    title: "Potential",
                    value: percent(
                        result.financialPotential
                    )
                )

                metric(
                    title: "Depletion",
                    value: percent(
                        result.energyDepletion
                    )
                )
            }

            Text(
                "Systemic risk is an emergent cellular-automaton signal "
                + "derived from exhaustion, stress, critical-cell "
                + "concentration, release, energy depletion and financial "
                + "potential. It is not calculated directly from banking "
                + "stress or any single historical input."
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
        result: MarketSimulationResult
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
                + "cellular exhaustion."
            )

            Text(
                "Equilibrium: "
                + percent(
                    result.equilibriumPressure
                )
                + " • Power law: "
                + percent(
                    analysis.powerLaw
                )
            )

            Text(
                "Energy: "
                + percent(
                    result.meanEnergy
                )
                + " • Momentum: "
                + percent(
                    result.meanMomentum
                )
                + " • Useful fuel: "
                + percent(
                    result.usefulFuel
                )
            )

            Text(
                "Exhaustion: "
                + percent(
                    result.meanExhaustion
                )
                + " • Stress: "
                + percent(
                    result.meanStress
                )
                + " • Risk: "
                + percent(
                    result.systemicRisk
                )
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
    //
    // No sliders.
    // All scenario parameters are fixed model inputs.
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
                    title: "Inflection",
                    value:
                        percent(
                            result.equilibriumInflection
                        )
                )
            }

            Text(
                "Equilibrium is the model's estimate of the point where "
                + "market expansion begins losing momentum. It is driven "
                + "primarily by stock-growth slowdown and inflation pressure; "
                + "the crash interval is only a weak contributor."
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
    // MARK: Current Energy
    // ========================================================

    private var energyCard: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(
                "Energy & Momentum"
            )
            .font(.headline)

            HStack {

                metric(
                    title: "Energy",
                    value:
                        percent(
                            result.meanEnergy
                        )
                )

                metric(
                    title: "Momentum",
                    value:
                        percent(
                            result.meanMomentum
                        )
                )

                metric(
                    title: "Useful Fuel",
                    value:
                        percent(
                            result.usefulFuel
                        )
                )
            }

            Text(
                "Money supply is treated as potential fuel. "
                + "Fuel becomes useful only when the system can still "
                + "convert it into momentum."
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
    // MARK: Current Exhaustion
    // ========================================================

    // ========================================================
    // MARK: Current Exhaustion
    // ========================================================

    private var exhaustionCard: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text("Exhaustion & Financial Resistance")
                .font(.headline)

            HStack {

                metric(
                    title: "Mean",
                    value: percent(
                        result.meanExhaustion
                    )
                )

                metric(
                    title: "Local",
                    value: percent(
                        result.localExhaustion
                    )
                )

                metric(
                    title: "Total",
                    value: percent(
                        result.totalExhaustion
                    )
                )
            }

            ProgressView(
                value: max(
                    0,
                    min(
                        1,
                        result.totalExhaustion
                    )
                )
            )

            HStack {

                metric(
                    title: "Banking Mass",
                    value: percent(
                        result.effectiveFinancialMass
                    )
                )

                metric(
                    title: "Potential",
                    value: percent(
                        result.financialPotential
                    )
                )

                metric(
                    title: "Contagion",
                    value: percent(
                        result.contagion
                    )
                )
            }

            Text(
                "Banking and credit fragility increases effective financial "
                + "mass. That makes policy force and neighboring financial "
                + "stress more consequential, increasing exhaustion when the "
                + "system can no longer efficiently convert energy into momentum."
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
                "Each cell carries energy, momentum, equilibrium, "
                + "exhaustion and stress. Neighboring cells transmit "
                + "exhaustion through contagion."
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
                    result.cells
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
                    "Release",
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
            Text("Systemic Risk")
                .font(.headline)

            HStack {
                Text(
                        result.systemicRisk
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
                value: min(
                    max(
                        result.systemicRisk,
                        0.0
                    ),
                    1.0
                )
            )

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
    // MARK: Disclaimer
    // ========================================================

    private var disclaimerCard: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(
                "Disclaimer"
            )
            .font(.headline)

            Text(
                "This is an experimental systems-dynamics and "
                + "cellular-automaton visualization. Historical "
                + "inputs and model weights must be connected to "
                + "documented and validated time-series data before "
                + "the model can be evaluated empirically."
            )

            Text(
                "The model does not establish causation, does not "
                + "guarantee future crashes, and is not financial, "
                + "trading or investment advice."
            )
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
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

        case .released:
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
    // MARK: Exhaustion Label
    // ========================================================

    private func exhaustionLabel(
        _ value: Double
    ) -> String {

        switch value {

        case 0..<0.25:
            return "Low"

        case 0.25..<0.50:
            return "Building"

        case 0.50..<0.75:
            return "Elevated"

        case 0.75..<0.90:
            return "Critical"

        default:
            return "Extreme"
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
        let input = HistoricalCAInput(
            year: selectedYear,
            growthM2: growthM2,
            inflationPercent: inflationPercent,
            taxGrowthPercent: taxGrowthPercent,
            economicGrowthPercent: economicGrowthPercent,
            stockGrowthPercent: stockGrowthPercent,
            previousStockGrowthPercent: previousStockGrowthPercent,
            growthBondPercent: bondYieldAvgPercent,
            growthVolumePercent: growthVolumePercent,
            cyclePressurePercent: crashInterval,
            shockPressurePercent: externalShockPercent,
            moneyPolicyChangeImpact: moneyPolicyChangeImpact,
            bankingCreditStressRating: bankingCreditStressRating
        )
        result = engine.analyze(input:input)
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
        -> HistoricalCAResult {

        let engine =
            MarketExhaustionEngine()

        let input = HistoricalCAInput(
            year: 2026,
            growthM2: 5,
            inflationPercent: 3,
            taxGrowthPercent: 5,
            economicGrowthPercent: 3,
            stockGrowthPercent: 12,
            previousStockGrowthPercent: 20,
            growthBondPercent: 4.5,
            growthVolumePercent: 10,
            cyclePressurePercent: 6,
            shockPressurePercent: 0,
            moneyPolicyChangeImpact: 0.60,
            bankingCreditStressRating: 2.0
        )
            return engine.analyze(input:input)
    }
}

// ============================================================
// MARK: - Preview
// ============================================================

#Preview {
    ContentView()
}
