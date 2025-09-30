//
//  HomeViewSnapshotTests.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-09-30.
//

import PreviewSnapshotsTesting
import Foundation
import Testing
@testable import ExerciseTracker

struct HomeViewSnapshotTests {
    
    @MainActor @Test(
        .tags(.snapshot)
    )
    func `home view basic state`() throws {
        ContentView_Previews.homeSnapshots.assertSnapshots()
    }
}
