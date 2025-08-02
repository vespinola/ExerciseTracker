//
//  HomeView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-15.
//

import SwiftUI
import HealthKitUI

struct HomeView: View {
    @State private var showPermissionAlert = false
    @State private var timer = Timer
        .publish(every: 60, on: .main, in: .common)
        .autoconnect()
    @StateObject var viewModel: HomeViewModel
    @Environment(\.scenePhase) var scenePhase

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
                    PieChartCardView(
                        model: .init(
                            title: "Move",
                            subtitle: viewModel.todayBurnedCalories,
                            description: "Activity Ring",
                            progress: viewModel.todayBurnedCaloriesPercentage
                        )
                    )
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
            Task {
                if await viewModel.requestAuthorization() {
                    getHealthData()
                } else {
                    showPermissionAlert.toggle()
                }
            }
        }
        .onReceive(timer) { _ in
            getHealthData()
        }
        .onChange(of: scenePhase) {
            getHealthData()
        }
        .alert("Permissions Denied", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Health Sharing") {
                if let url = URL(string: "x-apple-health://sharingOverview") {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please select ExerciseTracker and enable Health permissions.")
        }
    }

    private func getHealthData() {
        guard scenePhase == .active else { return }
        Task { await viewModel.fetchHealthData() }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(healthKitManager: MockHealthKitManager())
    )
}

