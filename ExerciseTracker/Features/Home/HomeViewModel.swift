//
//  HomeViewModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-23.
//

import SwiftUI
import HealthKit

@MainActor
class HomeViewModel: ObservableObject {
    private enum Constants {
        static let noData = "No Data"
    }
    private let calendar = Calendar.current
    private var now: Date { .now }
    private let hourlyIntervalComponents = DateComponents(hour: 1)
    let healthStore: HKHealthStore = .init()

    let dataType: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.distanceWalkingRunning),
        HKObjectType.activitySummaryType(),
        HKQuantityType(.bodyMass)
    ]

    @Published var todayStepsCount: String = Constants.noData
    @Published var hourlyStepCounts: [(Date, Double)] = []
    @Published var todayDistance: String = Constants.noData
    @Published var hourlyDistance: [(Date, Double)] = []
    @Published var todayBurnedCalories: String = Constants.noData
    @Published var todayBurnedCaloriesPercentage: Double = 0
    @Published var currentBodyMass: String = Constants.noData
    @Published var yearlyBodyMassList: [(Date, Double)] = []

    init() {}

    func fetchHealthData() async {
        async let steps: Void = fetchStepsPerHour()
        async let distance: Void = fetchDistancePerHour()
        async let move: Void = fetchMoveSummary()
        async let bodyMass: Void = fetchBodyMassData(
            startDate: calendar.date(byAdding: .month, value: -3, to: .now) ?? .now,
            endDate: now
        )
        _ = try? await (steps, distance, move, bodyMass)
    }

    private func fetchStepsPerHour() async throws {
        //        let startDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        let startDate = calendar.startOfDay(for: now)
        let (total, hourly) = try await fetchHourlyCumulativeSum(
            for: HKQuantityType(.stepCount),
            unit: .count(),
            formatter: { "\(Int($0))" },
            startDate: startDate,
            endDate: now,
            intervalComponents: hourlyIntervalComponents
        )
        self.todayStepsCount = total
        self.hourlyStepCounts = hourly
    }

    private func fetchDistancePerHour() async throws {
        //        let startDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        let startDate = calendar.startOfDay(for: now)
        let (total, hourly) = try await fetchHourlyCumulativeSum(
            for: HKQuantityType(.distanceWalkingRunning),
            unit: .meter(),
            formatter: { String(format: "%.2f", $0 / 1000.0) + " км" },
            startDate: startDate,
            endDate: now,
            intervalComponents: hourlyIntervalComponents
        )
        self.todayDistance = total
        self.hourlyDistance = hourly
    }

    private func fetchMoveSummary() async throws {
        //        var components = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: -1, to: now)!)
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.calendar = calendar
        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: components, end: components)
        let descriptor = HKActivitySummaryQueryDescriptor(predicate: predicate)
        let summaries = try await descriptor.result(for: healthStore)
        guard let summary = summaries.first else { return }
        let burned = summary.activeEnergyBurned.doubleValue(for: .largeCalorie())
        let goal = summary.activeEnergyBurnedGoal.doubleValue(for: .largeCalorie())
        self.todayBurnedCalories = "\(Int(burned))/\(Int(goal))KCAL"
        self.todayBurnedCaloriesPercentage = (burned / goal) * 100
    }

    private func fetchHourlyCumulativeSum(
        for quantityType: HKQuantityType,
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date,
        intervalComponents: DateComponents
    ) async throws -> (total: String, hourly: [(Date, Double)]) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: quantityType, predicate: predicate)
        // describes what kind of summary data you want from HealthKit.
        let queryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: intervalComponents
        )
        let results = try await queryDescriptor.result(for: healthStore)
        var hourlyValues: [(Date, Double)] = []
        results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let hour = statistics.startDate
            let value = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
            hourlyValues.append((hour, value))
        }
        let total = hourlyValues.map(\.1).reduce(0, +)
        return (formatter(Double(total)), hourlyValues)
    }

    private func fetchBodyMassData(startDate: Date, endDate: Date) async throws {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: weightType, predicate: predicate)
        let sortDescriptor = SortDescriptor(\HKQuantitySample.startDate)
        let descriptor = HKSampleQueryDescriptor(predicates: [samplePredicate], sortDescriptors: [sortDescriptor])
        let results = try await descriptor.result(for: healthStore)
        let mostRecents = results.map {
            ($0.startDate, $0.quantity.doubleValue(for: .gramUnit(with: .kilo)))
        }
        self.currentBodyMass = String(format: "%.1f Kg", mostRecents.last?.1 ?? .zero)
        self.yearlyBodyMassList = mostRecents
    }
}
