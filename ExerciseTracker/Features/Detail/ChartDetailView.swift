//
//  ChartDetailView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-02.
//

import SwiftUI
import Charts

struct ChartDetailView: View {
    @StateObject var viewModel: ChartDetailViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Group {
                    Text("\(viewModel.title): ")
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
    }

    @ViewBuilder
    private var chartView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
            VStack {
                Chart(viewModel.details) { element in
                    BarMark(
                        x: .value("Time", element.date),
                        y: .value("Value", element.value)
                        //TODO: Revisit width value per type
                    )
                }
                .animation(.smooth, value: viewModel.details)
                .chartYScale(domain: viewModel.details.dynamicDomain) //TODO: Find a way to set chartYAxis
                .chartXScale(domain: viewModel.xAxisStyle.xAxisDomain)
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
}

#Preview {
    ChartDetailView(
        viewModel: .init(
            model: .init(title: "Step Counts", dataOption: .stepCount),
            healthKitManager: MockHealthKitManager())
    )
}
