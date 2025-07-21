//
//  HeaderView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-15.
//

import SwiftUI

struct HeaderView: View {
  var body: some View {
    HStack {
      Text("Summary")
        .font(.title2)
        .bold()
      Spacer()
      Circle()
        .foregroundStyle(.gray)
        .frame(width: 40)
    }
    .padding()
  }
}

#Preview {
  HeaderView()
}
