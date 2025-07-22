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
            steps: "5,500",
            foregroundColor: Color.red,
            data: HourlySteps.mock
          ))
        }
        .padding(.horizontal)
        Spacer()
      }
    }
  }
}

#Preview {
  HomeView()
}
