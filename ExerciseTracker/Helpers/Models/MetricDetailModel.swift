//
//  HourlySteps.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-28.
//

import Foundation
import HealthKit

struct MetricDetailModel: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
    var sample: HKQuantitySample? = nil

    static func == (lhs: MetricDetailModel, rhs: MetricDetailModel) -> Bool {
        lhs.date == rhs.date && lhs.value == rhs.value
    }
}

extension [MetricDetailModel] {
    static let mock: [MetricDetailModel] = [
        .init(date: Date(), value: 20),
        .init(date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now, value: 30)
    ]

    var dynamicDomain: ClosedRange<Double> {
        guard let min = map(\.value).min(),
              let max = map(\.value).max() else {
            return 0...1
        }
        return (min * 0.9)...(max * 1.1)
    }
}
