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
    @Published var primaryData: String = DefaultMessages.noData
    @Published var details: [MetricDetailModel] = []
    @Published var xAxisStyle: XAxisType {
        didSet {
            Task {
                try? await fetchDataPerInterval()
            }
        }
    }

    let title: String
    let dataOption: HealthDataOptions
    let chartHelper: ChartHelping
    
    private let calendar = Calendar.current
    private let healthKitManager: HealthKitManaging
    
    init(
        model: ChartDetailModel,
        chartHelpers: ChartHelping = ChartHelpers(),
        healthKitManager: HealthKitManaging
    ) {
        self.title = model.title
        self.xAxisStyle = model.xAxisStyle
        self.dataOption = model.dataOption
        self.chartHelper = chartHelpers
        self.healthKitManager = healthKitManager
    }
    
    func fetchDataPerInterval() async throws {
        let startDate = xAxisStyle.startDate ?? .now
        let endDate = xAxisStyle.endDate ?? .now
        let result = try await healthKitManager.fetchHourlyCumulativeSum(
            for: dataOption.quantityType,
            unit: dataOption.unit,
            formatter: { dataOption.formatted(value: $0) }, //TODO: Check this part later
            startDate: startDate,
            endDate: endDate,
            intervalComponents: xAxisStyle.intervalComponents
        )
        self.primaryData = result.total
        self.details = MetricDetailModel.map(values: result.details)
    }
}
