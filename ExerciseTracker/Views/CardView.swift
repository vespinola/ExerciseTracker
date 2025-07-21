//
//  CardView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-15.
//

import SwiftUI

struct CardModel {
  var title: String
  var description: String
  var icon: String
  var action: Action
}

struct Action {
  var name: String
  var deeplink: String
}

struct CardView: View {
  var body: some View {

    VStack {
      HStack {
        Text("MENTAL WELLBEING")
          .font(.caption2)
          .bold()
        Spacer()
        CloseButton()
      }
      Divider()
        .padding(.vertical, 8)
      HStack(alignment: .top) {
        VStack() {
          Image(systemName: "apple.meditate.square.stack.fill")
            .resizable()
            .frame(width: 44, height: 44)
            .foregroundColor(.blue)
        }
        Spacer()
        VStack(alignment: .leading) {
          Text("Mental Health Questionnaire")
            .font(.headline)
            .padding(.bottom, 2)
          Text("Along with regular reflection, assessing your current risk for common conditions can be an important part of caring for your mental health.")
            .font(.caption)
          Button("Take Questionnaire", action: {
            print("hoho")
          })
          .buttonStyle(.bordered)
          .padding(.top, 16)
        }
        Spacer()
      }
    }
    .padding()
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .fill(Color.blue.opacity(0.1))
    )
    .padding(.horizontal)
  }
}

private struct CloseButton: View {
  var body: some View {
    Button(action: {
      print("hoho")
    }) {
      Image(systemName: "xmark.circle")
    }
  }
}

#Preview {
  CardView()
}

