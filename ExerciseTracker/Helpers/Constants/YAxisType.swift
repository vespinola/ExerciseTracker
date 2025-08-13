//
//  YAxisType.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-03.
//


enum YAxisType {
    case steps
    case kg
    case bpm
    case kcal
}

extension YAxisType {
    var yAxisStride: Double {
        switch self {
            case .steps: return 1000
            case .kg: return 5
            case .bpm: return 10
            case .kcal: return 50
        }
    }
}
