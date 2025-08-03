//
//  BarChartCardView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-20.
//

import SwiftUI
import Charts

struct BarChartCardView: View {
    private let model: ChartModel
    private let chartHelpers: ChartHelping
    private let onTap: () -> Void

    init(
        model: ChartModel,
        chartHelpers: ChartHelping = ChartHelpers(),
        onTap: @escaping () -> Void
    ) {
        self.model = model
        self.chartHelpers = chartHelpers
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap, label: {
            cardContent
        })
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
    }

    @ViewBuilder
    private var cardContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.white)
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Text(model.title)
                        .foregroundStyle(.black)
                    Spacer()
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.gray)
                }
                // Date
                Text(model.date)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.black)
                    .padding(.top, 4)

                // Primary metric
                Text(model.primaryData)
                    .font(.largeTitle)
                    .foregroundStyle(.blue)

                // Chart
                Chart(model.data) { element in
                    BarMark(
                        x: .value("Time", element.date),
                        y: .value(model.yAxisLabel, element.value),
                        width: 3.0
                    )
                }
                .chartYAxis(.hidden)
                .chartXScale(domain: chartHelpers.xAxisDomain(model.xAxisStyle))
                .chartXAxis {
                    AxisMarks(values: chartHelpers.xAxisTicks(model.xAxisStyle)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: chartHelpers.xAxisDateFormat(model.xAxisStyle))
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
                .clipped()
            }
            .padding()
        }
    }
}

#Preview {
    VStack {
        BarChartCardView(model: .init(
            title: "Steps Count",
            date: "Today",
            primaryData: "7,334",
            yAxisLabel: "steps",
            xAxisStyle: .hour,
            data: .mock
        ), onTap: {})

        BarChartCardView(model: .init(
            title: "Calories Burned",
            date: "This Week",
            primaryData: "2,500 kcal",
            yAxisLabel: "kcal",
            xAxisStyle: .day,
            data: .mock
        ), onTap: {})
    }
}
