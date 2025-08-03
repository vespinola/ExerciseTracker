//
//  ChartModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-28.
//

import Foundation

struct ChartModel {
    let title: String
    let date: String
    let primaryData: String
    let yAxisLabel: String
    let xAxisStyle: XAxisStyle
    let data: [MetricDetailModel]
}

extension ChartModel {
    static let mock: ChartModel = .init(
        title: "Steps Count",
        date: "Today",
        primaryData: "7,334",
        yAxisLabel: "steps",
        xAxisStyle: .hour,
        data: .mock
    )
}
