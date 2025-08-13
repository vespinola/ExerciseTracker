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

    var xAxisTicks: [Date] {
        let calendar = Calendar.current
        let baseDate: Date = calendar.startOfDay(for: .now)
        switch self {
            case .hour:
                // Show each 3 hours within the last 24 hours
                return stride(from: 0, through: 24, by: 6).compactMap {
                    calendar.date(byAdding: .hour, value: $0, to: baseDate)
                }
            case .week:
                // Show every week within the last 52 weeks (≈ 12 months)
                return stride(from: 0, through: 52, by: 4).compactMap {
                    calendar.date(byAdding: .weekOfYear, value: $0, to: baseDate)
                }
            case .month:
                // Show each month within the last 12 months
                return stride(from: 0, through: 12, by: 1).compactMap {
                    calendar.date(byAdding: .month, value: $0, to: baseDate)
                }
            default: return []
        }
    }

    var xAxisDateFormat: Date.FormatStyle {
        switch self {
            case .week:
                return .dateTime.week(.twoDigits)
            case .month:
                return .dateTime.month(.abbreviated)
            case .hour:
                return .dateTime.hour(.defaultDigits(amPM: .omitted))
            default: return .dateTime.day()
        }
    }

    var xAxisDomain: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        switch self {
            case .hour:
                let start = startOfToday
                let end = calendar.date(byAdding: .hour, value: 23, to: start) ?? now
                return start...end
            case .week:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? startOfToday
                let startOfNextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? now
                let end = calendar.date(byAdding: .second, value: -1, to: startOfNextWeek) ?? startOfNextWeek
                return startOfWeek...end
            case .month:
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? startOfToday
                let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? now
                let end = calendar.date(byAdding: .second, value: -1, to: startOfNextMonth) ?? startOfNextMonth
                return startOfMonth...end
            case .year:
                let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? startOfToday
                let startOfNextYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? now
                let end = calendar.date(byAdding: .second, value: -1, to: startOfNextYear) ?? startOfNextYear
                return startOfYear...end
        }
    }
}
