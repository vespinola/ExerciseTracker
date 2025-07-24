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
  @ObservedObject var viewModel: HomeViewModel = .init()
  @Environment(\.scenePhase) var scenePhase

  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.gray.opacity(0.1))
      VStack {
        HeaderView(model: .init(title: "Summary", image: "person.crop.circle"))
          .padding(.vertical)
        HStack(spacing: 16) {
          ChartCardView(model: .init(
            title: "Step Count",
            date: "Today",
            steps: viewModel.todayStepsCount,
            data: HourlySteps.mock
          ))
          ChartCardView(model: .init(
            title: "Step Distance",
            date: "Today",
            steps: "1.04KM",
            foregroundColor: Color.red,
            data: HourlySteps.mock
          ))
        }
        PieChartCardView(
          model: .init(
              title: "Move",
              subtitle: "51/300KCAL",
              description: "Activity Ring",
              progress: 34
            )
        )
        Spacer()
      }
      .padding(.horizontal)
    }
    .onAppear {
      print("homeview appeared")
      if HKHealthStore.isHealthDataAvailable() {
        trigger.toggle()
      }
    }
    .onChange(of: scenePhase) {
      guard scenePhase == .active else { return }
      Task {
        try? await viewModel.fetchStepsCount()
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
            try? await viewModel.fetchStepsCount()
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
