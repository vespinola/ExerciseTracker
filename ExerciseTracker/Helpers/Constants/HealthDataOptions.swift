//
//  HealthDataOptions.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-03.
//

import HealthKit

enum HealthDataOptions {
    case stepCount
    case stepDistance
//    case bodyMass
//    case activity

    var quantityType: HKQuantityType {
        switch self {
        case .stepCount:
            return HKQuantityType(.stepCount)
        case .stepDistance:
            return HKQuantityType(.distanceWalkingRunning)
        }
    }

    var unit: HKUnit {
        switch self {
        case .stepCount:
            return .count()
        case .stepDistance:
            return .meter()
        }
    }

    func formatted(value: Double) -> String {
        switch self {
        case .stepCount:
            return "\(Int(value))"
        case .stepDistance:
            return String(format: "%.2f", value / 1000.0) + " км"
        }
    }
}
