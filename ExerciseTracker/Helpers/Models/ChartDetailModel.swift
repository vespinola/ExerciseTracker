//
//  ChartDetailModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-03.
//


struct ChartDetailModel: Hashable {
    let title: String
    let xAxisStyle: XAxisType

    init(title: String, xAxisStyle: XAxisType = .hour) {
        self.title = title
        self.xAxisStyle = xAxisStyle
    }
}
