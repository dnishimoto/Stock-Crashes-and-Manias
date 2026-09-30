import SwiftUI
import Foundation

struct ContentView: View {

    @State private var isLoading = true
    
    // MARK: - Selected Year
    @State private var historicalSimulationResults:
        [HistoricalSimulationResult] = []
    
   @State private var currentYear = 2026
    

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
                    
                    if (!isLoading)
                    {
                        yearGroup(year: currentYear)
                        
                        ForEach(
                            allYears,
                            id: \.self
                        ) { year in
                            yearGroup(
                                year: year
                            )
                        }}
                }
                .padding()
            }
            .navigationTitle(
                "Stock Crashes and Manias"
            )
            .onAppear {
                isLoading = true

                Task {
                    await Task.yield()

                    await loadHistoricalMatrix()
                    loadYears()
                    isLoading = false
                }
            }
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black
                            .opacity(0.35)
                            .ignoresSafeArea()

                        VStack(spacing: 18) {
                            ProgressView()
                                .scaleEffect(1.4)

                            Text("Calculating Market Simulation")
                                .font(.headline)

                            Text(
                                "Historical cellular automa is being calculated."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                            Text("This will take about 60 seconds.")
                                .font(.subheadline.bold())
                                .multilineTextAlignment(.center)
                        }
                        .padding(28)
                        .frame(maxWidth: 320)
                        .background(
                            .regularMaterial,
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .shadow(radius: 20)
                    }
                }
            }
        }
    }
    // MARK: - Historical Simulation Result Card

    @ViewBuilder
    private func historicalSimulationResultCard(
        year : Int
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            let analysis = historicalAnalyses.first(where: {
                $0.year == year
            })

            if let analysis, analysis.frames.count >= 1 {

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
                            "Historical \(String(analysis.year)) Cellular Automaton"
                        )
                        .font(.headline)

                        Text(
                            "100 generations"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                    /*
                    Text(
                        simulation.result.riskLevel.rawValue
                    )
                    .font(.headline)
                    .foregroundStyle(
                        riskColor(
                            simulation.result.systemicRisk
                        )
                    )
                     */
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
                    cells: analysis.frames[analysis.frames.count-1].cells
                )

                stateLegendView
                Divider()
                //contagionCard(analysis:analysis)
                scenarioCard(analysis: analysis)
                riskCard(analysis: analysis)
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

           /* modelPipelineCard(
                year: simulation.year
            )
            */
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
                subtitle: "Years to analyze"
            )

          //  if year == selectedYear {
           //     currentInformationCard
          //  } else {
            /*
                if let simulation =
                    historicalSimulationResults.first(where: {
                        $0.year == year
                    }) {

                   
             */
            if !isLoading {
        
                ForEach(allYears, id: \.self) { year in
                    historicalSimulationResultCard(
                    year: year
                    )
                }
            }
          //  }
        }
    }

/*
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

            var caCells :[MarketCell]=[]

            let simulationResult = engine.runYear(
                year: year,
                caCells: &caCells,
                iterations: 100,
                equilibriumPressure: equilibriumPressure,
                volumePressure: volumePressure,
                scenario: scenario
            
            )

           
            guard let cells = simulationResult.cells else {
                return
            }

            historicalSimulationResults.append(
                HistoricalSimulationResult(
                    year: year,
                    result: simulationResult,
                    cells: cells
                )
            )
        }
    }
*/

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
                    "\(String(year))"
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
  
        }
        .padding(
            .horizontal,
            4
        )
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

    private func scenarioCard(
        analysis: HistoricalCrashAnalysis
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Text(
                "\(String(analysis.year)) Scenario"
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
                value: analysis.frames.first?.scenario?.moneySupplyChangePercent ?? 0.0,
                suffix: "%"
            )

            scenarioValue(
                "Inflation",
                value: analysis.frames.first?.scenario?.inflationPercent ?? 0.0,
                suffix: "%"
            )

            scenarioValue(
                "Money Policy Impact",
                value: analysis.frames.last?.scenario?.moneyPolicyChangeImpact ?? 0.0,
                suffix: ""
            )

            scenarioValue(
                "Economic Growth",
                value: analysis.frames.first?.scenario?.economicGrowthPercent ?? 0.0,
                suffix: "%"
            )

            scenarioValue(
                "Stock Growth",
                value: analysis.frames.first?.scenario?.stockGrowthPercent ?? 0.0,
                suffix: "%"
            )

            scenarioValue(
                "Previous Stock Growth",
                value: analysis.frames.first?.scenario?.previousStockGrowthPercent ?? 0.0,
                suffix: "%"
            )

            scenarioValue(
                "Average Bond Yield",
                value: analysis.frames.first?.scenario?.bondYieldAvgPercent ?? 0.0,
                suffix: "%"
            )


            scenarioValue(
                "Foreign Investment",
                value: analysis.frames.first?.scenario?.foreignInvestmentMillions ?? 0.0,
                suffix: "M"
            )

            scenarioValue(
                "Bank / Credit Stress",
                value: analysis.frames.first?.scenario?.bankingCreditStressRating ?? 0.0,
                suffix: ""
            )

            scenarioValue(
                "Policy Impact",
                value: analysis.frames.first?.scenario?.moneyPolicyChangeImpact ?? 0.0,
                suffix: ""
            )

            scenarioValue(
                "External Shock",
                value: analysis.frames.first?.scenario?.externalShockMagnitudePercent ?? 0.0,
                suffix: "%"
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
    /*
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
                cells: currentCells
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
     */

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
                cells: analysis.frames[analysis.frames.count-1].cells
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
            
            //contagionCard(analysis: analysis)
            scenarioCard(analysis: analysis)
            riskCard(analysis: analysis)
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
/*
    private var localFinancialStructureCard: some View {

        let cells = currentCells

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
*/
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
/*
    private func contagionCard(
        analysis: HistoricalCrashAnalysis
    ) -> some View {

        let cells = analysis.frames.last?.cells ?? []

        let columns = Array(
            repeating: GridItem(
                .fixed(8),
                spacing: 1
            ),
            count: 12
        )

        return VStack(
            alignment: .leading,
            spacing: 4
        ) {

            HStack(spacing: 6) {

                Text("Contagion")
                    .font(.caption.bold())

                metric(
                    title: "Mean",
                    value: percent(
                        mean(cells.map(\.contagion))
                    )
                )

                metric(
                    title: "S",
                    value: percent(
                        fraction(cells) {
                            $0.state == .stressed
                        }
                    )
                )

                metric(
                    title: "C",
                    value: percent(
                        fraction(cells) {
                            $0.state == .critical
                        }
                    )
                )

                metric(
                    title: "X",
                    value: percent(
                        fraction(cells) {
                            $0.state == .crashed
                        }
                    )
                )

                Spacer()

                HStack(spacing: 3) {
                    contagionLegend(color: .green, label: "")
                    contagionLegend(color: .yellow, label: "")
                    contagionLegend(color: .orange, label: "")
                    contagionLegend(color: .red, label: "")
                }
            }

            // Compact 12 × 12 lattice
            LazyVGrid(
                columns: columns,
                spacing: 1
            ) {
                ForEach(
                    Array(cells.enumerated()),
                    id: \.offset
                ) { _, cell in

                    Rectangle()
                        .fill(
                            contagionColor(for: cell)
                        )
                        .frame(
                            width: 8,
                            height: 8
                        )
                }
            }
            .frame(
                width: 12 * 8 + 11,
                height: 12 * 8 + 11
            )
        }
        .padding(6)
        .background(
            .thinMaterial,
            in: RoundedRectangle(
                cornerRadius: 8
            )
        )
    }
    private func contagionLegend(
        color: Color,
        label: String
    ) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(
                    width: 10,
                    height: 10
                )

            Text(label)
        }
    }
 */
    private func contagionColor(
        for cell: MarketCell
    ) -> Color {
        switch cell.state {
        case .crashed:
            return .red

        case .critical:
            return .orange

        case .stressed:
            return .yellow

        default:
            let contagion = min(
                max(cell.contagion, 0.0),
                1.0
            )

            return Color(
                red: contagion,
                green: 0.85 - (contagion * 0.55),
                blue: 0.20 - (contagion * 0.15)
            )
        }
    }
    // MARK: - Risk

    private func riskCard(
        analysis: HistoricalCrashAnalysis
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
                        analysis.result.systemicRisk
                    )
                )
                .font(
                    .title.bold()
                )
                .monospacedDigit()

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

            ProgressView(
                value:
                    bounded(
                        analysis.result.systemicRisk
                    )
            )

            HStack {

                metric(
                    title: "Cellular Stress",
                    value:
                        percent(
                            analysis.result.cellularStress
                        )
                )

                metric(
                    title: "Critical Cells",
                    value:
                        percent(
                            analysis.result.criticalFraction
                        )
                )

                metric(
                    title: "Crashed Cells",
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

    // MARK: - Dynamics
/*
    private var dynamicsCard: some View {

        let cells = currentCells

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
*/
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
                        max(cells.count, 1)
                    )
                )
            ),
            1
        )

        return LazyVGrid(
            columns: Array(
                repeating: GridItem(
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
            maxWidth: .infinity
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
/*
    private func rerunSelectedYear() {

        runSimulation(
            year: selectedYear
        )
    }
 */


 /*
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
 */

    // MARK: - Historical Data

    private func loadHistoricalMatrix() async {

        historicalAnalyses =
            await engine.analyzeAllHistoricalCrashes()
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

