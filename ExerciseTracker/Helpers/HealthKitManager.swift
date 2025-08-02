//
//  HealthKitManager.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-01.
//

import HealthKit

struct HKQueryResponse {
    let total: String
    let details: [(Date, Double)]

    static let fallback: HKQueryResponse = .init(total: "0", details: [])
}

struct HKSummaryQueryResponse {
    let burnedCalories: Double
    let goalCalories: Double

    static let fallback: HKSummaryQueryResponse = .init(burnedCalories: 0, goalCalories: 0)
}

protocol HealthKitManaging {
    func requestHealthKitAuthorization() async -> Bool

    func fetchMoveSummary(
        startDate: Date,
        endDate: Date
    ) async throws -> HKSummaryQueryResponse

    func fetchHourlyCumulativeSum(
        for quantityType: HKQuantityType,
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date,
        intervalComponents: DateComponents
    ) async throws -> HKQueryResponse

    func fetchBodyMassData(
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date
    ) async throws -> HKQueryResponse
}

final class HealthKitManager: ObservableObject, HealthKitManaging {
    private let calendar = Calendar.current
    private let healthStore: HKHealthStore
    private var now: Date { .now }
    private let readDataTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.distanceWalkingRunning),
        HKObjectType.activitySummaryType(),
        HKQuantityType(.bodyMass)
    ]

    init(healhStore: HKHealthStore = .init()) {
        self.healthStore = healhStore
    }

    func requestHealthKitAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        try? await healthStore.requestAuthorization(toShare: .init(), read: readDataTypes)
        var allPermissionsWereGranted = true
        readDataTypes.forEach { currentDataType in
            let status = healthStore.authorizationStatus(for: currentDataType)
            let dataTypeAuthorized = status == .sharingAuthorized
            allPermissionsWereGranted = allPermissionsWereGranted && dataTypeAuthorized
        }
        return allPermissionsWereGranted
    }

    func fetchMoveSummary(
        startDate: Date,
        endDate: Date,
    ) async throws -> HKSummaryQueryResponse {
        var startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        startComponents.calendar = calendar
        var endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
        endComponents.calendar = calendar
        let predicate = HKQuery.predicate(forActivitySummariesBetweenStart: startComponents, end: endComponents)
        let descriptor = HKActivitySummaryQueryDescriptor(predicate: predicate)
        let summaries = try await descriptor.result(for: healthStore)
        guard let summary = summaries.first else { return .fallback }
        let burned = summary.activeEnergyBurned.doubleValue(for: .largeCalorie())
        let goal = summary.activeEnergyBurnedGoal.doubleValue(for: .largeCalorie())
        return HKSummaryQueryResponse(burnedCalories: burned, goalCalories: goal)
    }

    func fetchHourlyCumulativeSum(
        for quantityType: HKQuantityType,
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date,
        intervalComponents: DateComponents
    ) async throws -> HKQueryResponse {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: quantityType, predicate: predicate)
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
        return HKQueryResponse(total: formatter(Double(total)), details: hourlyValues)
    }

    func fetchBodyMassData(
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date
    ) async throws -> HKQueryResponse {
        let quantityType = HKQuantityType(.bodyMass)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: quantityType, predicate: predicate)
        let sortDescriptor = SortDescriptor(\HKQuantitySample.startDate)
        let descriptor = HKSampleQueryDescriptor(predicates: [samplePredicate], sortDescriptors: [sortDescriptor])
        let results = try await descriptor.result(for: healthStore)
        let mostRecents = results.map {
            ($0.startDate, $0.quantity.doubleValue(for: unit))
        }
        return HKQueryResponse(total: formatter(mostRecents.last?.1 ?? .zero), details: mostRecents)
    }
}

struct MockHealthKitManager: HealthKitManaging {
    func requestHealthKitAuthorization() async -> Bool {
        return true
    }
    
    func fetchMoveSummary(
        startDate: Date,
        endDate: Date
    ) async throws -> HKSummaryQueryResponse {
        return HKSummaryQueryResponse(burnedCalories: 450, goalCalories: 600)
    }

    func fetchHourlyCumulativeSum(
        for quantityType: HKQuantityType,
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date,
        intervalComponents: DateComponents
    ) async throws -> HKQueryResponse {
        let now = Date()
        let hours = (0..<24).map { offset in
            (Calendar.current.date(byAdding: .hour, value: -offset, to: now)!, Double(offset * 10))
        }
        return HKQueryResponse(total: "240", details: hours)
    }

    func fetchBodyMassData(
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date
    ) async throws -> HKQueryResponse {
        let values = [
            (Date(), 70.5),
            (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 70.2)
        ]
        return HKQueryResponse(total: formatter(70.5), details: values)
    }
}
