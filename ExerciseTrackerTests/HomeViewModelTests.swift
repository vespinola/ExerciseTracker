//
//  ExerciseTrackerTests.swift
//  ExerciseTrackerTests
//
//  Created by Vladimir Espinola Lezcano on 2025-07-14.
//

import Testing
import Foundation
@testable import ExerciseTracker
import HealthKit

struct HomeViewModelTests {
    private static let isTestEnabled = true

    @MainActor
    @Test(
        .enabled(if: isTestEnabled),
        .tags(.ui)
    )
    func `home viewmodel basic functionality`() async throws {
        //Given
        let spyManager = SpyHealthKitManager()
        let viewModel = HomeViewModelFixture.getInstance(healthKitManger: spyManager)

        //When
        await viewModel.requestAuthorization()
        await viewModel.fetchHealthData()

        //Then
        #expect(spyManager.fetchHourlyCumulativeSumWasCalled)
        #expect(spyManager.fetchMoveSummaryWasCalled)
        #expect(spyManager.requestHealthKitAuthorizationWasCalled)
    }

}

extension Tag {
    @Tag static var ui: Self
}

struct HomeViewModelFixture {
    @MainActor static func getInstance(
        healthKitManger: SpyHealthKitManager
    ) -> HomeViewModel {
        return .init(
            healthKitManager: healthKitManger,
            onStepsCountTap: { _ in },
            onSettingsTap: { },
            onBodyMassTap: { }
        )
    }
}

final class SpyHealthKitManager: HealthKitManaging {
    private(set) var requestHealthKitAuthorizationWasCalled = false
    private(set) var fetchMoveSummaryWasCalled = false
    private(set) var fetchHourlyCumulativeSumWasCalled = false
    private(set) var fetchBodyMassDataWasCalled = false
    private(set) var saveBodyMassWasCalled = false
    private(set) var deleteSampleWasCalled = false

    func requestHealthKitAuthorization() async -> Bool {
        requestHealthKitAuthorizationWasCalled = true
        return true
    }

    func fetchMoveSummary(startDate: Date, endDate: Date) async throws -> ExerciseTracker.HKSummaryQueryResponse {
        fetchMoveSummaryWasCalled = true
        return .fallback
    }

    func fetchHourlyCumulativeSum(
        for quantityType: HKQuantityType,
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date,
        intervalComponents: DateComponents
    ) async throws -> ExerciseTracker.HKQueryResponse {
        fetchHourlyCumulativeSumWasCalled = true
        return .fallback
    }

    func fetchBodyMassData(
        unit: HKUnit,
        formatter: (Double) -> String,
        startDate: Date,
        endDate: Date
    ) async throws -> ExerciseTracker.HKQueryResponse {
        fetchBodyMassDataWasCalled = true
        return .fallback
    }

    func saveBodyMass(date: Date, bodyBass: Double) {
        saveBodyMassWasCalled = true
    }

    func deleteSample(sample: HKQuantitySample) {
        deleteSampleWasCalled = true
    }
}
