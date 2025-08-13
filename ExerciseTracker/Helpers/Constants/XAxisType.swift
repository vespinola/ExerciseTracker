//
//  XAxisType.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-03.
//

import Foundation

enum XAxisType: String, CaseIterable, Identifiable {
    case hour = "Hour"
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }

    // key point to define the buckets
    var intervalComponents: DateComponents {
        switch self {
            case .hour:
                return DateComponents(hour: 1)
            case .week:
                return DateComponents(day: 1)
            case .month:
                return DateComponents(day: 1)
            case .year:
                return DateComponents(month: 1)
        }
    }

    var shortLabel: String {
        switch self {
            case .hour: return "H"
            case .week: return "W"
            case .month: return "M"
            case .year: return "Y"
        }
    }

    /// Short label for the picker
    var shortLabelForSegmentedPicker: String {
        switch self {
            case .hour: return "D" // Fitness app uses Day for the first tab
            case .week: return "W"
            case .month: return "M"
            case .year: return "Y"
        }
    }

    static var supportedCases: [XAxisType] { allCases }
}

extension XAxisType {
    /// Returns the relevant start date for each XAxisType case.
    var startDate: Date? {
        let now = Date()
        switch self {
            case .hour:
                // Start of the current day
                return Calendar.current.startOfDay(for: now)
            case .week:
                // Start of current ISO week (Monday)
                var iso = Calendar(identifier: .iso8601)
                iso.timeZone = Calendar.current.timeZone
                let comps = iso.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
                return iso.date(from: comps)
            case .month:
                // Start of the current month
                return Calendar.current.dateInterval(of: .month, for: now)?.start
            case .year:
                // Start of the current year
                return Calendar.current.dateInterval(of: .year, for: now)?.start
        }
    }

    /// Returns the relevant end date for each XAxisType case, aligned to the next interval boundary.
    var endDate: Date? {
        let now = Date()
        switch self {
            case .hour:
                // End is start of tomorrow
                let startOfToday = Calendar.current.startOfDay(for: now)
                return Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)
            case .week:
                // End is start of next ISO week (Monday of next week)
                var iso = Calendar(identifier: .iso8601)
                iso.timeZone = Calendar.current.timeZone
                let comps = iso.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
                if let startOfWeek = iso.date(from: comps) {
                    return iso.date(byAdding: .day, value: 7, to: startOfWeek)
                }
                return nil
            case .month:
                // End is start of next month
                if let startOfMonth = Calendar.current.dateInterval(of: .month, for: now)?.start {
                    return Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)
                }
                return nil
            case .year:
                // End is start of next year
                if let startOfYear = Calendar.current.dateInterval(of: .year, for: now)?.start {
                    return Calendar.current.date(byAdding: .year, value: 1, to: startOfYear)
                }
                return nil
        }
    }
}
