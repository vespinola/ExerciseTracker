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
        .publish(every: 30, on: .main, in: .common)
        .autoconnect()
    @ObservedObject var viewModel: HomeViewModel = .init()
    @Environment(\.scenePhase) var scenePhase

    private var stepsPerHour: [HourlySteps] {
        viewModel.hourlyStepCounts.map {
            .init(hour: $0.0, count: $0.1)
        }
    }

    private var distancePerHour: [HourlySteps] {
        viewModel.hourlyDistance.map {
            .init(hour: $0.0, count: $0.1)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                HeaderView(model: .init(title: "Summary", image: "person.crop.circle"))
                    .padding(.top)
                HStack(spacing: 16) {
                    ChartCardView(model: .init(
                        title: "Step Count",
                        date: "Today",
                        steps: viewModel.todayStepsCount,
                        data: stepsPerHour
                    ))
                    ChartCardView(model: .init(
                        title: "Step Distance",
                        date: "Today",
                        steps: viewModel.todayDistance,
                        foregroundColor: Color.red,
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
                Spacer()
            }
            .padding(.horizontal)
        }
        .onAppear {
            if HKHealthStore.isHealthDataAvailable() {
                trigger.toggle()
            }
        }
        .onReceive(timer) { _ in
            guard scenePhase == .active else { return }
            Task {
                try? await viewModel.fetchHealthData()
            }
        }
        .healthDataAccessRequest(
            store: viewModel.healthStore,
            readTypes: viewModel.dataType,
            trigger: trigger
        ) { result in
            switch result {
                case .success(_):
                    Task {
                        try? await viewModel.fetchHealthData()
                    }
                case .failure(let error):
                    // do something
                    print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    HomeView()
}

