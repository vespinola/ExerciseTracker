//
//  HourlySteps.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-28.
//

import Foundation

struct MetricDetailModel: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double

    static func == (lhs: MetricDetailModel, rhs: MetricDetailModel) -> Bool {
        lhs.date == rhs.date && lhs.value == rhs.value
    }
}

extension [MetricDetailModel] {
    static let mock: [MetricDetailModel] = [
        .init(date: Date(), value: 20),
        .init(date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now, value: 30)
    ]
}
