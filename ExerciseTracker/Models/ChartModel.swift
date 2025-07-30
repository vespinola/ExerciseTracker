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
    var data: [MetricDetailModel] = []
}
