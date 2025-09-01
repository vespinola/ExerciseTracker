//
//  HealthKitManager.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-01.
//

import HealthKit

struct HKQueryResponse {
    let total: String
    let details: [MetricDetailModel]

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

    func saveBodyMass(
        date: Date,
        bodyBass: Double
    )

    func deleteSample(sample: HKQuantitySample)
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

    private let writeDataTypes: Set<HKQuantityType> = [
        HKQuantityType(.bodyMass)
    ]

    init(healhStore: HKHealthStore = .init()) {
        self.healthStore = healhStore
    }

    func requestHealthKitAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        try? await healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes)
        var allPermissionsWereGranted = true
        writeDataTypes.forEach { currentDataType in
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
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
        let samplePredicate = HKSamplePredicate.quantitySample(type: quantityType, predicate: predicate)
        let queryDescriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: intervalComponents
        )
        let results = try await queryDescriptor.result(for: healthStore)
        var hourlyValues: [MetricDetailModel] = []
        results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
            let hour = statistics.startDate
            let value = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
            hourlyValues.append(.init(date: hour, value: value))
        }
        let total = hourlyValues.map(\.value).reduce(0, +)
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
            MetricDetailModel(date: $0.startDate, value: $0.quantity.doubleValue(for: unit), sample: $0)
        }
        return HKQueryResponse(total: formatter(mostRecents.last?.value ?? .zero), details: mostRecents)
    }

    func saveBodyMass(date: Date, bodyBass: Double) {
        let quantityType = HKQuantityType(.bodyMass)
        let sample = HKQuantitySample(
            type: quantityType,
            quantity: HKQuantity(
                unit: HKUnit.gramUnit(with: .kilo, ),
                doubleValue: bodyBass
            ),
            start: date,
            end: date
        )
        healthStore.save(sample) { (success, error) in
            if let error = error {
                print("Error saving weight: \(error.localizedDescription)")
            } else if success {
                print("Weight saved successfully!")
            }
        }
    }

    func deleteSample(sample: HKQuantitySample) {
        healthStore.delete(sample) { success, error in
            if let error = error {
                print("Error deleting sample: \(error)")
            } else if success {
                print("Sample deleted from HealthKit")
            }
        }
    }
}

struct MockHealthKitManager: HealthKitManaging {
    func saveBodyMass(date: Date, bodyBass: Double) { }

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
            MetricDetailModel(date: Calendar.current.date(byAdding: .hour, value: -offset, to: now)!, value: Double(offset * 10))
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
            MetricDetailModel(date: Date(), value: 70.5),
            MetricDetailModel(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, value: 70.2)
        ]
        return HKQueryResponse(total: formatter(70.5), details: values)
    }

    func deleteSample(sample: HKQuantitySample) { }
}
