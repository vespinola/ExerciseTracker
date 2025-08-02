//
//  ChartModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-28.
//

import Foundation

enum XAxisStyle {
    case day
    case week
    case month
    case hour
}

struct ChartModel {
    let title: String
    let date: String
    let primaryData: String
    let yAxisLabel: String
    let xAxisStyle: XAxisStyle
    let data: [MetricDetailModel]
}
