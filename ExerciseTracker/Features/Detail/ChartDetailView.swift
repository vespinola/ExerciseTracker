//
//  ChartDetailView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-02.
//

import SwiftUI

struct ChartDetailView: View {
    @StateObject var viewModel: ChartDetailViewModel
    @State private var selectedRange: String = "Day"

    var body: some View {
        VStack {
            Text(viewModel.model.title)
                .font(.largeTitle)
            Picker("Choose a range", selection: $selectedRange) {
                Text("D").tag("Day")
                Text("W").tag("Week")
                Text("M").tag("Month")
                Text("Y").tag("Year")
            }
            .pickerStyle(.segmented)
            BarChartCardView(model: .init(
                title: "Step Count",
                date: "Today",
                primaryData: viewModel.todayStepsCount,
                yAxisLabel: "steps",
                xAxisStyle: .hour,
                data: MetricDetailModel.map(values: viewModel.hourlyStepCounts)
            ), onTap: { })
            Spacer()
        }
        .task {
            try? await viewModel.fetchStepsPerHour()
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
