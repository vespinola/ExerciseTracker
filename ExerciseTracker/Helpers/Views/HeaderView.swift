//
//  HeaderView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-15.
//

import SwiftUI

struct HeaderModel {
    let title: String
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
        }
    }
}

#Preview {
    HeaderView(model: .init(title: "Summary"))
}

