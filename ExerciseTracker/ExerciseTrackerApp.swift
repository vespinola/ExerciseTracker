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
    
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var coordinator = Coordinator(
        healthKitManager: HealthKitManager()
    )
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(page: .home)
                    .navigationDestination(for: Page.self) { page in
                        coordinator.build(page: page)
                    }
            }
            .sheet(item: $coordinator.sheet) { sheet in
                coordinator.build(sheet: sheet)
            }
            .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
