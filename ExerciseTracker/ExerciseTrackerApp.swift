//
//  ExerciseTrackerApp.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-14.
//

import SwiftUI
import SwiftData

@main
struct ExerciseTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
