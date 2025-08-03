//
//  LineChartCardView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-28.
//

import SwiftUI
import Charts

struct LineChartCardView: View {
    private let model: ChartModel

    init(model: ChartModel) {
        self.model = model
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.white)

            VStack(alignment: .leading) {
                // Header
                HStack {
                    Text(model.title)
                    Spacer()
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.gray)
                }

                // Date
                Text(model.date)
                    .font(.caption)
                    .bold()
                    .padding(.top, 4)

                // Primary metric value
                Text(model.primaryData)
                    .font(.largeTitle)
                    .foregroundStyle(.blue)

                // Chart
                Chart(model.data) { element in
                    LineMark(
                        x: .value("Time", element.date),
                        y: .value(model.yAxisLabel, element.value)
                    )
                    .symbol {
                        Circle()
                            .fill(.red)
                            .frame(width: 6)
                            .shadow(radius: 1)
                    }
                    .interpolationMethod(.linear)

                    PointMark(
                        x: .value("Time", element.date),
                        y: .value(model.yAxisLabel, element.value)
                    )
                    .annotation(position: .automatic, alignment: .bottom, spacing: 10) {
                        if element == model.data.first || element == model.data.last {
                            Text("\(Int(element.value)) \(model.yAxisLabel)")
                                .font(.caption2)
                                .foregroundStyle(.black)
                        }
                    }
                }
                .chartYScale(domain: dynamicYDomain())
                .chartYAxis {
                    AxisMarks(values: .stride(by: 10))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 6)) {
                        AxisGridLine()
                        AxisTick()
                        // TODO: Define a best way to display x axis dates
                        // AxisValueLabel(format: xAxisDateFormat())
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
    }

    // Compute dynamic Y-axis domain
    private func dynamicYDomain() -> ClosedRange<Double> {
        guard let min = model.data.map(\.value).min(),
              let max = model.data.map(\.value).max() else {
            return 0...1
        }
        return (min * 0.9)...(max * 1.1)
    }
}

#Preview {
    VStack {
        LineChartCardView(model: .init(
            title: "Body Mass",
            date: "Today",
            primaryData: "94 kg",
            yAxisLabel: "kg",
            xAxisStyle: .week,
            data: .mock
        ))

        LineChartCardView(model: .init(
            title: "Steps Count",
            date: "This Week",
            primaryData: "12,340",
            yAxisLabel: "steps",
            xAxisStyle: .day,
            data: .mock
        ))

        LineChartCardView(model: .init(
            title: "Heart Rate",
            date: "Last Hour",
            primaryData: "72 bpm",
            yAxisLabel: "bpm",
            xAxisStyle: .hour,
            data: .mock
        ))
    }
}
