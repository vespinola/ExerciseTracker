//
//  HeaderView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-15.
//

import SwiftUI

struct HeaderModel {
  let title: String
  let image: String
}

struct HeaderView: View {
  let model: HeaderModel

  var body: some View {
    HStack {
      Text(model.title)
        .font(.title2)
        .bold()
      Spacer()
      Image(systemName: model.image)
        .resizable()
        .scaledToFit()
        .symbolRenderingMode(.palette)
        .foregroundStyle(.blue)
        .frame(width: 30, height: 30)
    }
    .padding()
  }
}

#Preview {
  HeaderView(model: .init(title: "Summary", image: "person.crop.circle"))
}
