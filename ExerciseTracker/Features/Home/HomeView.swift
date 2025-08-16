//
//  HomeView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-15.
//

import SwiftUI
import HealthKitUI

struct HomeView: View {
    @State private var timer: Timer?
    @StateObject private var viewModel: HomeViewModel
    @Environment(\.scenePhase) var scenePhase

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVStack(spacing: 16) {
                    HeaderView(model: .init(title: "Summary", image: "figure.walk.circle.fill", action: viewModel.onAddWeidhtTap))
                        .padding(.top)
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
                        xAxisStyle: XAxisType.week,
                        data: viewModel.yearlyBodyMassList
                    ))
                    HStack(spacing: 16) {
                        BarChartCardView(model: .init(
                            title: "Step Count",
                            date: "Today",
                            primaryData: viewModel.todayStepsCount,
                            yAxisLabel: "steps",
                            xAxisStyle: XAxisType.hour,
                            data: viewModel.hourlyStepCounts
                        ), onTap: {
                            viewModel.onStepsCountTap(
                                .init(title: "Step Count", dataOption: .stepCount)
                            )
                        })
                        BarChartCardView(model: .init(
                            title: "Step Distance",
                            date: "Today",
                            primaryData: viewModel.todayDistance,
                            yAxisLabel: "distance",
                            xAxisStyle: XAxisType.hour,
                            data: viewModel.hourlyDistance
                        ), onTap: {
                            viewModel.onStepsCountTap(
                                .init(title: "Step Distance", dataOption: .stepDistance)
                            )
                        })
                    }
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: scenePhase) {
            getHealthData()
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: TimerConfiguration.waitTime, repeats: true) { _ in
                getHealthData()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .alert("Permissions Denied", isPresented: $viewModel.showPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Health Sharing") {
                // Deeplink is not official, but it's working fine for now
                if let url = URL(string: "x-apple-health://sharingOverview") {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please select ExerciseTracker and enable Health permissions.")
        }
        .task {
            await viewModel.requestAuthorization()
        }
    }

    private func getHealthData() {
        guard scenePhase == .active else { return }
        Task { await viewModel.fetchHealthData() }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            healthKitManager: MockHealthKitManager(),
            onStepsCountTap: { _ in },
            onAddWeidhtTap: {}
        )
    )
}

