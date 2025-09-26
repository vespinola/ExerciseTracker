//
//  ChartDetailViewModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-02.
//

import SwiftUI
import HealthKit
import Observation

@MainActor @Observable
final class ChartDetailViewModel {
    var primaryData: String = DefaultMessages.noData
    var details: [MetricDetailModel] = []
    var xAxisStyle: XAxisType {
        didSet {
            scheduleFetch(for: xAxisStyle)
        }
    }

    let title: String
    let dataOption: HealthDataOptions
    
    private let calendar = Calendar.current
    private let healthKitManager: HealthKitManaging

    @ObservationIgnored
    private var fetchTask: Task<Void, Never>?
    
    init(
        model: ChartDetailModel,
        healthKitManager: HealthKitManaging
    ) {
        self.title = model.title
        self.xAxisStyle = model.xAxisStyle
        self.dataOption = model.dataOption
        self.healthKitManager = healthKitManager
    }
    
    private func scheduleFetch(for style: XAxisType) {
        // Cancel any in-flight fetch
        fetchTask?.cancel()

        // Start a new task for the requested style
        fetchTask = Task { [weak self] in
            guard let self else { return }

            let startDate = style.startDate ?? .now
            let endDate = style.endDate ?? .now

            let result = try? await self.healthKitManager.fetchHourlyCumulativeSum(
                for: self.dataOption.quantityType,
                unit: self.dataOption.unit,
                formatter: { self.dataOption.formatted(value: $0) },
                startDate: startDate,
                endDate: endDate,
                intervalComponents: style.intervalComponents
            )

            // Ensure this task is still relevant and not cancelled
            guard !Task.isCancelled, style == self.xAxisStyle, let result else { return }

            self.primaryData = result.total
            self.details = result.details
        }
    }
    
    func fetchDataPerInterval() async throws {
        scheduleFetch(for: xAxisStyle)
    }
}

extension ChartDetailViewModel {
    /// Proxy to the current X axis bucket unit for concise usage in views
    var bucketUnit: Calendar.Component { xAxisStyle.bucketUnit }

    /// Proxy that snaps a date to the beginning of the bucket for the current X axis style
    func bucketStart(for date: Date) -> Date {
        xAxisStyle.bucketStart(for: date, calendar: calendar)
    }
}
