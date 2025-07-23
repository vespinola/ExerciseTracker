//
//  CircleChartCardView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-22.
//

import SwiftUI
import Charts

struct PieChartModel {
  let title: String
  let subtitle: String
  let description: String
  let progress: Double
}

struct PieChartCardView: View {
  let model: PieChartModel
  var body: some View {
    ZStack(alignment: .topLeading) {
      RoundedRectangle(cornerRadius: 25)
        .fill(.white)

      VStack(alignment: .leading) {
        Text(model.description)
          .font(.headline)
        HStack(spacing: 16) {
          ZStack {
            Circle()
              .stroke(Color(.darkGray), lineWidth: 40)

            Circle()
              .trim(from: 0, to: 0.16)
              .stroke(Color.red, style: StrokeStyle(lineWidth: 40, lineCap: .round))
              .rotationEffect(.degrees(-90))
//            GeometryReader { geo in
//              let radius = geo.size.width / 2
//              let angle = Angle(degrees: 360 * model.progress - 90)
//              let x = radius + radius + cos(angle.radians)
//              let y = radius + radius * sin(angle.radians)
//
//              Image(systemName: "arrow.right")
//                .symbolRenderingMode(.palette)
//                .foregroundColor(.white)
//                .position(x: x, y: y)
//                .font(.caption)
//                .bold()
//            }
          }
          .padding(20)

          VStack(alignment: .leading) {
            Text(model.title)
              .font(.headline)
              .bold()
            Text(model.subtitle)
              .font(.title2)
              .bold()
              .foregroundStyle(.red)
          }
        }
      }
      .padding()
    }
    .frame(height: 250)
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  PieChartCardView(
    model: .init(
      title: "Move",
      subtitle: "51/300KCAL",
      description: "Activity Ring",
      progress: 20
    )
  )
}
