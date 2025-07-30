//
//  BarChartCardView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-20.
//

import SwiftUI
import Charts

struct BarChartCardView: View {
    let model: ChartModel

    let baseDate = Calendar.current.startOfDay(for: Date())
    let tickHours = [0, 6, 12, 18, 24]
    var tickDates: [Date] {
        tickHours.compactMap { Calendar.current.date(byAdding: .hour, value: $0, to: baseDate) }
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
                        print("hoho")
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
                Chart(model.data) {
                    BarMark(
                        x: .value("Time", $0.date),
                        y: .value("Steps", $0.value),
                        width: 3.0
                    )
                }
                .chartYAxis(.hidden)
                .chartXScale(domain: baseDate...Calendar.current.date(byAdding: .hour, value: 23, to: baseDate)!)
                .chartXAxis {
                    AxisMarks(values: tickDates) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
                .clipped()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

#Preview {
  BarChartCardView(model: .init(
    title: "Steps count",
    date: "Today",
    primaryData: "7,334",
    data: MetricDetailModel.mock
  ))
}

extension MetricDetailModel {
    static var mock: [MetricDetailModel] {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        return (0..<24).compactMap { hour in
            guard let date = calendar.date(byAdding: .hour, value: hour, to: baseDate) else { return nil }
            return MetricDetailModel(date: date, value: Double.random(in: 0..<1000))
        }
    }
}

