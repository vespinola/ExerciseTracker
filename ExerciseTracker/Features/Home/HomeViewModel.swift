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

    @Published var todayStepsCount: String = Constants.noData
    @Published var hourlyStepCounts: [(Date, Double)] = []
    @Published var todayDistance: String = Constants.noData
    @Published var hourlyDistance: [(Date, Double)] = []
    @Published var todayBurnedCalories: String = Constants.noData
    @Published var todayBurnedCaloriesPercentage: Double = 0
    @Published var currentBodyMass: String = Constants.noData
    @Published var yearlyBodyMassList: [(Date, Double)] = []

    private let healthKitManager: HealthKitManaging

    init(healthKitManager: HealthKitManaging) {
        self.healthKitManager = healthKitManager
    }

    func requestAuthorization() async -> Bool {
        await healthKitManager.requestHealthKitAuthorization()
    }

    func fetchHealthData() async {
        async let steps: Void = fetchStepsPerHour()
        async let distance: Void = fetchDistancePerHour()
        async let move: Void = fetchMoveSummary()
        async let bodyMass: Void = fetchBodyMassData()
        _ = try? await (steps, distance, move, bodyMass)
    }

    private func fetchStepsPerHour() async throws {
        let startDate = calendar.startOfDay(for: now)
        let result = try await healthKitManager.fetchHourlyCumulativeSum(
            for: HKQuantityType(.stepCount),
            unit: .count(),
            formatter: { "\(Int($0))" },
            startDate: startDate,
            endDate: now,
            intervalComponents: hourlyIntervalComponents
        )
        self.todayStepsCount = result.total
        self.hourlyStepCounts = result.details
    }

    private func fetchDistancePerHour() async throws {
        let startDate = calendar.startOfDay(for: now)
        let result = try await healthKitManager.fetchHourlyCumulativeSum(
            for: HKQuantityType(.distanceWalkingRunning),
            unit: .meter(),
            formatter: { String(format: "%.2f", $0 / 1000.0) + " км" },
            startDate: startDate,
            endDate: now,
            intervalComponents: hourlyIntervalComponents
        )
        self.todayDistance = result.total
        self.hourlyDistance = result.details
    }

    private func fetchMoveSummary() async throws {
        let result = try await healthKitManager.fetchMoveSummary(startDate: now, endDate: now)
        self.todayBurnedCalories = "\(Int(result.burnedCalories))/\(Int(result.goalCalories))KCAL"
        self.todayBurnedCaloriesPercentage = (result.burnedCalories / result.goalCalories) * 100
    }

    private func fetchBodyMassData() async throws {
        let startDate = calendar.date(byAdding: .month, value: -3, to: .now) ?? .now
        let endDate = now
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
