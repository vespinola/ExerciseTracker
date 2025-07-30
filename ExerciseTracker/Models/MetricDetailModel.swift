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
