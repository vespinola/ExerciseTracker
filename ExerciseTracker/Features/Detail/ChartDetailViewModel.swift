//
//  ChartDetailViewModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-02.
//

import SwiftUI
import HealthKit

struct ChartDetailModel: Hashable {
    let title: String
}

@MainActor
final class ChartDetailViewModel: ObservableObject {
    @Published var todayStepsCount: String = Constants.noData
    @Published var hourlyStepCounts: [(Date, Double)] = []
    
    let model: ChartDetailModel
    private let calendar = Calendar.current
    private var now: Date { .now }
    private let hourlyIntervalComponents = DateComponents(hour: 1)
    private let healthKitManager: HealthKitManaging

    init(model: ChartDetailModel, healthKitManager: HealthKitManaging) {
        self.model = model
        self.healthKitManager = healthKitManager
    }

    func fetchStepsPerHour() async throws {
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
}
