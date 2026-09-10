//

//  ContentView.swift

//  Market Crash Cellular Automaton

//

//  Created by David Nishimoto on 9/9/26.

//

import SwiftUI

import Foundation

import Charts

// ============================================================

// MARK: - CRASH RECORD

// ============================================================

struct CrashRecord: Identifiable {

    let id = UUID()

    let year: Int

    let volumeMillions: Double

}

struct CrashVolumePoint: Identifiable {

    let id = UUID()

    let year: Int

    let volume: Double

}

// ============================================================
// MARK: - CURRENT MARKET VOLUME
// ============================================================

struct MarketVolumePoint: Identifiable {
    let id = UUID()
    let date: Date
    let volumeMillions: Double
}

private struct YahooChartResponse: Decodable {
    let chart: YahooChart
}

private struct YahooChart: Decodable {
    let result: [YahooChartResult]?
}

private struct YahooChartResult: Decodable {
    let timestamp: [Int]?
    let indicators: YahooIndicators
}

private struct YahooIndicators: Decodable {
    let quote: [YahooQuote]
}

private struct YahooQuote: Decodable {
    let volume: [Double?]?
}

private enum YahooMarketVolumeService {
    static func currentYearVolume() async throws -> [MarketVolumePoint] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let year = calendar.component(.year, from: now)
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? now
        let end = calendar.date(byAdding: .day, value: 1, to: now) ?? now

        let period1 = Int(start.timeIntervalSince1970)
        let period2 = Int(end.timeIntervalSince1970)

        var components = URLComponents(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EGSPC")!
        components.queryItems = [
            URLQueryItem(name: "period1", value: String(period1)),
            URLQueryItem(name: "period2", value: String(period2)),
            URLQueryItem(name: "interval", value: "1d"),
            URLQueryItem(name: "events", value: "history"),
            URLQueryItem(name: "includeAdjustedClose", value: "true")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(YahooChartResponse.self, from: data)
        guard let chartResult = decoded.chart.result?.first,
              let timestamps = chartResult.timestamp,
              let volumes = chartResult.indicators.quote.first?.volume else {
            return []
        }

        var points: [MarketVolumePoint] = []
        for (index, timestamp) in timestamps.enumerated() {
            guard index < volumes.count,
                  let volume = volumes[index],
                  volume.isFinite,
                  volume >= 0 else {
                continue
            }

            points.append(
                MarketVolumePoint(
                    date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
                    volumeMillions: volume / 1_000_000.0
                )
            )
        }

        return points.sorted { $0.date < $1.date }
    }
}

// Helper to get volume points from crashRecords

private func crashVolumeHistory(from records: [CrashRecord]) -> [CrashVolumePoint] {

    records.map { CrashVolumePoint(year: $0.year, volume: $0.volumeMillions) }

}

// ============================================================

// MARK: - CELL STATE

// ============================================================

enum MarketCellState: Int, CaseIterable {

    case stable = 0

    case rising = 1

    case stressed = 2

    case critical = 3

    case crash = 4

    var name: String {

        switch self {

        case .stable:

            return "STABLE"

        case .rising:

            return "RISING"

        case .stressed:

            return "STRESSED"

        case .critical:

            return "CRITICAL"

        case .crash:

            return "CRASH"

        }

    }

    var symbol: String {

        switch self {

        case .stable:

            return "circle"

        case .rising:

            return "arrow.up"

        case .stressed:

            return "exclamationmark.triangle"

        case .critical:

            return "bolt.fill"

        case .crash:

            return "xmark.octagon.fill"

        }

    }

    var description: String {

        switch self {

        case .stable:

            return "Low local market pressure."

        case .rising:

            return "Market activity is increasing."

        case .stressed:

            return "Persistent local instability."

        case .critical:

            return "High instability with contagion potential."

        case .crash:

            return "Local cell has entered crash state."

        }

    }

}

// ============================================================

// MARK: - MARKET CELL

// ============================================================

struct MarketCell {

    var state: MarketCellState

    var stress: Double

    var volumePressure: Double

    var contagion: Double

}

// ============================================================

// MARK: - SIMULATION RESULT

// ============================================================

struct MarketRiskResult {

    var currentYear: Int

    var yearsSinceCrash: Int

    var alpha: Double

    var equilibriumPressure: Double

    var volumePressure: Double

    var cellularStress: Double

    var criticalFraction: Double

    var crashFraction: Double

    var systemicRisk: Double

    var predictedWindowStart: Int

    var predictedWindowEnd: Int

    var riskLevel: String

}

// ============================================================

// MARK: - MARKET CRASH ENGINE

// ============================================================

final class MarketCrashEngine {

    // --------------------------------------------------------

    // Historical crash records

    // --------------------------------------------------------

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

    // --------------------------------------------------------

    // Cellular automaton

    // --------------------------------------------------------

    private(set) var cells: [MarketCell] = []

    let gridWidth: Int

    let gridHeight: Int

    // --------------------------------------------------------

    // Tunable parameters

    // --------------------------------------------------------

    var equilibriumWeight: Double = 0.40

    var volumeWeight: Double = 0.25

    var contagionWeight: Double = 0.35

    var risingThreshold: Double = 0.20

    var stressedThreshold: Double = 0.40

    var criticalThreshold: Double = 0.65

    var crashThreshold: Double = 0.85

    init(

        gridWidth: Int = 20,

        gridHeight: Int = 12

    ) {

        self.gridWidth = gridWidth

        self.gridHeight = gridHeight

        let count = gridWidth * gridHeight

        self.cells = Array(

            repeating: MarketCell(

                state: .stable,

                stress: 0,

                volumePressure: 0,

                contagion: 0

            ),

            count: count

        )

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

        ).map { current, previous in

            Double(current.year - previous.year)

        }

    }

    // ========================================================

    // MARK: - Power-Law Alpha

    // ========================================================

    /*

     Continuous power-law maximum-likelihood estimate:

         alpha = 1 + n / Σ ln(x / xmin)

     This is an experimental estimator for the crash-interval

     distribution.

    */

    func estimatePowerLawAlpha() -> Double {
        return estimatePowerLawAlpha(upThroughCrashIndex: crashRecords.count - 1)
    }

    func estimatePowerLawAlpha(
        upThroughCrashIndex crashIndex: Int
    ) -> Double {
        guard crashIndex > 0,
              crashRecords.count > 1 else {
            return 2.0
        }

        let lastIndex = min(crashIndex, crashRecords.count - 1)
        var intervals: [Double] = []

        for index in 1...lastIndex {
            let interval = Double(
                crashRecords[index].year - crashRecords[index - 1].year
            )
            if interval > 0 {
                intervals.append(interval)
            }
        }

        guard !intervals.isEmpty else {
            return 2.0
        }

        let xmin = max(intervals.min() ?? 1.0, 1.0)
        let logarithmicSum = intervals.reduce(0.0) { partial, interval in
            partial + log(max(interval / xmin, 1.000001))
        }

        guard logarithmicSum > 0 else {
            return 2.0
        }

        let alpha = 1.0 + Double(intervals.count) / logarithmicSum
        return min(max(alpha, 1.01), 10.0)
    }

    // ========================================================

    // MARK: - Power-Law Probability

    // ========================================================

    /*

     Survival-style power-law pressure.

     As the elapsed time increases relative to the

     historical minimum interval, equilibrium pressure rises.

    */

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
            return 0
        }

        let xmin = max(intervals.min() ?? 1.0, 1.0)
        let x = max(Double(yearsSinceCrash), xmin)
        let survivalProbability = pow(
            x / xmin,
            -(alpha - 1.0)
        )

        return min(
            max(1.0 - survivalProbability, 0.0),
            1.0
        )
    }

    // ========================================================

    // MARK: - Volume Pressure

    // ========================================================

    func calculateVolumePressure() -> Double {
        let records = crashRecords
        guard records.count >= 3 else {
            return 0
        }
        return volumePressure(
            recent: records[records.count - 1].volumeMillions,
            previous: records[records.count - 2].volumeMillions,
            older: records[records.count - 3].volumeMillions
        )
    }

    func calculateCurrentVolumePressure(
        points: [MarketVolumePoint]
    ) -> Double {
        guard points.count >= 3 else {
            return 0
        }

        let sorted = points.sorted { $0.date < $1.date }
        return volumePressure(
            recent: sorted[sorted.count - 1].volumeMillions,
            previous: sorted[sorted.count - 2].volumeMillions,
            older: sorted[sorted.count - 3].volumeMillions
        )
    }

    func historicalVolumePressure(
        crashIndex: Int
    ) -> Double {
        guard crashIndex > 0,
              crashIndex < crashRecords.count else {
            return 0
        }

        let recent = crashRecords[crashIndex].volumeMillions
        let previous = crashRecords[crashIndex - 1].volumeMillions
        let recentGrowth = (recent - previous) / max(previous, 1.0)

        guard crashIndex >= 2 else {
            return min(max(0.7 * max(recentGrowth, 0), 0), 1)
        }

        let older = crashRecords[crashIndex - 2].volumeMillions
        return volumePressure(
            recent: recent,
            previous: previous,
            older: older
        )
    }

    private func volumePressure(
        recent: Double,
        previous: Double,
        older: Double
    ) -> Double {
        let recentGrowth = (recent - previous) / max(previous, 1.0)
        let previousGrowth = (previous - older) / max(older, 1.0)
        let acceleration = recentGrowth - previousGrowth

        let growthComponent = min(max(recentGrowth, 0), 1)
        let accelerationComponent = min(max(acceleration * 4.0, 0), 1)

        return min(
            max(
                0.7 * growthComponent +
                0.3 * accelerationComponent,
                0
            ),
            1
        )
    }

    // ========================================================

    // MARK: - Initialize Cellular Automaton

    // ========================================================

    func resetCells() {

        cells = Array(

            repeating: MarketCell(

                state: .stable,

                stress: 0,

                volumePressure: 0,

                contagion: 0

            ),

            count: gridWidth * gridHeight

        )

    }

    // ========================================================

    // MARK: - Neighbor Indices

    // ========================================================

    private func neighborIndices(

        for index: Int

    ) -> [Int] {

        let x = index % gridWidth

        let y = index / gridWidth

        var neighbors: [Int] = []

        for dy in -1...1 {

            for dx in -1...1 {

                if dx == 0 && dy == 0 {

                    continue

                }

                let nx = x + dx

                let ny = y + dy

                guard

                    nx >= 0,

                    nx < gridWidth,

                    ny >= 0,

                    ny < gridHeight

                else {

                    continue

                }

                neighbors.append(

                    ny * gridWidth + nx

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

            neighborIndices(for: index)

        guard !neighbors.isEmpty else {

            return 0

        }

        let totalStress =

            neighbors.reduce(0.0) {

                result,

                neighborIndex in

                result +

                cells[neighborIndex].stress

            }

        return min(

            max(

                totalStress /

                Double(neighbors.count),

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

    ) -> MarketCellState {

        switch stress {

        case ..<risingThreshold:

            return .stable

        case ..<stressedThreshold:

            return .rising

        case ..<criticalThreshold:

            return .stressed

        case ..<crashThreshold:

            return .critical

        default:

            return .crash

        }

    }

    // ========================================================

    // MARK: - Run Cellular Automaton

    // ========================================================

    func step(

        equilibriumPressure: Double,

        volumePressure: Double

    ) {

        var nextCells = cells

        for index in cells.indices {

            let contagion =

                contagionForCell(

                    at: index

                )

            /*

             Add a small spatial perturbation so the

             automaton does not evolve identically everywhere.

            */

            let x = index % gridWidth

            let y = index / gridWidth

            let spatialSignal =

                abs(

                    sin(

                        Double(x) * 0.73 +

                        Double(y) * 1.17

                    )

                ) * 0.08

            let pressure =

                equilibriumWeight *

                equilibriumPressure

                +

                volumeWeight *

                volumePressure

                +

                contagionWeight *

                contagion

                +

                spatialSignal

            let boundedPressure =

                min(

                    max(pressure, 0),

                    1

                )

            nextCells[index] = MarketCell(

                state: stateForStress(

                    boundedPressure

                ),

                stress: boundedPressure,

                volumePressure: volumePressure,

                contagion: contagion

            )

        }

        cells = nextCells

    }

    // ========================================================

    // MARK: - Run Multiple Generations

    // ========================================================

    func run(

        generations: Int,

        equilibriumPressure: Double,

        volumePressure: Double

    ) {

        for _ in 0..<generations {

            step(

                equilibriumPressure:

                    equilibriumPressure,

                volumePressure:

                    volumePressure

            )

        }

    }

    // ========================================================

    // MARK: - Cellular Stress

    // ========================================================

    func cellularStress() -> Double {

        guard !cells.isEmpty else {

            return 0

        }

        return cells.reduce(0.0) {

            $0 + $1.stress

        }

        /

        Double(cells.count)

    }

    // ========================================================

    // MARK: - Critical Fraction

    // ========================================================

    func criticalCellFraction() -> Double {

        guard !cells.isEmpty else {

            return 0

        }

        let count =

            cells.filter {

                $0.state == .critical

                ||

                $0.state == .crash

            }.count

        return Double(count) /

        Double(cells.count)

    }

    // ========================================================

    // MARK: - Crash Fraction

    // ========================================================

    func crashCellFraction() -> Double {

        guard !cells.isEmpty else {

            return 0

        }

        let count =

            cells.filter {

                $0.state == .crash

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

        let risk =

            0.30 * equilibriumPressure +

            0.20 * volumePressure +

            0.25 * localStress +

            0.15 * critical +

            0.10 * crash

        return min(

            max(risk, 0),

            1

        )

    }

    // ========================================================

    // MARK: - Risk Level

    // ========================================================

    func riskLevel(

        _ risk: Double

    ) -> String {

        switch risk {

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

    // MARK: - Full Analysis

    // ========================================================

    func analyze(
        currentYear: Int,
        currentVolumePoints: [MarketVolumePoint] = []
    ) -> MarketRiskResult {
        resetCells()

        let lastCrashYear = crashRecords.last?.year ?? currentYear
        let yearsSinceCrash = max(currentYear - lastCrashYear, 0)
        let alpha = estimatePowerLawAlpha()
        let equilibrium = powerLawPressure(yearsSinceCrash: yearsSinceCrash)
        let volume = currentVolumePoints.count >= 3
            ? calculateCurrentVolumePressure(points: currentVolumePoints)
            : calculateVolumePressure()

        run(
            generations: 8,
            equilibriumPressure: equilibrium,
            volumePressure: volume
        )

        let localStress = cellularStress()
        let critical = criticalCellFraction()
        let crash = crashCellFraction()
        let risk = systemicRisk(
            equilibriumPressure: equilibrium,
            volumePressure: volume
        )

        let horizon = riskWindowHorizon(for: risk)

        return MarketRiskResult(
            currentYear: currentYear,
            yearsSinceCrash: yearsSinceCrash,
            alpha: alpha,
            equilibriumPressure: equilibrium,
            volumePressure: volume,
            cellularStress: localStress,
            criticalFraction: critical,
            crashFraction: crash,
            systemicRisk: risk,
            predictedWindowStart: currentYear + 1,
            predictedWindowEnd: currentYear + horizon,
            riskLevel: riskLevel(risk)
        )
    }

    func analyzeHistoricalCrash(
        at crashIndex: Int
    ) -> HistoricalCrashAnalysis? {
        guard crashRecords.indices.contains(crashIndex) else {
            return nil
        }

        resetCells()

        let record = crashRecords[crashIndex]
        let intervalYears: Int

        if crashIndex > 0 {
            intervalYears = max(
                record.year - crashRecords[crashIndex - 1].year,
                0
            )
        } else {
            intervalYears = 0
        }

        let alpha = estimatePowerLawAlpha(
            upThroughCrashIndex: crashIndex
        )

        let intervals: [Double]
        if crashIndex > 0 {
            intervals = (1...crashIndex).compactMap { index in
                let interval = Double(
                    crashRecords[index].year - crashRecords[index - 1].year
                )
                return interval > 0 ? interval : nil
            }
        } else {
            intervals = []
        }

        let equilibrium = powerLawPressure(
            yearsSinceCrash: intervalYears,
            alpha: alpha,
            intervals: intervals
        )

        let volume = historicalVolumePressure(
            crashIndex: crashIndex
        )

        run(
            generations: 8,
            equilibriumPressure: equilibrium,
            volumePressure: volume
        )

        let localStress = cellularStress()
        let critical = criticalCellFraction()
        let crash = crashCellFraction()
        let risk = systemicRisk(
            equilibriumPressure: equilibrium,
            volumePressure: volume
        )

        let horizon = riskWindowHorizon(for: risk)
        let previousCrashYear = crashIndex > 0
            ? crashRecords[crashIndex - 1].year
            : record.year

        let result = MarketRiskResult(
            currentYear: record.year,
            yearsSinceCrash: intervalYears,
            alpha: alpha,
            equilibriumPressure: equilibrium,
            volumePressure: volume,
            cellularStress: localStress,
            criticalFraction: critical,
            crashFraction: crash,
            systemicRisk: risk,
            predictedWindowStart: max(
                previousCrashYear + 1,
                record.year - horizon
            ),
            predictedWindowEnd: record.year,
            riskLevel: riskLevel(risk)
        )

        return HistoricalCrashAnalysis(
            year: record.year,
            intervalYears: intervalYears,
            result: result,
            cells: cells
        )
    }

    private func riskWindowHorizon(
        for risk: Double
    ) -> Int {
        switch risk {
        case ..<0.20: return 10
        case ..<0.40: return 7
        case ..<0.65: return 5
        case ..<0.80: return 3
        default: return 2
        }
    }

}

// ============================================================

// MARK: - HISTORICAL CRASH ANALYSIS

// ============================================================

struct HistoricalCrashAnalysis: Identifiable {
    let id = UUID()
    let year: Int
    let intervalYears: Int
    let result: MarketRiskResult
    let cells: [MarketCell]
}

// ============================================================

// MARK: - CONTENT VIEW

// ============================================================

struct ContentView: View {

    // --------------------------------------------------------

    // Simulation engine

    // --------------------------------------------------------

    @State private var engine =

        MarketCrashEngine()

    @State private var crashSnapshots: [MarketCrashSnapshot] = []

    struct MarketCrashSnapshot: Identifiable {
        let id = UUID()
        let year: Int
        let intervalYears: Int
        let alpha: Double
        let equilibriumPressure: Double
        let volumePressure: Double
        let cellularStress: Double
        let criticalFraction: Double
        let crashFraction: Double
        let systemicRisk: Double
        let riskLevel: String
        let riskWindowStart: Int
        let riskWindowEnd: Int
        let cells: [MarketCell]
    }

    // --------------------------------------------------------

    // UI state

    // --------------------------------------------------------

    @State private var currentYear: Double = 2026

    @State private var result =

        MarketRiskResult(

            currentYear: 2026,

            yearsSinceCrash: 4,

            alpha: 2.0,

            equilibriumPressure: 0,

            volumePressure: 0,

            cellularStress: 0,

            criticalFraction: 0,

            crashFraction: 0,

            systemicRisk: 0,

            predictedWindowStart: 2027,

            predictedWindowEnd: 2036,

            riskLevel: "LOW"

        )

    @State private var isRunning = false
    @State private var yahooVolumePoints: [MarketVolumePoint] = []
    @State private var yahooVolumeStatus = "Loading current S&P 500 volume…"

    // ========================================================

    // MARK: - Body

    // ========================================================

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(

                    alignment: .leading,

                    spacing: 18

                ) {

                    headerCard

                    historicalDataCard

                    powerLawCard

                    equilibriumCard

                    cellularAutomatonCard

                    riskCard

                    predictionCard

                    disclaimerCard

                }

                .padding()

            }

            .background(

                Color(.systemGroupedBackground)

            )

            .navigationTitle(

                "Market Crash CA"

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

                                "play.fill"

                        )

                    }

                    .accessibilityLabel(

                        "Run simulation"

                    )

                }

            }

        }

        .onAppear {

            runSimulation()

            generateCrashSnapshots()

        }

    }

    // ========================================================

    // MARK: - Header

    // ========================================================

    private var headerCard: some View {

        VStack(

            alignment: .leading,

            spacing: 10

        ) {

            HStack {

                Image(

                    systemName:

                        "waveform.path.ecg"

                )

                .font(.largeTitle)

                VStack(

                    alignment: .leading

                ) {

                    Text(

                        "Market Crash Cellular Automaton"

                    )

                    .font(.title2)

                    .fontWeight(.bold)

                    Text(

                        "Power-law equilibrium + local contagion"

                    )

                    .font(.subheadline)

                    .foregroundStyle(.secondary)

                }

            }

            Text(

                "The model combines historical crash intervals, "

                + "power-law temporal pressure, trading-volume pressure, "

                + "and a cellular automaton representing local market instability."

            )

            .font(.body)

        }

        .padding()

        .background(.background)

        .clipShape(

            RoundedRectangle(

                cornerRadius: 16

            )

        )

    }

    // ========================================================

    // MARK: - Historical Data

    // ========================================================

    private var historicalDataCard: some View {

        VStack(

            alignment: .leading,

            spacing: 12

        ) {

            sectionHeader(

                title: "1. Historical Market Data",

                icon: "chart.xyaxis.line"

            )

            HStack {

                metric(

                    title: "Crash Events",

                    value:

                        "\(engine.crashRecords.count)"

                )

                metric(

                    title: "First",

                    value:

                        "\(engine.crashRecords.first?.year ?? 0)"

                )

                metric(

                    title: "Latest",

                    value:

                        "\(engine.crashRecords.last?.year ?? 0)"

                )

            }

            Divider()

            Text("Crash intervals")

            let intervals =

                engine.crashIntervals()

            Text(

                intervals

                    .map {

                        String(

                            format: "%.0f",

                            $0

                        )

                    }

                    .joined(

                        separator: "  •  "

                    )

            )

            .font(.system(

                .body,

                design: .monospaced

            ))

            .foregroundStyle(.secondary)

        }

        .cardStyle()

    }

    // ========================================================

    // MARK: - Power Law

    // ========================================================

    private var powerLawCard: some View {

        let alpha =

            engine.estimatePowerLawAlpha()

        return VStack(

            alignment: .leading,

            spacing: 12

        ) {

            sectionHeader(

                title: "2. Power-Law Distribution",

                icon: "function"

            )

            Text(

                "P(x) ∝ x⁻ᵅ"

            )

            .font(.title3)

            .fontWeight(.semibold)

            HStack {

                Text("Estimated α")

                Spacer()

                Text(

                    String(

                        format: "%.4f",

                        alpha

                    )

                )

                .fontWeight(.bold)

                .monospacedDigit()

            }

            Text(

                "α describes the shape of the historical "

                + "crash-interval distribution. It establishes "

                + "the model's temporal equilibrium rather than "

                + "directly predicting a crash."

            )

            .font(.subheadline)

            .foregroundStyle(.secondary)

        }

        .cardStyle()

    }

    // ========================================================

    // MARK: - Equilibrium

    // ========================================================

    private var equilibriumCard: some View {

        VStack(

            alignment: .leading,

            spacing: 12

        ) {

            sectionHeader(

                title: "3. Temporal Equilibrium",

                icon: "clock"

            )

            HStack {

                Text("Current year")

                Spacer()

                Text(

                    "\(Int(currentYear))"

                )

                .fontWeight(.bold)

            }

            Slider(

                value:

                    $currentYear,

                in: 1908...2035,

                step: 1

            )

            .onChange(

                of: currentYear

            ) {

                _,

                _ in

                runSimulation()

                generateCrashSnapshots()

            }

            HStack {

                Text(

                    "Years since last crash"

                )

                Spacer()

                Text(

                    "\(result.yearsSinceCrash)"

                )

                .fontWeight(.bold)

                .monospacedDigit()

            }

            ProgressView(

                value:

                    result.equilibriumPressure

            )

            Text(

                "Equilibrium pressure: "

                +

                "\(percent(result.equilibriumPressure))"

            )

            .font(.caption)

            .foregroundStyle(.secondary)

        }

        .cardStyle()

    }

    // ========================================================

    // MARK: - Cellular Automaton

    // ========================================================

    private var cellularAutomatonCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "4. Historical Crash Pipeline", icon: "square.grid.3x3.fill")

            Text("Every historical crash is processed through the same six-stage model: crash event → power-law equilibrium → volume buildup → cellular contagion → systemic stress → reconstructed risk window.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(
                crashSnapshots,
                id: \.id
            ) { (snapshot: MarketCrashSnapshot) in
                VStack(alignment: .leading, spacing: 12) {
                    Text("Crash Event — \(snapshot.year)")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("1. Historical Crash")
                        .font(.headline)
                    metric(title: "Crash year", value: "\(snapshot.year)")

                    Text("2. Power-Law Equilibrium")
                        .font(.headline)
                    HStack {
                        metric(title: "Interval", value: "\(snapshot.intervalYears) years")
                        metric(title: "α", value: String(format: "%.3f", snapshot.alpha))
                        metric(title: "Equilibrium", value: percent(snapshot.equilibriumPressure))
                    }

                    Text("3. Mania / Volume Buildup")
                        .font(.headline)
                    riskMetric("Historical volume pressure", snapshot.volumePressure)

                    Text("4. Cellular Contagion")
                        .font(.headline)
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: engine.gridWidth),
                        spacing: 3
                    ) {
                        ForEach(
                            snapshot.cells.indices,
                            id: \.self
                        ) { index in
                            snapshotCellView(snapshot.cells[index])
                        }
                    }
                    riskMetric("Cellular stress", snapshot.cellularStress)
                    riskMetric("Critical + crash cells", snapshot.criticalFraction)
                    riskMetric("Crash cells", snapshot.crashFraction)

                    Text("5. Systemic Stress")
                        .font(.headline)
                    HStack {
                        Text(snapshot.riskLevel)
                            .fontWeight(.bold)
                        Spacer()
                        Text(percent(snapshot.systemicRisk))
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    ProgressView(value: snapshot.systemicRisk)

                    Text("6. Reconstructed Crash-Risk Window")
                        .font(.headline)
                    Text("\(snapshot.riskWindowStart) → \(snapshot.riskWindowEnd)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .monospacedDigit()
                    Text("This is a historical reconstruction, not evidence that the model predicted the event in advance.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Divider()
            HStack {
                legend(state: .stable)
                legend(state: .rising)
                legend(state: .stressed)
                legend(state: .critical)
                legend(state: .crash)
            }
        }
        .cardStyle()
    }

    // ========================================================

    // MARK: - Cell View

    // ========================================================

    private func cellView(

        _ cell: MarketCell

    ) -> some View {

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

    private func snapshotCellView(_ cell: MarketCell) -> some View {

        RoundedRectangle(cornerRadius: 2)

            .fill(cellColor(cell.state))

            .aspectRatio(1, contentMode: .fit)

            .overlay(cell.state == .crash ? RoundedRectangle(cornerRadius: 2).stroke(Color.red, lineWidth: 2) : nil)

    }

    // ========================================================

    // MARK: - Cell Color

    // ========================================================

    private func cellColor(

        _ state: MarketCellState

    ) -> Color {

        switch state {

        case .stable:

            return .gray.opacity(0.25)

        case .rising:

            return .blue.opacity(0.55)

        case .stressed:

            return .orange.opacity(0.70)

        case .critical:

            return .red.opacity(0.75)

        case .crash:

            return .black

        }

    }

    // ========================================================

    // MARK: - Legend

    // ========================================================

    private func legend(

        state: MarketCellState

    ) -> some View {

        HStack(spacing: 4) {

            Circle()

                .fill(

                    cellColor(state)

                )

                .frame(

                    width: 8,

                    height: 8

                )

            Text(state.name)

                .font(.caption2)

        }

    }

    // ========================================================

    // MARK: - Risk

    // ========================================================

    private var riskCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "5. Current Systemic Stress", icon: "exclamationmark.shield")

            Text("The current market state combines the current power-law equilibrium, current-year volume buildup, and cellular contagion into one systemic-risk signal.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading) {
                    Text(result.riskLevel)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Composite model signal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(percent(result.systemicRisk))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
            }

            ProgressView(value: result.systemicRisk)
            riskMetric("Equilibrium pressure", result.equilibriumPressure)
            riskMetric("Volume pressure", result.volumePressure)
            riskMetric("Cellular stress", result.cellularStress)
            riskMetric("Critical cells", result.criticalFraction)
            riskMetric("Crash cells", result.crashFraction)

            Divider()
            Text("Current Yahoo Finance volume")
                .font(.headline)
            if let latest = yahooVolumePoints.last {
                metric(
                    title: "Latest S&P 500 daily volume",
                    value: String(format: "%.1f M", latest.volumeMillions)
                )
            }
            Text(yahooVolumeStatus)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    // ========================================================

    // MARK: - Prediction Window

    // ========================================================

    private var predictionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "6. Next-Crash Risk Window", icon: "calendar")

            Text("Current pipeline: power-law equilibrium → current Yahoo volume buildup → cellular contagion → systemic stress → forward risk window.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading) {
                    Text("\(result.predictedWindowStart)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Window begins")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "arrow.right")
                VStack(alignment: .leading) {
                    Text("\(result.predictedWindowEnd)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Window ends")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("The model-generated window is a research signal, not a deterministic forecast. Historical windows shown above are reconstructions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    // ========================================================

    // MARK: - Disclaimer

    // ========================================================

    private var disclaimerCard: some View {

        VStack(

            alignment: .leading,

            spacing: 8

        ) {

            Label(

                "Model status",

                systemImage:

                    "info.circle"

            )

            .fontWeight(.semibold)

            Text(

                "This is an experimental statistical and "

                + "cellular-automaton model. Historical crash "

                + "records and volume inputs are used to construct "

                + "the simulation. The output should be interpreted "

                + "as a research risk signal, not financial advice "

                + "or a guaranteed crash prediction."

            )

            .font(.caption)

            .foregroundStyle(.secondary)

        }

        .padding()

        .background(

            Color.yellow.opacity(0.12)

        )

        .clipShape(

            RoundedRectangle(

                cornerRadius: 16

            )

        )

    }

    // ========================================================

    // MARK: - Section Header

    // ========================================================

    private func sectionHeader(

        title: String,

        icon: String

    ) -> some View {

        HStack {

            Image(

                systemName: icon

            )

            Text(title)

                .font(.headline)

        }

    }

    // ========================================================

    // MARK: - Metric

    // ========================================================

    private func metric(

        title: String,

        value: String

    ) -> some View {

        VStack(

            alignment: .leading

        ) {

            Text(value)

                .font(.headline)

                .monospacedDigit()

            Text(title)

                .font(.caption)

                .foregroundStyle(.secondary)

        }

        .frame(

            maxWidth: .infinity,

            alignment: .leading

        )

    }

    // ========================================================

    // MARK: - Risk Metric

    // ========================================================

    private func riskMetric(

        _ title: String,

        _ value: Double

    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(

                percent(value)

            )

            .fontWeight(.semibold)

            .monospacedDigit()

        }

        .font(.subheadline)

    }

    // ========================================================

    // MARK: - Percentage

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

    // MARK: - Run Simulation

    // ========================================================

    private func runSimulation() {
        guard !isRunning else { return }

        isRunning = true

        Task { @MainActor in
            let year = Int(currentYear)
            let calendarYear = Calendar.current.component(.year, from: Date())

            if year == calendarYear {
                do {
                    yahooVolumePoints = try await YahooMarketVolumeService.currentYearVolume()
                    yahooVolumeStatus = yahooVolumePoints.isEmpty
                        ? "Yahoo returned no current-year volume observations."
                        : "Loaded \(yahooVolumePoints.count) current-year daily observations from Yahoo Finance (S&P 500)."
                } catch {
                    yahooVolumePoints = []
                    yahooVolumeStatus = "Yahoo volume unavailable; using the model's historical volume input."
                }
            } else {
                yahooVolumePoints = []
                yahooVolumeStatus = "Yahoo current-year volume is used only for the current calendar year."
            }

            result = engine.analyze(
                currentYear: year,
                currentVolumePoints: yahooVolumePoints
            )

            generateCrashSnapshots()
            isRunning = false
        }
    }

    private func generateCrashSnapshots() {
        var snapshots: [MarketCrashSnapshot] = []

        for index in engine.crashRecords.indices {
            guard let analysis = engine.analyzeHistoricalCrash(at: index) else {
                continue
            }

            let historical = analysis.result
            snapshots.append(
                MarketCrashSnapshot(
                    year: analysis.year,
                    intervalYears: analysis.intervalYears,
                    alpha: historical.alpha,
                    equilibriumPressure: historical.equilibriumPressure,
                    volumePressure: historical.volumePressure,
                    cellularStress: historical.cellularStress,
                    criticalFraction: historical.criticalFraction,
                    crashFraction: historical.crashFraction,
                    systemicRisk: historical.systemicRisk,
                    riskLevel: historical.riskLevel,
                    riskWindowStart: historical.predictedWindowStart,
                    riskWindowEnd: historical.predictedWindowEnd,
                    cells: analysis.cells
                )
            )
        }

        _ = engine.analyze(
            currentYear: Int(currentYear),
            currentVolumePoints: yahooVolumePoints
        )
        crashSnapshots = snapshots
    }

    

}

// ============================================================

// MARK: - CARD STYLE

// ============================================================

private struct CardStyle: ViewModifier {

    func body(

        content: Content

    ) -> some View {

        content

            .padding()

            .background(

                Color(.systemBackground)

            )

            .clipShape(

                RoundedRectangle(

                    cornerRadius: 16

                )

            )

            .shadow(

                color: .black.opacity(0.04),

                radius: 5

            )

    }

}

private extension View {

    func cardStyle() -> some View {

        modifier(

            CardStyle()

        )

    }

}

// ============================================================

// MARK: - PREVIEW

// ============================================================

#Preview {

    ContentView()

}
