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

    @Published var todayStepsCount: String = DefaultMessages.noData
    @Published var hourlyStepCounts: [MetricDetailModel] = []
    @Published var todayDistance: String = DefaultMessages.noData
    @Published var hourlyDistance: [MetricDetailModel] = []
    @Published var todayBurnedCalories: String = DefaultMessages.noData
    @Published var todayBurnedCaloriesPercentage: Double = 0
    @Published var currentBodyMass: String = DefaultMessages.noData
    @Published var yearlyBodyMassList: [MetricDetailModel] = []

    @Published var showPermissionAlert = false

    private let healthKitManager: HealthKitManaging
    let onStepsCountTap: (ChartDetailModel) -> Void

    init(healthKitManager: HealthKitManaging, onStepsCountTap: @escaping (ChartDetailModel) -> Void) {
        self.healthKitManager = healthKitManager
        self.onStepsCountTap = onStepsCountTap
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
        self.hourlyStepCounts = MetricDetailModel.map(values: result.details)
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
        self.hourlyDistance = MetricDetailModel.map(values: result.details)
    }

    private func fetchMoveSummary() async throws {
        let result = try await healthKitManager.fetchMoveSummary(startDate: .now, endDate: .now)
        self.todayBurnedCalories = "\(Int(result.burnedCalories))/\(Int(result.goalCalories))KCAL"
        self.todayBurnedCaloriesPercentage = (result.burnedCalories / result.goalCalories) * 100
    }

    private func fetchBodyMassData() async throws {
        let startDate = calendar.date(byAdding: .month, value: -3, to: .now) ?? .now
        let endDate: Date = .now
        let result = try await healthKitManager.fetchBodyMassData(
            unit: .gramUnit(with: .kilo),
            formatter: { String(format: "%.1f Kg", $0) },
            startDate: startDate,
            endDate: endDate
        )
        self.currentBodyMass = result.total
        self.yearlyBodyMassList = MetricDetailModel.map(values: result.details)
    }
}
