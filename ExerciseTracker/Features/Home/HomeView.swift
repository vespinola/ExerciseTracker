//
//  HomeView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-15.
//

import SwiftUI
import HealthKitUI

struct HomeView: View {
    @State var trigger = false
    @State private var timer = Timer
        .publish(every: 60, on: .main, in: .common)
        .autoconnect()
    @ObservedObject var viewModel: HomeViewModel = .init()
    @Environment(\.scenePhase) var scenePhase

    private var stepsPerHour: [MetricDetailModel] {
        viewModel.hourlyStepCounts.map {
            .init(date: $0.0, value: $0.1)
        }
    }

    private var distancePerHour: [MetricDetailModel] {
        viewModel.hourlyDistance.map {
            .init(date: $0.0, value: $0.1)
        }
    }
    private var bodyMassPerMonth: [MetricDetailModel] {
        viewModel.yearlyBodyMassList.map {
            .init(date: $0.0, value: $0.1)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVStack(spacing: 16) {
                    HeaderView(model: .init(title: "Summary", image: "person.crop.circle"))
                        .padding(.top)
                    HStack(spacing: 16) {
                        BarChartCardView(model: .init(
                            title: "Step Count",
                            date: "Today",
                            primaryData: viewModel.todayStepsCount,
                            yAxisLabel: "steps",
                            xAxisStyle: .hour,
                            data: stepsPerHour
                        ))
                        BarChartCardView(model: .init(
                            title: "Step Distance",
                            date: "Today",
                            primaryData: viewModel.todayDistance,
                            yAxisLabel: "distance",
                            xAxisStyle: .hour,
                            data: distancePerHour
                        ))
                    }
                    PieChartCardView(
                        model: .init(
                            title: "Move",
                            subtitle: viewModel.todayBurnedCalories,
                            description: "Activity Ring",
                            progress: viewModel.todayBurnedCaloriesPercentage
                        )
                    )
                    LineChartCardView(model: .init(
                        title: "Body Mass",
                        date: "Last 3 Months(in weeks)",
                        primaryData: viewModel.currentBodyMass,
                        yAxisLabel: "kg",
                        xAxisStyle: .week,
                        data: bodyMassPerMonth
                    ))
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            if HKHealthStore.isHealthDataAvailable() {
                trigger.toggle()
            }
        }
        .onReceive(timer) { _ in
            getHealthData()
        }
        .onChange(of: scenePhase) {
            getHealthData()
        }
        .healthDataAccessRequest(
            store: viewModel.healthStore,
            readTypes: viewModel.dataType,
            trigger: trigger
        ) { result in
            switch result {
                case .success(_):
                    Task {
                        await viewModel.fetchHealthData()
                    }
                case .failure(let error):
                    // do something
                    print(error.localizedDescription)
            }
        }
    }

    private func getHealthData() {
        guard scenePhase == .active else { return }
        Task {
            await viewModel.fetchHealthData()
        }
    }
}

#Preview {
    HomeView()
}

