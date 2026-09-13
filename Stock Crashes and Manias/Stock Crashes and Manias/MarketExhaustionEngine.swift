//
//  MarketExhaustionEngine.swift
//  Stock Crashes and Manias
//
//  Created by David Nishimoto on 9/10/26.
//

import Foundation
import SwiftUI
import Combine

// ============================================================
// MARK: - Market Exhaustion Engine
// ============================================================
//
// Architecture:
//
// HistoricalYear
//      ↓
// MarketScenario
//      ↓
// MarketExhaustionEngine
//      ↓
// stepCA()
//      ↓
// MarketCell[]
//      ↓
// MarketRiskResult
//
// MarketParameters is the ONLY coefficient/parameter system.
//
// MarketScenario is historical/macro INPUT DATA.
// It is not a second parameter system.
//
// The cellular automaton is synchronous:
// all neighbor reads come from previousCells and all writes
// go into nextCells.
//
// One generation currently represents one simulated year
// because generationsPerYear defaults to 1.
// ============================================================

@MainActor
final class MarketExhaustionEngine: ObservableObject {

    // ========================================================
    // MARK: - Published Simulation State
    // ========================================================

    @Published private(set) var cells: [MarketCell] = []

    @Published private(set) var yearlyRiskHistory:
        [YearlyRiskSnapshot] = []

    @Published private(set) var historicalFrames:
        [HistoricalCAFrame] = []

    @Published private(set) var historicalAnalyses:
        [HistoricalCrashAnalysis] = []

    // ========================================================
    // MARK: - Canonical Configuration
    // ========================================================

    private(set) var parameters: MarketParameters

    private var random: SplitMix64

    private let historicalData: HistoricalJSONRoot

    // ========================================================
    // MARK: - Initialization
    // ========================================================

    init(
        parameters: MarketParameters = MarketParameters(),
        historicalJSON: String = historicalMarketJSON
    ) {
        self.parameters = parameters
        self.random = SplitMix64(
            seed: parameters.randomSeed
        )

        self.historicalData =
            Self.decodeHistoricalData(
                historicalJSON
            )

        resetCells()
    }

    // ========================================================
    // MARK: - Parameter Updates
    // ========================================================

    func updateParameters(
        _ newParameters: MarketParameters
    ) {
        parameters = newParameters

        random = SplitMix64(
            seed: parameters.randomSeed
        )

        resetCells()
    }

    // ========================================================
    // MARK: - Reset
    // ========================================================

    func resetCells() {

        random = SplitMix64(
            seed: parameters.randomSeed
        )

        yearlyRiskHistory.removeAll(
            keepingCapacity: true
        )

        historicalFrames.removeAll(
            keepingCapacity: true
        )

        historicalAnalyses.removeAll(
            keepingCapacity: true
        )

        let width = max(
            parameters.gridWidth,
            1
        )

        let height = max(
            parameters.gridHeight,
            1
        )

        let count = width * height

        cells = (0..<count).map { id in

            let variation =
                random.centeredUnit() * 0.04

            let energy =
                bounded(
                    parameters.initialEnergy + variation
                )

            let liquidity =
                bounded(
                    parameters.initialLiquidity
                )

            let capital =
                bounded(
                    parameters.initialCapital
                )

            return MarketCell(
                id: id,
                energy: energy,
                liquidity: liquidity,
                capital: capital,
                momentum: 0.0,
                financialPotential: 0.0,
                potentialGradient: 0.0,
                exhaustion: 0.0,
                contagion: 0.0,
                stress: 0.0,
                state: .stable
            )
        }
    }

    // ========================================================
    // MARK: - Public Simulation
    // ========================================================

    /// Runs the CA for the requested number of years.
    ///
    /// One generation represents one year according to
    /// generationsPerYear.
    @discardableResult
    func run(
        years: Int,
        equilibriumPressure: Double,
        volumePressure: Double,
        scenario: MarketScenario = .neutral
    ) -> MarketRiskResult {

        guard years > 0 else {
            return makeRiskResult(
                year: 0,
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure
            )
        }

        var result =
            makeRiskResult(
                year: 0,
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure
            )

        let generationsPerYear =
            max(
                parameters.generationsPerYear,
                1
            )

        for year in 1...years {

            for _ in 0..<generationsPerYear {
                stepCA(
                    equilibriumPressure:
                        equilibriumPressure,
                    volumePressure:
                        volumePressure,
                    scenario: scenario
                )
            }

            result = makeRiskResult(
                year: year,
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure
            )

            yearlyRiskHistory.append(
                YearlyRiskSnapshot(
                    year: year,
                    equilibriumPressure:
                        result.equilibriumPressure,
                    volumePressure:
                        result.volumePressure,
                    systemicRisk:
                        result.systemicRisk,
                    meanEnergy:
                        result.meanEnergy,
                    meanMomentum:
                        result.meanMomentum,
                    meanExhaustion:
                        result.meanExhaustion,
                    meanStress:
                        result.meanStress,
                    meanFinancialPotential:
                        result.meanFinancialPotential,
                    criticalFraction:
                        result.criticalFraction,
                    crashFraction:
                        result.crashFraction
                )
            )
        }

        return result
    }

    /// Runs exactly one simulated year.
    @discardableResult
    func runYear(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double,
        scenario: MarketScenario = .neutral
    ) -> MarketRiskResult {

        let generations =
            max(
                parameters.generationsPerYear,
                1
            )

        for _ in 0..<generations {

            stepCA(
                equilibriumPressure:
                    equilibriumPressure,
                volumePressure:
                    volumePressure,
                scenario: scenario
            )
        }

        let result = makeRiskResult(
            year: year,
            equilibriumPressure:
                equilibriumPressure,
            volumePressure:
                volumePressure
        )

        yearlyRiskHistory.append(
            YearlyRiskSnapshot(
                year: year,
                equilibriumPressure:
                    result.equilibriumPressure,
                volumePressure:
                    result.volumePressure,
                systemicRisk:
                    result.systemicRisk,
                meanEnergy:
                    result.meanEnergy,
                meanMomentum:
                    result.meanMomentum,
                meanExhaustion:
                    result.meanExhaustion,
                meanStress:
                    result.meanStress,
                meanFinancialPotential:
                    result.meanFinancialPotential,
                criticalFraction:
                    result.criticalFraction,
                crashFraction:
                    result.crashFraction
            )
        )

        return result
    }

    // ========================================================
    // MARK: - Core Cellular Automaton
    // ========================================================

    private func stepCA(
        equilibriumPressure: Double,
        volumePressure: Double,
        scenario: MarketScenario
    ) {

        guard !cells.isEmpty else {
            return
        }

        // ----------------------------------------------------
        // Normalize historical/macro inputs.
        // ----------------------------------------------------

        let normalizedMoneySupply =
            bounded(
                scenario.moneySupplyChangePercent / 20.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let normalizedInflation =
            bounded(
                scenario.inflationPercent / 15.0
            )

        let normalizedTaxGrowth =
            bounded(
                scenario.taxationGrowthPercent / 15.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let normalizedEconomicGrowth =
            bounded(
                scenario.economicGrowthPercent / 20.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let normalizedStockGrowth =
            bounded(
                scenario.stockGrowthPercent / 60.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let normalizedPreviousStockGrowth =
            bounded(
                scenario.previousStockGrowthPercent / 60.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let normalizedBondYield =
            bounded(
                scenario.bondYieldAvgPercent / 15.0
            )

        let normalizedBankingStress =
            bounded(
                scenario.bankingCreditStressRating / 10.0
            )

        let normalizedPolicy =
            bounded(
                scenario.moneyPolicyChangeImpact / 10.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let normalizedShock =
            bounded(
                abs(
                    scenario.externalShockMagnitudePercent
                ) / 20.0
            )

        // ----------------------------------------------------
        // External forcing.
        // ----------------------------------------------------

        let equilibrium =
            bounded(
                equilibriumPressure
            )

        let volume =
            bounded(
                volumePressure
            )

        let externalForcing =
            bounded(
                parameters.equilibriumWeight * equilibrium
                +
                parameters.volumeWeight * volume
            )

        // ----------------------------------------------------
        // Expansionary macro forcing.
        // ----------------------------------------------------

        let positiveMoney =
            max(
                normalizedMoneySupply,
                0.0
            )

        let positiveEconomicGrowth =
            max(
                normalizedEconomicGrowth,
                0.0
            )

        let positiveStockGrowth =
            max(
                normalizedStockGrowth,
                0.0
            )

        let positivePolicy =
            max(
                normalizedPolicy,
                0.0
            )

        let expansionaryEnergy =
            positiveMoney
            * parameters.moneySupplyEnergyWeight
            +
            positiveEconomicGrowth
            * parameters.economicGrowthEnergyWeight
            +
            positiveStockGrowth
            * parameters.economicGrowthEnergyWeight
            +
            positivePolicy
            * parameters.moneySupplyEnergyWeight

        // ----------------------------------------------------
        // Contractionary macro forcing.
        // ----------------------------------------------------

        let negativeMoney =
            max(
                -normalizedMoneySupply,
                0.0
            )

        let negativeEconomicGrowth =
            max(
                -normalizedEconomicGrowth,
                0.0
            )

        let positiveTaxPressure =
            max(
                normalizedTaxGrowth,
                0.0
            )

        let contractionaryEnergy =
            negativeMoney
            * parameters.moneySupplyEnergyWeight
            +
            normalizedInflation
            * parameters.economicGrowthEnergyWeight
            +
            positiveTaxPressure
            * parameters.taxLiquidityRate
            +
            normalizedBondYield
            * parameters.bondYieldLiquidityRate
            +
            normalizedBankingStress
            * parameters.bankingLiquidityRate
            +
            normalizedShock
            * parameters.externalShockEnergyWeight

        let macroEnergyForcing =
            bounded(
                expansionaryEnergy
                - contractionaryEnergy,
                minimum: -1.0,
                maximum: 1.0
            )

        // ----------------------------------------------------
        // Macro momentum.
        // ----------------------------------------------------

        let growthMomentum =
            normalizedEconomicGrowth
            * 0.40
            +
            normalizedStockGrowth
            * 0.40
            +
            normalizedMoneySupply
            * 0.20
            +
            normalizedPolicy
            * 0.20

        let slowdownMomentum =
            max(
                -normalizedEconomicGrowth,
                0.0
            )
            * 0.40
            +
            max(
                -normalizedStockGrowth,
                0.0
            )
            * 0.40
            +
            normalizedBondYield
            * 0.20
            +
            normalizedBankingStress
            * 0.20
            +
            normalizedShock
            * 0.20

        let macroMomentum =
            bounded(
                growthMomentum
                - slowdownMomentum,
                minimum: -1.0,
                maximum: 1.0
            )

        // ----------------------------------------------------
        // Macro stress.
        // ----------------------------------------------------

        let macroStress =
            bounded(
                normalizedInflation
                +
                positiveTaxPressure * 0.25
                +
                normalizedBondYield * 0.30
                +
                normalizedBankingStress * 0.40
                +
                negativeEconomicGrowth * 0.30
                +
                normalizedShock * 0.40
            )

        // ----------------------------------------------------
        // Energy conversion.
        //
        // This explicitly connects energyConversion to the
        // actual cellular energy update.
        // ----------------------------------------------------

        let baseInjectedEnergy =
            externalForcing
            * parameters.energyInjectionRate

        let macroInjectedEnergy =
            macroEnergyForcing
            * parameters.macroEnergyInjectionRate

        let rawInjectedEnergy =
            baseInjectedEnergy
            +
            macroInjectedEnergy

        let convertedInjectedEnergy =
            rawInjectedEnergy
            *
            bounded(
                parameters.energyConversion,
                minimum: 0.0,
                maximum: 1.0
            )

        // ----------------------------------------------------
        // Synchronous CA update.
        //
        // NEVER read neighbors from nextCells.
        // ----------------------------------------------------

        let previousCells = cells

        var nextCells = previousCells

        for index in previousCells.indices {

            let cell =
                previousCells[index]

            let neighbors =
                neighboringCells(
                    index: index,
                    cells: previousCells
                )

            // ------------------------------------------------
            // Neighbor averages.
            // ------------------------------------------------

            let neighborEnergy =
                mean(
                    neighbors.map(\.energy)
                )

            let neighborMomentum =
                mean(
                    neighbors.map(\.momentum)
                )

            let neighborPotential =
                mean(
                    neighbors.map(
                        \.financialPotential
                    )
                )

            // ------------------------------------------------
            // Energy transfer.
            // ------------------------------------------------

            let localEnergyTransfer =
                (
                    neighborEnergy
                    - cell.energy
                )
                *
                parameters.energyTransferRate

            let preliminaryEnergy =
                cell.energy
                *
                parameters.energyRetention
                +
                convertedInjectedEnergy
                +
                localEnergyTransfer

            let dissipatedEnergy =
                max(
                    preliminaryEnergy,
                    0.0
                )
                *
                parameters.dissipationRate

            let updatedEnergy =
                bounded(
                    preliminaryEnergy
                    - dissipatedEnergy
                )

            // ------------------------------------------------
            // Momentum.
            // ------------------------------------------------

            let momentumFromExternalForce =
                (
                    externalForcing
                    - 0.5
                )
                *
                parameters.momentumResponse

            let momentumFromMacro =
                macroMomentum
                *
                parameters.macroMomentumResponse

            let momentumFromGradient =
                (
                    neighborPotential
                    - cell.financialPotential
                )
                *
                parameters.potentialGradientResponse

            let momentumTransfer =
                (
                    neighborMomentum
                    - cell.momentum
                )
                *
                parameters.momentumTransferRate

            let updatedMomentum =
                bounded(
                    cell.momentum
                    *
                    parameters.momentumRetention
                    +
                    momentumFromExternalForce
                    +
                    momentumFromMacro
                    +
                    momentumFromGradient
                    +
                    momentumTransfer,
                    minimum: -1.0,
                    maximum: 1.0
                )

            // ------------------------------------------------
            // Financial potential.
            //
            // This is a model-defined financial potential,
            // not physical gravitational potential.
            // ------------------------------------------------

            let potentialInput =
                updatedEnergy
                *
                parameters.potentialEnergyWeight
                +
                abs(updatedMomentum)
                *
                parameters.potentialMomentumWeight

            let updatedPotential =
                bounded(
                    cell.financialPotential
                    +
                    (
                        potentialInput
                        -
                        cell.financialPotential
                    )
                    *
                    parameters.potentialGain
                )

            let potentialGradient =
                bounded(
                    updatedPotential
                    - neighborPotential,
                    minimum: -1.0,
                    maximum: 1.0
                )

            // ------------------------------------------------
            // Liquidity depletion.
            // ------------------------------------------------

            let baseLiquidityDepletion =
                max(
                    externalForcing,
                    0.0
                )
                *
                parameters.liquidityDepletionRate

            let inflationLiquidity =
                normalizedInflation
                *
                parameters.inflationLiquidityRate

            let bondLiquidity =
                normalizedBondYield
                *
                parameters.bondYieldLiquidityRate

            let bankingLiquidity =
                normalizedBankingStress
                *
                parameters.bankingLiquidityRate

            let taxLiquidity =
                positiveTaxPressure
                *
                parameters.taxLiquidityRate

            let shockLiquidity =
                normalizedShock
                *
                parameters.externalShockCapitalRate

            let financialPotentialLiquidity =
                updatedPotential
                *
                parameters.liquidityDepletionRate

            let liquidityDepletion =
                baseLiquidityDepletion
                +
                inflationLiquidity
                +
                bondLiquidity
                +
                bankingLiquidity
                +
                taxLiquidity
                +
                shockLiquidity
                +
                financialPotentialLiquidity

            let updatedLiquidity =
                bounded(
                    cell.liquidity
                    - liquidityDepletion
                    +
                    parameters.exhaustionRecoveryRate
                    * 0.25
                )

            // ------------------------------------------------
            // Capital depletion.
            // ------------------------------------------------

            let capitalDepletion =
                updatedPotential
                *
                parameters.capitalDepletionRate
                +
                normalizedTaxGrowth
                *
                parameters.taxCapitalRate
                +
                normalizedBankingStress
                *
                parameters.bankingCapitalRate
                +
                normalizedShock
                *
                parameters.externalShockCapitalRate
                +
                max(
                    -normalizedEconomicGrowth,
                    0.0
                )
                *
                parameters.capitalDepletionRate

            let updatedCapital =
                bounded(
                    cell.capital
                    - capitalDepletion
                )

            // ------------------------------------------------
            // Neighbor contagion.
            //
            // Only critical/crashed neighbors contribute.
            // ------------------------------------------------

            let criticalNeighborCount =
                neighbors.reduce(
                    into: 0
                ) { count, neighbor in

                    if neighbor.state == .critical
                        || neighbor.state == .crashed
                    {
                        count += 1
                    }
                }

            let contagionFraction =
                neighbors.isEmpty
                ? 0.0
                : Double(
                    criticalNeighborCount
                )
                /
                Double(
                    neighbors.count
                )

            let updatedContagion =
                bounded(
                    contagionFraction
                    *
                    parameters.contagionRate
                )

            // ------------------------------------------------
            // Resource depletion.
            // ------------------------------------------------

            let energyDepletion =
                bounded(
                    1.0
                    - updatedEnergy
                )

            let resourceDepletion =
                bounded(
                    (
                        1.0
                        - updatedLiquidity
                    )
                    * 0.50
                    +
                    (
                        1.0
                        - updatedCapital
                    )
                    * 0.50
                )

            // ------------------------------------------------
            // Exhaustion.
            // ------------------------------------------------

            let directExhaustion =
                energyDepletion
                *
                parameters.energyDepletionStressWeight

            let resourceExhaustion =
                resourceDepletion
                *
                parameters.exhaustionAccumulationRate

            let macroExhaustion =
                macroStress
                *
                parameters.macroExhaustionRate

            let recovery =
                updatedLiquidity
                *
                updatedCapital
                *
                parameters.exhaustionRecoveryRate

            let updatedExhaustion =
                bounded(
                    cell.exhaustion
                    +
                    directExhaustion
                    +
                    resourceExhaustion
                    +
                    macroExhaustion
                    -
                    recovery
                )

            // ------------------------------------------------
            // Stress components.
            // ------------------------------------------------

            let energyStress =
                energyDepletion
                *
                parameters.energyWeight

            let momentumStress =
                max(
                    -updatedMomentum,
                    0.0
                )
                *
                parameters.momentumWeight

            let potentialStress =
                updatedPotential
                *
                parameters.potentialWeight

            let exhaustionStress =
                updatedExhaustion
                *
                parameters.exhaustionWeight

            let contagionStress =
                updatedContagion
                *
                parameters.contagionWeight

            let macroStressComponent =
                macroStress
                *
                parameters.macroStressWeight

            let dissipationStress =
                dissipatedEnergy
                *
                parameters.energyDissipationWeight

            let potentialGradientStress =
                abs(
                    potentialGradient
                )
                *
                parameters.potentialWeight
                *
                0.50

            // ------------------------------------------------
            // Stochastic perturbation.
            //
            // Deterministic because SplitMix64 is reset from
            // MarketParameters.randomSeed.
            // ------------------------------------------------

            let noise =
                random.centeredUnit()
                *
                0.02

            let rawStress =
                energyStress
                +
                momentumStress
                +
                potentialStress
                +
                exhaustionStress
                +
                contagionStress
                +
                macroStressComponent
                +
                dissipationStress
                +
                potentialGradientStress
                +
                noise

            let updatedStress =
                bounded(
                    rawStress
                )

            // ------------------------------------------------
            // State classification.
            // ------------------------------------------------

            let updatedState =
                classifyState(
                    stress: updatedStress,
                    energy: updatedEnergy
                )

            nextCells[index] =
                MarketCell(
                    id: cell.id,
                    energy: updatedEnergy,
                    liquidity: updatedLiquidity,
                    capital: updatedCapital,
                    momentum: updatedMomentum,
                    financialPotential: updatedPotential,
                    potentialGradient: potentialGradient,
                    exhaustion: updatedExhaustion,
                    contagion: updatedContagion,
                    stress: updatedStress,
                    state: updatedState
                )
        }

        // ----------------------------------------------------
        // Commit only after every cell has been calculated.
        // ----------------------------------------------------

        cells = nextCells
    }

    // ========================================================
    // MARK: - Neighbor Lookup
    // ========================================================

    private func neighboringCells(
        index: Int,
        cells: [MarketCell]
    ) -> [MarketCell] {

        let width =
            max(
                parameters.gridWidth,
                1
            )

        let height =
            max(
                parameters.gridHeight,
                1
            )

        let x = index % width
        let y = index / width

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

        var result: [MarketCell] = []

        result.reserveCapacity(
            directions.count
        )

        for (dx, dy) in directions {

            let nx = x + dx
            let ny = y + dy

            guard nx >= 0,
                  nx < width,
                  ny >= 0,
                  ny < height
            else {
                continue
            }

            let neighborIndex =
                ny * width + nx

            guard neighborIndex >= 0,
                  neighborIndex < cells.count
            else {
                continue
            }

            result.append(
                cells[neighborIndex]
            )
        }

        return result
    }

    // ========================================================
    // MARK: - Historical Data Conversion
    // ========================================================

    private func scenario(
        from year: HistoricalYear,
        previousYear: HistoricalYear?
    ) -> MarketScenario {

        MarketScenario(
            moneySupplyChangePercent:
                year.m2GrowthPercent ?? 0.0,

            inflationPercent:
                year.inflationPercent ?? 0.0,

            taxationGrowthPercent:
                year.taxGrowthPercent ?? 0.0,

            economicGrowthPercent:
                year.economicGrowthPercent ?? 0.0,

            stockGrowthPercent:
                year.stockGrowthPercent ?? 0.0,

            previousStockGrowthPercent:
                previousYear?.stockGrowthPercent
                ??
                year.stockGrowthPercent
                ??
                0.0,

            bondYieldAvgPercent:
                year.bondYieldAvgPercent ?? 0.0,

            bankingCreditStressRating:
                year.bankingCreditStressRating ?? 0.0,

            moneyPolicyChangeImpact:
                year.moneyPolicyChangeImpact ?? 0.0,

            externalShockMagnitudePercent:
                0.0
        )
    }

    // ========================================================
    // MARK: - Historical Year Selection
    // ========================================================

    private func historicalYear(
        for targetYear: Int
    ) -> HistoricalYear? {

        historicalData.crashPeriods
            .flatMap(\.priorYears)
            .filter {
                $0.year <= targetYear
            }
            .max {
                $0.year < $1.year
            }
    }

    private func historicalYearsThrough(
        _ year: Int
    ) -> [HistoricalYear] {

        historicalData.crashPeriods
            .flatMap(\.priorYears)
            .filter {
                $0.year <= year
            }
            .sorted {
                $0.year < $1.year
            }
    }

    // ========================================================
    // MARK: - Historical Volume Pressure
    // ========================================================

    private func historicalVolumePressure(
        through year: Int
    ) -> Double {

        let points =
            historicalYearsThrough(year)
            .compactMap { historicalYear -> MarketVolumePoint? in

                guard let volume =
                    historicalYear.stockVolumeMillions,
                      volume.isFinite
                else {
                    return nil
                }

                return MarketVolumePoint(
                    year: historicalYear.year,
                    volumeMillions: volume
                )
            }
            .sorted {
                $0.year < $1.year
            }

        guard points.count >= 2 else {
            return 0.0
        }

        let recent =
            points[points.count - 1]

        let previous =
            points[points.count - 2]

        let recentGrowth =
            (
                recent.volumeMillions
                - previous.volumeMillions
            )
            /
            max(
                abs(previous.volumeMillions),
                1.0
            )

        guard points.count >= 3 else {

            return bounded(
                max(
                    recentGrowth,
                    0.0
                ),
                minimum: 0.0,
                maximum: 1.0
            )
        }

        let older =
            points[points.count - 3]

        let previousGrowth =
            (
                previous.volumeMillions
                - older.volumeMillions
            )
            /
            max(
                abs(older.volumeMillions),
                1.0
            )

        let acceleration =
            recentGrowth
            - previousGrowth

        let growthComponent =
            max(
                recentGrowth,
                0.0
            )

        let accelerationComponent =
            max(
                acceleration,
                0.0
            )

        return bounded(
            0.70 * growthComponent
            +
            0.30 * accelerationComponent,
            minimum: 0.0,
            maximum: 1.0
        )
    }

    // ========================================================
    // MARK: - Historical Equilibrium Pressure
    // ========================================================

    private func historicalEquilibriumPressure(
        for year: HistoricalYear
    ) -> Double {

        let money =
            bounded(
                (year.m2GrowthPercent ?? 0.0)
                / 20.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let economic =
            bounded(
                (year.economicGrowthPercent ?? 0.0)
                / 20.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let stock =
            bounded(
                (year.stockGrowthPercent ?? 0.0)
                / 60.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let policy =
            bounded(
                (year.moneyPolicyChangeImpact ?? 0.0)
                / 10.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let inflation =
            bounded(
                (year.inflationPercent ?? 0.0)
                / 15.0
            )

        let bond =
            bounded(
                (year.bondYieldAvgPercent ?? 0.0)
                / 15.0
            )

        let banking =
            bounded(
                (year.bankingCreditStressRating ?? 0.0)
                / 10.0
            )

        let positiveExpansion =
            max(money, 0.0) * 0.20
            +
            max(economic, 0.0) * 0.20
            +
            max(stock, 0.0) * 0.20
            +
            max(policy, 0.0) * 0.10

        let contraction =
            max(-money, 0.0) * 0.10
            +
            max(-economic, 0.0) * 0.15
            +
            inflation * 0.15
            +
            bond * 0.15
            +
            banking * 0.25

        return bounded(
            positiveExpansion
            + contraction,
            minimum: 0.0,
            maximum: 1.0
        )
    }

    // ========================================================
    // MARK: - Cycle Pressure Exponent
    // ========================================================

    /// This is NOT an empirical power-law exponent.
    ///
    /// It is a model-defined cycle-pressure exponent derived
    /// from dispersion in historical crash intervals.
    private func estimateCyclePressureExponent(
        intervals: [Int]
    ) -> Double {

        guard !intervals.isEmpty else {
            return 0.5
        }

        let values =
            intervals.map(Double.init)

        let meanInterval =
            mean(values)

        guard meanInterval > 0.0 else {
            return 0.5
        }

        let variance =
            mean(
                values.map {
                    pow(
                        $0 - meanInterval,
                        2.0
                    )
                }
            )

        let standardDeviation =
            sqrt(
                max(
                    variance,
                    0.0
                )
            )

        let coefficientOfVariation =
            standardDeviation
            /
            meanInterval

        let exponent =
            (
                1.0
                +
                coefficientOfVariation
            )
            /
            3.0

        return bounded(
            exponent,
            minimum: 0.25,
            maximum: 1.0
        )
    }

    // ========================================================
    // MARK: - Cycle Pressure
    // ========================================================

    private func cyclePressure(
        yearsSinceCrash: Int,
        meanInterval: Double,
        exponent: Double
    ) -> Double {

        guard meanInterval >= 0.0 else {
            return 0.0
        }

        let x =
            (
                Double(
                    max(
                        yearsSinceCrash,
                        0
                    )
                )
                +
                1.0
            )
            /
            (
                meanInterval
                +
                1.0
            )

        let raw =
            pow(
                max(x, 0.0),
                bounded(
                    exponent,
                    minimum: 0.25,
                    maximum: 1.0
                )
            )

        return bounded(
            raw
        )
    }

    // ========================================================
    // MARK: - Historical Crash Analysis
    // ========================================================

    @discardableResult
    func analyzeHistoricalCrash(
        at period: HistoricalCrashPeriod
    ) -> HistoricalCrashAnalysis? {

        guard validateHistoricalCausality(
            period: period
        )
        else {
            return nil
        }

        resetCells()

        let sortedYears =
            period.priorYears.sorted {
                $0.year < $1.year
            }

        guard !sortedYears.isEmpty else {
            return nil
        }

        let crashIntervals =
            historicalData.crashPeriods
                .map(\.crashYear)
                .sorted()
                .adjacentPairs()
                .map {
                    $1 - $0
                }

        let exponent =
            estimateCyclePressureExponent(
                intervals: crashIntervals
            )

        let meanInterval =
            mean(
                crashIntervals.map(Double.init)
            )

        var previousYear:
            HistoricalYear?

        var finalResult:
            MarketRiskResult?

        for historicalYear in sortedYears {

            let scenarioValue =
                scenario(
                    from: historicalYear,
                    previousYear: previousYear
                )

            let equilibrium =
                historicalEquilibriumPressure(
                    for: historicalYear
                )

            let volume =
                historicalVolumePressure(
                    through: historicalYear.year
                )

            let yearsSincePreviousCrash =
                max(
                    historicalYear.year
                    -
                    latestCrashYear(
                        before: historicalYear.year
                    ),
                    0
                )

            let cycle =
                cyclePressure(
                    yearsSinceCrash:
                        yearsSincePreviousCrash,
                    meanInterval:
                        meanInterval,
                    exponent:
                        exponent
                )

            let combinedEquilibrium =
                bounded(
                    0.70 * equilibrium
                    +
                    0.30 * cycle
                )

            finalResult =
                runYear(
                    year:
                        historicalYear.year,
                    equilibriumPressure:
                        combinedEquilibrium,
                    volumePressure:
                        volume,
                    scenario:
                        scenarioValue
                )

            historicalFrames.append(
                HistoricalCAFrame(
                    year:
                        historicalYear.year,
                    isCrashYear:
                        false,
                    moneyEnergyChange:
                        scenarioValue
                            .moneySupplyChangePercent,
                    volumePressure:
                        volume,
                    cells:
                        cells
                )
            )

            previousYear =
                historicalYear
        }

        guard let result = finalResult else {
            return nil
        }

        let interval =
            period.crashYear
            -
            sortedYears.last!.year

        let analysis =
            makeHistoricalAnalysis(
                period: period,
                result: result
            )

        historicalAnalyses.append(
            HistoricalCrashAnalysis(
                year:
                    period.crashYear,
                intervalYears:
                    interval,
                result:
                    result,
                cells:
                    cells
            )
        )

        return HistoricalCrashAnalysis(
            year:
                period.crashYear,
            intervalYears:
                interval,
            result:
                result,
            cells:
                cells
        )
    }

    // ========================================================
    // MARK: - Analyze All Historical Crashes
    // ========================================================

    @discardableResult
    func analyzeAllHistoricalCrashes()
        -> [HistoricalCrashAnalysis]
    {
        historicalAnalyses.removeAll(
            keepingCapacity: true
        )

        historicalFrames.removeAll(
            keepingCapacity: true
        )

        for period in historicalData.crashPeriods {

            _ = analyzeHistoricalCrash(
                at: period
            )
        }

        return historicalAnalyses
    }

    // ========================================================
    // MARK: - Historical Rows
    // ========================================================

    func historicalCARows()
        -> [HistoricalCARow]
    {
        var rows: [HistoricalCARow] = []

        for period in historicalData.crashPeriods {

            guard let analysis =
                analyzeHistoricalCrash(
                    at: period
                )
            else {
                continue
            }

            let historicalAnalysis =
                makeHistoricalAnalysis(
                    period: period,
                    result: analysis.result
                )

            rows.append(
                HistoricalCARow(
                    period:
                        period,
                    analysis:
                        historicalAnalysis,
                    result:
                        analysis.result,
                    cells:
                        analysis.cells
                )
            )
        }

        return rows
    }

    // ========================================================
    // MARK: - Historical Analysis Builder
    // ========================================================

    private func makeHistoricalAnalysis(
        period: HistoricalCrashPeriod,
        result: MarketRiskResult
    ) -> HistoricalAnalysis {

        let years =
            period.priorYears.sorted {
                $0.year < $1.year
            }

        let latest =
            years.last

        let previous =
            years.dropLast().last

        let crashInterval =
            period.crashYear
            -
            (latest?.year ?? period.crashYear)

        let stockVolumeGrowth =
            historicalVolumePressure(
                through:
                    latest?.year
                    ??
                    period.crashYear
            )

        let intervals =
            historicalData.crashPeriods
                .map(\.crashYear)
                .sorted()
                .adjacentPairs()
                .map {
                    $1 - $0
                }

        let powerLaw =
            estimateCyclePressureExponent(
                intervals:
                    intervals
            )

        let equilibrium =
            latest.map {
                historicalEquilibriumPressure(
                    for: $0
                )
            }
            ?? 0.0

        let optimism =
            bounded(
                max(
                    latest?.economicGrowthPercent
                        ?? 0.0,
                    0.0
                ) / 20.0
                +
                max(
                    latest?.stockGrowthPercent
                        ?? 0.0,
                    0.0
                ) / 60.0
            )

        let momentum =
            bounded(
                (
                    latest?.stockGrowthPercent
                        ?? 0.0
                ) / 60.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let previousMomentum =
            bounded(
                (
                    previous?.stockGrowthPercent
                        ?? latest?.stockGrowthPercent
                        ?? 0.0
                ) / 60.0,
                minimum: -1.0,
                maximum: 1.0
            )

        let momentumTurn =
            bounded(
                previousMomentum
                - momentum,
                minimum: -1.0,
                maximum: 1.0
            )

        return HistoricalAnalysis(
            crashYear:
                period.crashYear,

            priorYearsUsed:
                years.map(\.year),

            m2Growth:
                latest?.m2GrowthPercent ?? 0.0,

            inflation:
                latest?.inflationPercent ?? 0.0,

            bondYield:
                latest?.bondYieldAvgPercent ?? 0.0,

            taxGrowth:
                latest?.taxGrowthPercent ?? 0.0,

            economicGrowth:
                latest?.economicGrowthPercent ?? 0.0,

            stockGrowth:
                latest?.stockGrowthPercent ?? 0.0,

            stockVolumeGrowth:
                stockVolumeGrowth,

            moneyPolicyChangeImpact:
                latest?.moneyPolicyChangeImpact ?? 0.0,

            crashInterval:
                crashInterval,

            optimism:
                optimism,

            momentum:
                momentum,

            momentumTurn:
                momentumTurn,

            equilibrium:
                equilibrium,

            powerLaw:
                powerLaw,

            cellularRisk:
                result.systemicRisk,

            bankingCreditStressRating:
                latest?.bankingCreditStressRating ?? 0.0
        )
    }

    // ========================================================
    // MARK: - Historical Causality
    // ========================================================

    func validateHistoricalCausality(
        year: Int
    ) -> Bool {

        let allHistoricalYears =
            historicalData.crashPeriods
                .flatMap(\.priorYears)

        if let selected =
            historicalYear(
                for: year
            ) {

            guard selected.year <= year else {
                return false
            }
        }

        let selectedRows =
            allHistoricalYears.filter {
                $0.year <= year
            }

        guard selectedRows.allSatisfy({
            $0.year <= year
        })
        else {
            return false
        }

        let eligibleCrashes =
            crashRecords.filter {
                $0.year <= year
            }

        if let latest =
            eligibleCrashes.last {

            let canonicalLatest =
                crashRecords.last(
                    where: {
                        $0.year <= year
                    }
                )

            guard canonicalLatest?.year
                    == latest.year
            else {
                return false
            }
        }

        return true
    }
    private var crashRecords: [CrashRecord] {
        historicalData.crashPeriods.map { period in
            CrashRecord(
                year: period.crashYear,
                volumeMillions:
                    period.priorYears
                        .last(where: { $0.stockVolumeMillions != nil })?
                        .stockVolumeMillions
                        ?? 0.0
            )
        }
    }
    private func validateHistoricalCausality(
        period: HistoricalCrashPeriod
    ) -> Bool {

        period.priorYears.allSatisfy {
            $0.year < period.crashYear
        }
    }

    // ========================================================
    // MARK: - Latest Crash
    // ========================================================

    private func latestCrashYear(
        before year: Int
    ) -> Int {

        historicalData.crashPeriods
            .map(\.crashYear)
            .filter {
                $0 < year
            }
            .max()
            ?? year
    }

    // ========================================================
    // MARK: - Risk Result
    // ========================================================

    private func makeRiskResult(
        year: Int,
        equilibriumPressure: Double,
        volumePressure: Double
    ) -> MarketRiskResult {

        let meanEnergy =
            mean(
                cells.map(\.energy)
            )

        let meanMomentum =
            mean(
                cells.map(\.momentum)
            )

        let meanExhaustion =
            mean(
                cells.map(\.exhaustion)
            )

        let meanStress =
            mean(
                cells.map(\.stress)
            )

        let meanFinancialPotential =
            mean(
                cells.map(
                    \.financialPotential
                )
            )

        let critical =
            criticalCellFraction()

        let crashed =
            crashCellFraction()

        let systemic =
            systemicRisk(
                equilibrium:
                    equilibriumPressure,
                volume:
                    volumePressure,
                stress:
                    meanStress,
                critical:
                    critical,
                crashed:
                    crashed
            )

        return MarketRiskResult(
            year:
                year,

            equilibriumPressure:
                bounded(
                    equilibriumPressure
                ),

            volumePressure:
                bounded(
                    volumePressure
                ),

            meanEnergy:
                bounded(
                    meanEnergy
                ),

            meanMomentum:
                bounded(
                    meanMomentum,
                    minimum: -1.0,
                    maximum: 1.0
                ),

            meanExhaustion:
                bounded(
                    meanExhaustion
                ),

            meanStress:
                bounded(
                    meanStress
                ),

            meanFinancialPotential:
                bounded(
                    meanFinancialPotential
                ),

            criticalFraction:
                critical,

            crashFraction:
                crashed,

            systemicRisk:
                systemic,

            riskLevel:
                classifyState(
                    stress:
                        systemic,
                    energy:
                        1.0
                )
        )
    }

    // ========================================================
    // MARK: - Systemic Risk
    // ========================================================

    private func systemicRisk(
        equilibrium: Double,
        volume: Double,
        stress: Double,
        critical: Double,
        crashed: Double
    ) -> Double {

        let result =
            equilibrium
            *
            parameters.systemicEquilibriumWeight
            +
            volume
            *
            parameters.systemicVolumeWeight
            +
            stress
            *
            parameters.systemicStressWeight
            +
            critical
            *
            parameters.systemicCriticalWeight
            +
            crashed
            *
            parameters.systemicCrashWeight

        return bounded(
            result
        )
    }

    // ========================================================
    // MARK: - State Classification
    // ========================================================

    private func classifyState(
        stress: Double,
        energy: Double
    ) -> MarketState {

        let normalizedStress =
            bounded(
                stress
            )

        let normalizedEnergy =
            bounded(
                energy
            )

        if normalizedEnergy
            <= parameters
                .severeEnergyDepletionThreshold
        {
            return .crashed
        }

        if normalizedStress
            >= parameters.crashedThreshold
        {
            return .crashed
        }

        if normalizedStress
            >= parameters.criticalThreshold
        {
            return .critical
        }

        if normalizedStress
            >= parameters.stressedThreshold
        {
            return .stressed
        }

        if normalizedStress
            >= parameters.risingThreshold
        {
            return .rising
        }

        return .stable
    }

    // ========================================================
    // MARK: - Fractions
    // ========================================================

    func criticalCellFraction() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let count =
            cells.reduce(
                into: 0
            ) { result, cell in

                if cell.state == .critical {
                    result += 1
                }
            }

        return bounded(
            Double(count)
            /
            Double(cells.count)
        )
    }

    func crashCellFraction() -> Double {

        guard !cells.isEmpty else {
            return 0.0
        }

        let count =
            cells.reduce(
                into: 0
            ) { result, cell in

                if cell.state == .crashed {
                    result += 1
                }
            }

        return bounded(
            Double(count)
            /
            Double(cells.count)
        )
    }

    // ========================================================
    // MARK: - Current State Accessors
    // ========================================================

    func meanEnergy() -> Double {
        mean(
            cells.map(\.energy)
        )
    }

    func meanMomentum() -> Double {
        mean(
            cells.map(\.momentum)
        )
    }

    func meanExhaustion() -> Double {
        mean(
            cells.map(\.exhaustion)
        )
    }

    func meanStress() -> Double {
        mean(
            cells.map(\.stress)
        )
    }

    func meanFinancialPotential() -> Double {
        mean(
            cells.map(
                \.financialPotential
            )
        )
    }

    func currentSystemicRisk(
        equilibriumPressure: Double = 0.0,
        volumePressure: Double = 0.0
    ) -> Double {

        systemicRisk(
            equilibrium:
                equilibriumPressure,
            volume:
                volumePressure,
            stress:
                meanStress(),
            critical:
                criticalCellFraction(),
            crashed:
                crashCellFraction()
        )
    }

    func riskLevel(
        equilibriumPressure: Double = 0.0,
        volumePressure: Double = 0.0
    ) -> MarketState {

        classifyState(
            stress:
                currentSystemicRisk(
                    equilibriumPressure:
                        equilibriumPressure,
                    volumePressure:
                        volumePressure
                ),
            energy:
                1.0
        )
    }

    // ========================================================
    // MARK: - Parameter Validation
    // ========================================================

    func validateParameters()
        -> [String]
    {
        var errors: [String] = []

        if parameters.gridWidth < 1 {
            errors.append(
                "gridWidth must be at least 1."
            )
        }

        if parameters.gridHeight < 1 {
            errors.append(
                "gridHeight must be at least 1."
            )
        }

        if parameters.generationsPerYear < 1 {
            errors.append(
                "generationsPerYear must be at least 1."
            )
        }

        if !parameters.energyConversion.isFinite
            || parameters.energyConversion < 0.0
            || parameters.energyConversion > 1.0
        {
            errors.append(
                "energyConversion must be between 0 and 1."
            )
        }

        if !(
            parameters.risingThreshold
            <= parameters.stressedThreshold
            &&
            parameters.stressedThreshold
            <= parameters.criticalThreshold
            &&
            parameters.criticalThreshold
            <= parameters.crashedThreshold
        ) {
            errors.append(
                "State thresholds must be ordered rising <= stressed <= critical <= crashed."
            )
        }

        let systemicWeightSum =
            parameters.systemicEquilibriumWeight
            +
            parameters.systemicVolumeWeight
            +
            parameters.systemicStressWeight
            +
            parameters.systemicCriticalWeight
            +
            parameters.systemicCrashWeight

        if abs(
            systemicWeightSum - 1.0
        ) > 0.000001 {

            errors.append(
                "Systemic-risk weights must sum to 1.0."
            )
        }

        return errors
    }

    // ========================================================
    // MARK: - Historical Data Validation
    // ========================================================

    func validateHistoricalData()
        -> [String]
    {
        var errors: [String] = []

        for period in historicalData.crashPeriods {

            if !validateHistoricalCausality(
                period: period
            ) {
                errors.append(
                    "Crash year \(period.crashYear) contains a prior year that is not earlier than the crash year."
                )
            }

            let years =
                period.priorYears.map(\.year)

            if Set(years).count != years.count {
                errors.append(
                    "Crash year \(period.crashYear) contains duplicate historical years."
                )
            }
        }

        return errors
    }

    // ========================================================
    // MARK: - Historical Data Access
    // ========================================================

    func historicalCrashPeriods()
        -> [HistoricalCrashPeriod]
    {
        historicalData.crashPeriods
            .sorted {
                $0.crashYear < $1.crashYear
            }
    }

    func historicalScenario(
        for year: Int
    ) -> MarketScenario {

        guard let selected =
            historicalYear(
                for: year
            )
        else {
            return .neutral
        }

        let previous =
            historicalYearsThrough(
                selected.year
            )
            .dropLast()
            .last

        return scenario(
            from:
                selected,
            previousYear:
                previous
        )
    }

    // ========================================================
    // MARK: - Detailed Historical CA Result
    // ========================================================

    func makeHistoricalCAResult(
        for period: HistoricalCrashPeriod
    ) -> HistoricalCAResult? {

        guard let analysis =
            analyzeHistoricalCrash(
                at: period
            )
        else {
            return nil
        }

        let result =
            analysis.result

        let latest =
            period.priorYears
                .sorted {
                    $0.year < $1.year
                }
                .last

        let scenarioValue =
            latest.map {
                scenario(
                    from: $0,
                    previousYear:
                        period.priorYears
                            .sorted {
                                $0.year < $1.year
                            }
                            .dropLast()
                            .last
                )
            }
            ?? .neutral

        let energyDepletion =
            bounded(
                1.0
                - result.meanEnergy
            )

        let stockSlowdown =
            bounded(
                max(
                    -scenarioValue.stockGrowthPercent,
                    0.0
                ) / 60.0
            )

        let inflationPressure =
            bounded(
                scenarioValue.inflationPercent
                / 15.0
            )

        let shockPressure =
            bounded(
                abs(
                    scenarioValue
                        .externalShockMagnitudePercent
                )
                / 20.0
            )

        let bankingStress =
            bounded(
                scenarioValue
                    .bankingCreditStressRating
                / 10.0
            )

        let bankingPolicyInteraction =
            bounded(
                bankingStress
                *
                abs(
                    scenarioValue
                        .moneyPolicyChangeImpact
                )
                / 10.0
            )

        let equilibriumInflection =
            bounded(
                abs(
                    result.equilibriumPressure
                    -
                    result.volumePressure
                )
            )

        let usefulFuel =
            bounded(
                result.meanEnergy
                *
                (
                    1.0
                    -
                    result.meanExhaustion
                )
            )

        let overdrivePressure =
            bounded(
                result.meanFinancialPotential
                *
                result.meanMomentum
            )

        let effectiveFinancialMass =
            bounded(
                result.meanFinancialPotential
                *
                (
                    0.5
                    +
                    result.meanEnergy
                    * 0.5
                )
            )

        let financialPathForce =
            bounded(
                abs(
                    mean(
                        cells.map(
                            \.potentialGradient
                        )
                    )
                )
            )

        let contagion =
            bounded(
                mean(
                    cells.map(
                        \.contagion
                    )
                )
            )

        let nonlinearFinancialAttractor =
            bounded(
                result.meanFinancialPotential
                *
                result.meanFinancialPotential
                *
                (
                    0.5
                    +
                    result.meanStress
                )
            )

        return HistoricalCAResult(
            crashYear:
                period.crashYear,

            meanEnergy:
                result.meanEnergy,

            meanMomentum:
                result.meanMomentum,

            meanExhaustion:
                result.meanExhaustion,

            meanStress:
                result.meanStress,

            meanFinancialPotential:
                result.meanFinancialPotential,

            criticalFraction:
                result.criticalFraction,

            releaseFraction:
                result.crashFraction,

            energyDepletion:
                energyDepletion,

            stockSlowdown:
                stockSlowdown,

            inflationPressure:
                inflationPressure,

            shockPressure:
                shockPressure,

            bankingStress:
                bankingStress,

            bankingPolicyInteraction:
                bankingPolicyInteraction,

            equilibriumPressure:
                result.equilibriumPressure,

            equilibriumInflection:
                equilibriumInflection,

            usefulFuel:
                usefulFuel,

            overdrivePressure:
                overdrivePressure,

            systemicRisk:
                result.systemicRisk,

            finalEnergy:
                result.meanEnergy,

            finalMomentum:
                result.meanMomentum,

            financialPotential:
                result.meanFinancialPotential,

            potentialGradient:
                financialPathForce,

            localExhaustion:
                result.meanExhaustion,

            totalExhaustion:
                bounded(
                    result.meanExhaustion
                    +
                    energyDepletion
                    * 0.5
                ),

            effectiveFinancialMass:
                effectiveFinancialMass,

            financialPathForce:
                financialPathForce,

            contagion:
                contagion,

            nonlinearFinancialAttractor:
                nonlinearFinancialAttractor,

            cells:
                analysis.cells
        )
    }

    // ========================================================
    // MARK: - Utility
    // ========================================================

    private func bounded(
        _ value: Double,
        minimum: Double = 0.0,
        maximum: Double = 1.0
    ) -> Double {

        guard value.isFinite else {
            return minimum
        }

        return min(
            max(
                value,
                minimum
            ),
            maximum
        )
    }

    private func mean(
        _ values: [Double]
    ) -> Double {

        guard !values.isEmpty else {
            return 0.0
        }

        let finiteValues =
            values.filter {
                $0.isFinite
            }

        guard !finiteValues.isEmpty else {
            return 0.0
        }

        return finiteValues.reduce(
            0.0,
            +
        )
        /
        Double(
            finiteValues.count
        )
    }

    // ========================================================
    // MARK: - Historical JSON Decoder
    // ========================================================

    private static func decodeHistoricalData(
        _ json: String
    ) -> HistoricalJSONRoot {

        guard let data =
            json.data(
                using: .utf8
            )
        else {
            return HistoricalJSONRoot(
                crashPeriods: []
            )
        }

        do {

            return try JSONDecoder().decode(
                HistoricalJSONRoot.self,
                from: data
            )

        } catch {

            assertionFailure(
                "Historical market JSON failed to decode: \(error)"
            )

            return HistoricalJSONRoot(
                crashPeriods: []
            )
        }
    }
}

// ============================================================
// MARK: - Collection Helper
// ============================================================

private extension Array {

    func adjacentPairs()
        -> [(Element, Element)]
    {
        guard count >= 2 else {
            return []
        }

        var pairs:
            [(Element, Element)] = []

        pairs.reserveCapacity(
            count - 1
        )

        for index in 0..<(count - 1) {

            pairs.append(
                (
                    self[index],
                    self[index + 1]
                )
            )
        }

        return pairs
    }
}
