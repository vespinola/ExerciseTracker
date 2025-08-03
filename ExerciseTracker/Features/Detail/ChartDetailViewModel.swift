//
//  ChartDetailViewModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-02.
//

import SwiftUI
import HealthKit

@MainActor
final class ChartDetailViewModel: ObservableObject {
    @Published var primaryData: String = Constants.noData
    @Published var details: [MetricDetailModel] = []

    let model: ChartDetailModel
    let chartHelper: ChartHelping

    private let calendar = Calendar.current
    private let healthKitManager: HealthKitManaging

    init(
        model: ChartDetailModel,
        chartHelpers: ChartHelping = ChartHelpers(),
        healthKitManager: HealthKitManaging
    ) {
        self.model = model
        self.chartHelper = chartHelpers
        self.healthKitManager = healthKitManager
    }

    func fetchStepsPerHour() async throws {
        let startDate = calendar.startOfDay(for: .now)
        let result = try await healthKitManager.fetchHourlyCumulativeSum(
            for: HKQuantityType(.stepCount),
            unit: .count(),
            formatter: { "\(Int($0))" },
            startDate: startDate,
            endDate: .now,
            intervalComponents: XAxisType.hour.intervalComponents
        )
        self.primaryData = result.total
        self.details = MetricDetailModel.map(values: result.details)
    }
}
