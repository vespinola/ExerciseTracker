//
//  HomeViewModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-23.
//

import SwiftUI
import HealthKit

@MainActor @Observable
class HomeViewModel {
    private let calendar = Calendar.current

    var todayStepsCount: String = DefaultMessages.noData
    var hourlyStepCounts: [MetricDetailModel] = []
    var todayDistance: String = DefaultMessages.noData
    var hourlyDistance: [MetricDetailModel] = []
    var todayBurnedCalories: String = DefaultMessages.noData
    var todayBurnedCaloriesPercentage: Double = 0
    var currentBodyMass: String = DefaultMessages.noData
    var yearlyBodyMassList: [MetricDetailModel] = []

    var showPermissionAlert = false

    private let healthKitManager: HealthKitManaging
    let onStepsCountTap: (ChartDetailModel) -> Void
    let onSettingsTap: () -> Void

    init(
        healthKitManager: HealthKitManaging,
        onStepsCountTap: @escaping (ChartDetailModel) -> Void,
        onSettingsTap: @escaping () -> Void
    ) {
        self.healthKitManager = healthKitManager
        self.onStepsCountTap = onStepsCountTap
        self.onSettingsTap = onSettingsTap
    }

    func requestAuthorization() async {
        let granted = await healthKitManager.requestHealthKitAuthorization()
        if granted {
            await fetchHealthData()
        } else {
            showPermissionAlert = true
        }
    }

    func fetchHealthData() async {
        async let steps: Void = fetchStepsPerHour()
        async let distance: Void = fetchDistancePerHour()
        async let move: Void = fetchMoveSummary()
        async let bodyMass: Void = fetchBodyMassData()
        _ = try? await (steps, distance, move, bodyMass)
    }

    private func fetchStepsPerHour() async throws {
        let startDate = calendar.startOfDay(for: .now)
        let result = try await healthKitManager.fetchHourlyCumulativeSum(
            for: HKQuantityType(.stepCount),
            unit: .count(),
            formatter: { "\(Int($0))" },
            startDate: startDate,
            endDate: .now,
            intervalComponents: XAxisType.hour.intervalComponents
        )
        self.todayStepsCount = result.total
        self.hourlyStepCounts = result.details
    }

    private func fetchDistancePerHour() async throws {
        let startDate = calendar.startOfDay(for: .now)
        let result = try await healthKitManager.fetchHourlyCumulativeSum(
            for: HKQuantityType(.distanceWalkingRunning),
            unit: .meter(),
            formatter: { String(format: "%.2f", $0 / 1000.0) + " км" },
            startDate: startDate,
            endDate: .now,
            intervalComponents: XAxisType.hour.intervalComponents
        )
        self.todayDistance = result.total
        self.hourlyDistance = result.details
    }

    private func fetchMoveSummary() async throws {
        let result = try await healthKitManager.fetchMoveSummary(startDate: .now, endDate: .now)
        self.todayBurnedCalories = "\(Int(result.burnedCalories))/\(Int(result.goalCalories))KCAL"
        self.todayBurnedCaloriesPercentage = (result.burnedCalories / result.goalCalories) * 100
    }

    func fetchBodyMassData() async throws {
        let startDate = calendar.date(byAdding: .month, value: -6, to: .now) ?? .now
        let endDate: Date = .now
        let result = try await healthKitManager.fetchBodyMassData(
            unit: .gramUnit(with: .kilo),
            formatter: { String(format: "%.1f Kg", $0) },
            startDate: startDate,
            endDate: endDate
        )
        self.currentBodyMass = result.total
        self.yearlyBodyMassList = result.details
    }
}
