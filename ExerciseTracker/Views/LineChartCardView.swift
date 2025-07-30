//
//  BarChartCardView 2.swift
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
        ZStack() {
            RoundedRectangle(cornerRadius: 25)
                .fill(.white)
            VStack(alignment: .leading) {
                HStack {
                    Text(model.title)
                    Spacer()
                    Button {
                        print("line chart tapped")
                    } label: {
                        Image(systemName: "arrow.right.circle")
                            .foregroundStyle(.gray)
                    }
                }
                Text(model.date)
                    .font(.caption)
                    .bold()
                    .padding(.top, 4)
                Text(model.primaryData)
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                Chart(model.data) { element in
                    LineMark(
                        x: .value("Time", element.date),
                        y: .value("KG", element.value)
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
                        y: .value("KG", element.value)
                    )
                    .annotation(
                        position: .automatic,
                        alignment: .bottom,
                        spacing: 10
                    ) {
                        if element == model.data.first || element == model.data.last {
                            Text("\(Int(element.value))")
                                .font(.caption2)
                                .foregroundStyle(Color.black)
                        }
                    }
                }
                .chartYScale(domain: 80...120)
                .chartYAxis {
                    AxisMarks(values: .stride(by: 10))
                }
                .chartXAxis {
                    AxisMarks {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(
                            format: .dateTime.week(.defaultDigits).week()
                        )
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
}

#Preview {
    LineChartCardView(model: .init(
        title: "Steps count",
        date: "Today",
        primaryData: "7,334",
        data: MetricDetailModel.mock
    ))
}
