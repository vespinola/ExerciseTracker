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
    let onTap: () -> Void

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
                .chartXScale(domain: xAxisDomain())
                .chartXAxis {
                    AxisMarks(values: xAxisTicks()) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: xAxisDateFormat())
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
                .clipped()
            }
            .padding()
        }
    }

    private func yAxisStride() -> Double {
        switch model.yAxisLabel.lowercased() {
            case "steps": return 1000
            case "kg": return 5
            case "bpm": return 10
            default: return 10
        }
    }

    private func xAxisTicks() -> [Date] {
        let calendar = Calendar.current
        let baseDate: Date = calendar.startOfDay(for: .now)
        switch model.xAxisStyle {
            case .hour:
                // Show each 3 hours within the last 24 hours
                return stride(from: 0, through: 24, by: 6).compactMap {
                    calendar.date(byAdding: .hour, value: $0, to: baseDate)
                }
            case .day:
                // Show every 5 days within the last 30 days
                return stride(from: 0, through: 30, by: 5).compactMap {
                    calendar.date(byAdding: .day, value: $0, to: baseDate)
                }

            case .week:
                // Show every week within the last 52 weeks (≈ 12 months)
                return stride(from: 0, through: 52, by: 4).compactMap {
                    calendar.date(byAdding: .weekOfYear, value: $0, to: baseDate)
                }

            case .month:
                // Show each month within the last 12 months
                return stride(from: 0, through: 12, by: 1).compactMap {
                    calendar.date(byAdding: .month, value: $0, to: baseDate)
                }
        }
    }

    private func xAxisDateFormat() -> Date.FormatStyle {
        switch model.xAxisStyle {
            case .day:
                return .dateTime.day(.twoDigits).month(.abbreviated)
            case .week:
                return .dateTime.week(.twoDigits)
            case .month:
                return .dateTime.month(.abbreviated)
            case .hour:
                return .dateTime.hour(.defaultDigits(amPM: .omitted))
        }
    }

    private func xAxisDomain() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: .now)

        switch model.xAxisStyle {
            case .hour:
                let end = calendar.date(byAdding: .hour, value: 23, to: baseDate) ?? .now
                let start = baseDate
                return start...end

            case .day:
                let end = calendar.date(byAdding: .day, value: 30, to: baseDate) ?? .now
                let start = baseDate
                return start...end

            case .week:
                let end = calendar.date(byAdding: .weekOfYear, value: 52, to: baseDate) ?? .now
                let start = baseDate
                return start...end

            case .month:
                let end = calendar.date(byAdding: .month, value: 12, to: baseDate) ?? .now
                let start = baseDate
                return start...end
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
