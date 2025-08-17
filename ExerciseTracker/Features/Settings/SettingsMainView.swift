//
//  SettingsMainView.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-16.
//

import SwiftUI

struct SettingsMainView: View {
    @EnvironmentObject var coordinator: Coordinator

    var body: some View {
        Form {
            Section {
                Button("Add a new entry") {
                    coordinator.present(sheet: .addWeight)
                }
            } header: {
                Text("Manage your weight")
            }

        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsMainView()
}
