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
    let action: () -> Void
}

struct HeaderView: View {
    let model: HeaderModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.title2)
                    .bold()
                Text(.now, style: .date)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Button(action: model.action) {
                Image(systemName: model.image)
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.blue)
                    .frame(width: 30, height: 30)
            }
        }
    }
}

#Preview {
    HeaderView(model: .init(title: "Summary", image: "person.crop.circle", action: {}))
}

