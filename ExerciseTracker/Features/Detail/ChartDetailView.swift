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
    @State private var selectedRange: String = "Day"
    private var model: ChartDetailModel {
        viewModel.model
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                HStack(spacing: .zero) {
                    Text("\(model.title): ")
                        .font(.largeTitle)
                    Text(viewModel.primaryData)
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                }
                .padding(.top, 4)
                Picker("Choose a range", selection: $selectedRange) {
                    Text("D").tag("Day")
                    Text("W").tag("Week")
                    Text("M").tag("Month")
                    Text("Y").tag("Year")
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
                try? await viewModel.fetchStepsPerHour()
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
                        y: .value("Value", element.value),
                        width: 3.0
                    )
                }
                .chartXScale(domain: viewModel.chartHelper.xAxisDomain(.hour))
                .chartXAxis {
                    AxisMarks(values: viewModel.chartHelper.xAxisTicks(.hour)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: viewModel.chartHelper.xAxisDateFormat(.hour))
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
            model: .init(title: "Step Counts"),
            healthKitManager: MockHealthKitManager())
    )
}
