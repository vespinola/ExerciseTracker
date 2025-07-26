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
    private let calendar = Calendar.current
    private var now: Date { .now }
    private let hourlyIntervalComponents = DateComponents(hour: 1)
    let healthStore: HKHealthStore = .init()

    let dataType: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.distanceWalkingRunning),
        HKObjectType.activitySummaryType()
    ]

    @Published var todayStepsCount: String = "No Data"
    @Published var hourlyStepCounts: [(Date, Int)] = []
    @Published var todayDistance: String = "No Data"
    @Published var hourlyDistance: [(Date, Int)] = []
    @Published var todayBurnedCalories: String = "No Data"
    @Published var todayBurnedCaloriesPercentage: Double = 0

    init() {}

    func fetchHealthData() async throws {
        try await fetchStepsPerHour()
        try await fetchDistancePerHour()
        try await fetchMoveSummary()
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
    ) async throws -> (total: String, hourly: [(Date, Int)]) {
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
        var hourlyValues: [(Date, Int)] = []
        results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let hour = statistics.startDate
            let value = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
            hourlyValues.append((hour, Int(value)))
        }
        let total = hourlyValues.map(\.1).reduce(0, +)
        return (formatter(Double(total)), hourlyValues)
    }
}
