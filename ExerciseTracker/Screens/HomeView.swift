//
//  HomeView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-15.
//

import SwiftUI

struct HomeView: View {
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
            steps: "5,000",
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
  }
}

#Preview {
  HomeView()
}
