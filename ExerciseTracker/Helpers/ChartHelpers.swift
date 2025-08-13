//
//  ChartHelpers.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-03.
//

import Foundation

protocol ChartHelping {
    func xAxisTicks(_ xAxisStyle: XAxisType) -> [Date]
    func xAxisDateFormat(_ xAxisStyle: XAxisType) -> Date.FormatStyle
    func xAxisDomain(_ xAxisStyle: XAxisType) -> ClosedRange<Date>
    func yAxisStride(for type: YAxisType) -> Double
}

struct ChartHelpers: ChartHelping {
    func xAxisTicks(_ xAxisStyle: XAxisType) -> [Date] {
        let calendar = Calendar.current
        let baseDate: Date = calendar.startOfDay(for: .now)
        switch xAxisStyle {
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

    func xAxisDateFormat(_ xAxisStyle: XAxisType) -> Date.FormatStyle {
        switch xAxisStyle {
            case .week:
                return .dateTime.week(.twoDigits)
            case .month:
                return .dateTime.month(.abbreviated)
            case .hour:
                return .dateTime.hour(.defaultDigits(amPM: .omitted))
            default: return .dateTime.day()
        }
    }

    func xAxisDomain(_ xAxisStyle: XAxisType) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        switch xAxisStyle {
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

    func yAxisStride(for type: YAxisType) -> Double {
        switch type {
            case .steps: return 1000
            case .kg: return 5
            case .bpm: return 10
            case .kcal: return 50
        }
    }
}
