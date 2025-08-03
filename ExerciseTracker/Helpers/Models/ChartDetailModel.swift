//
//  ChartDetailModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-03.
//


struct ChartDetailModel: Hashable {
    let title: String
    let xAxisStyle: XAxisType
    let dataOption: HealthDataOptions

    init(
        title: String,
        dataOption: HealthDataOptions,
        xAxisStyle: XAxisType = .hour
    ) {
        self.title = title
        self.dataOption = dataOption
        self.xAxisStyle = xAxisStyle
    }
}
