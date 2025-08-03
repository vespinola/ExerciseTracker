//
//  XAxisType.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-03.
//

import Foundation

enum XAxisType: String, CaseIterable, Identifiable {
    case hour = "Hour"
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }

    var intervalComponents: DateComponents {
        switch self {
            case .hour:
                return DateComponents(hour: 1)
            case .day:
                return DateComponents(day: 1)
            case .week:
                return DateComponents(weekOfYear: 1)
            case .month:
                return DateComponents(month: 1)
            case .year:
                return DateComponents(year: 1)
        }
    }

    var shortLabel: String {
        switch self {
            case .hour: return "H"
            case .day: return "D"
            case .week: return "W"
            case .month: return "M"
            case .year: return "Y"
        }
    }

    /// Short label for the picker
    var shortLabelForSegmentedPicker: String {
        switch self {
            case .hour: return "D"
            case .day: return "D"
            case .week: return "W"
            case .month: return "M"
            case .year: return "Y"
        }
    }

    static var supportedCases: [XAxisType] {
        allCases.filter { $0 != .day }
    }
}
