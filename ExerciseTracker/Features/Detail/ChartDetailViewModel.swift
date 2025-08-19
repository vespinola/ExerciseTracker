//
//  ChartDetailViewModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-02.
//

import SwiftUI
import HealthKit

@MainActor @Observable
final class ChartDetailViewModel {
    var primaryData: String = DefaultMessages.noData
    var details: [MetricDetailModel] = []
    var xAxisStyle: XAxisType {
        didSet {
            Task {
                try? await fetchDataPerInterval()
            }
        }
    }

    let title: String
    let dataOption: HealthDataOptions
    
    private let calendar = Calendar.current
    private let healthKitManager: HealthKitManaging
    
    init(
        model: ChartDetailModel,
        healthKitManager: HealthKitManaging
    ) {
        self.title = model.title
        self.xAxisStyle = model.xAxisStyle
        self.dataOption = model.dataOption
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
        self.details = result.details
    }
}
