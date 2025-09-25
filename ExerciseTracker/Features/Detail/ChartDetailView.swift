//
//  ChartDetailView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-02.
//

import SwiftUI
import Charts

struct ChartDetailView: View {
    @State var viewModel: ChartDetailViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Group {
                    Text("\(viewModel.title): ")
                        .foregroundStyle(.gray)
                    + Text(viewModel.primaryData)
                        .foregroundStyle(.blue)
                }
                .font(.largeTitle)
                .padding(.top, 4)
                Picker("Choose a range", selection: $viewModel.xAxisStyle) {
                    ForEach(XAxisType.supportedCases) {
                        Text($0.shortLabelForSegmentedPicker).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                GeometryReader { geometry in
                    chartView
                        .frame(height: geometry.size.height * 0.5)
                        .padding(.vertical)
                }
                Spacer()
            }
            .padding(.horizontal)
            .task {
                try? await viewModel.fetchDataPerInterval()
            }
        }
        .navigationTitle("Details")
    }

    @ViewBuilder
    private var chartView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
            VStack {
                Chart(viewModel.details) { element in
                    BarMark(
                        x: .value("Time", viewModel.bucketStart(for: element.date), unit: viewModel.bucketUnit),
                        y: .value("Value", element.value)
                    )
                }
                .animation(.smooth, value: viewModel.details)
                .chartYScale(
                    domain: viewModel.details.dynamicDomain,
                    range: .plotDimension(padding: 0)
                ) //TODO: Find a way to set chartYAxis
                .chartXScale(domain: viewModel.xAxisStyle.xAxisDomain, range: .plotDimension(padding: 0))
                .chartXAxis {
                    AxisMarks(values: viewModel.xAxisStyle.xAxisTicks) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: viewModel.xAxisStyle.xAxisDateFormat)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue)
                .padding()
            }
        }
    }

    private func unitFor(_ type: XAxisType) -> Calendar.Component {
        switch type {
            case .hour:  return .hour
            case .week, .month: return .day
            case .year:  return .month
        }
    }

    private func bucketStart(for date: Date) -> Date {
        let cal = Calendar.current
        switch viewModel.xAxisStyle {
            case .hour:
                return cal.dateInterval(of: .hour, for: date)?.start ?? date
            case .week, .month:
                return cal.startOfDay(for: date)
            case .year:
                return cal.dateInterval(of: .month, for: date)?.start ?? cal.startOfDay(for: date)
        }
    }
}

#Preview {
    ChartDetailView(
        viewModel: .init(
            model: .init(title: "Step Counts", dataOption: .stepCount),
            healthKitManager: MockHealthKitManager())
    )
}
