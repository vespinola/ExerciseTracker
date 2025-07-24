//
//  HomeViewModel.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-07-23.
//

import SwiftUI
import HealthKit

class HomeViewModel: ObservableObject {
  let healthStore: HKHealthStore = .init()
  let dataType: Set = [
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.walkingStepLength),
    HKQuantityType(.stepCount)
  ]

  @Published var todayStepsCount: String = "No data to display" //{
//    stepsCount.isEmpty ? "No data to display" : "\(stepsCount.last ?? 0)"
//  }

//  @Published var stepsCount: [Double] = []


  init() {}

  func fetchStepsCount() async throws {
    let interval = 1
    let startDate = Calendar.current.date(byAdding: .day, value: -interval, to: .now) ?? .now
    let type = HKQuantityType(.stepCount)
    let samplesDataRange = HKQuery.predicateForSamples(withStart: startDate, end: .now, options: .strictEndDate)
    let samples = HKSamplePredicate.quantitySample(type: type, predicate: samplesDataRange)
    let stepsQuery = HKStatisticsCollectionQueryDescriptor(
      predicate: samples,
      options: .mostRecent,
      anchorDate: .now,
      intervalComponents: DateComponents(day: interval)
    )
    let stepsData = try await stepsQuery.result(for: healthStore)

    stepsData.enumerateStatistics(from: startDate, to: .now) { statistics, pointer in
      let count = statistics.sumQuantity()?.doubleValue(for: .count())
      DispatchQueue.main.async {
        if let count, count > 0 {
          self.todayStepsCount = "\(count)"
        }
      }
    }
  }

}
