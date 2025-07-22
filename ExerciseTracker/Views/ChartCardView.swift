//
//  ChartCardView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-20.
//

import SwiftUI
import Charts

struct ChartCardModel {
  let title: String
  let date: String
  let steps: String
  var foregroundColor: Color = .blue
  var data: [HourlySteps] = []
}

struct HourlySteps: Identifiable {
  let id = UUID()
  let hour: Int
  let count: Int
}

struct ChartCardView: View {
  let model: ChartCardModel

  var body: some View {
    ZStack() {
      RoundedRectangle(cornerRadius: 25)
        .fill(.white)
      VStack(alignment: .leading) {
        HStack {
          Text(model.title)
          Spacer()
          Button {
            print("hoho")
          } label: {
            Image(systemName: "arrow.right.circle")
              .foregroundStyle(.gray)
          }
        }
        Text(model.date)
          .font(.caption)
          .bold()
          .padding(.top, 4)
        Text(model.steps)
          .font(.largeTitle)
          .foregroundStyle(model.foregroundColor)
        Chart(model.data) {
          BarMark(
            x: .value("Time", $0.hour), // TODO: FIX ME
            y: .value("Steps", $0.count),
            width: 3.0
          )
        }
        .chartYAxis(.hidden)
        .chartXAxis {
          // TODO: Double-check this
          AxisMarks(values: [0, 6, 12, 18, 24])
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(model.foregroundColor)
      }
      .padding()
    }
    .frame(maxWidth: .infinity) 
    .frame(height: 250)
  }
}

#Preview {
  ChartCardView(model: .init(
    title: "Steps count",
    date: "Today",
    steps: "7,334",
    data: HourlySteps.mock
  ))
}

extension HourlySteps {
  static var mock = Array(0...23).map {
    HourlySteps(hour: $0, count: Int.random(in: 500..<1000))
  }
}
