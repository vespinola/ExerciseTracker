//
//  ChartHelpers.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-03.
//

import Foundation

enum YAxisType {
    case steps
    case kg
    case bpm
    case kcal
}

enum XAxisStyle {
    case day
    case week
    case month
    case hour
}

protocol ChartHelping {
    func xAxisTicks(_ xAxisStyle: XAxisStyle) -> [Date]
    func xAxisDateFormat(_ xAxisStyle: XAxisStyle) -> Date.FormatStyle
    func xAxisDomain(_ xAxisStyle: XAxisStyle) -> ClosedRange<Date>
    func yAxisStride(for type: YAxisType) -> Double
}

struct ChartHelpers: ChartHelping {
    func xAxisTicks(_ xAxisStyle: XAxisStyle) -> [Date] {
        let calendar = Calendar.current
        let baseDate: Date = calendar.startOfDay(for: .now)
        switch xAxisStyle {
            case .hour:
                // Show each 3 hours within the last 24 hours
                return stride(from: 0, through: 24, by: 6).compactMap {
                    calendar.date(byAdding: .hour, value: $0, to: baseDate)
                }
            case .day:
                // Show every 5 days within the last 30 days
                return stride(from: 0, through: 30, by: 5).compactMap {
                    calendar.date(byAdding: .day, value: $0, to: baseDate)
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
        }
    }

    func xAxisDateFormat(_ xAxisStyle: XAxisStyle) -> Date.FormatStyle {
        switch xAxisStyle {
            case .day:
                return .dateTime.day(.twoDigits).month(.abbreviated)
            case .week:
                return .dateTime.week(.twoDigits)
            case .month:
                return .dateTime.month(.abbreviated)
            case .hour:
                return .dateTime.hour(.defaultDigits(amPM: .omitted))
        }
    }

    func xAxisDomain(_ xAxisStyle: XAxisStyle) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: .now)

        switch xAxisStyle {
            case .hour:
                let end = calendar.date(byAdding: .hour, value: 23, to: baseDate) ?? .now
                let start = baseDate
                return start...end

            case .day:
                let end = calendar.date(byAdding: .day, value: 30, to: baseDate) ?? .now
                let start = baseDate
                return start...end

            case .week:
                let end = calendar.date(byAdding: .weekOfYear, value: 52, to: baseDate) ?? .now
                let start = baseDate
                return start...end

            case .month:
                let end = calendar.date(byAdding: .month, value: 12, to: baseDate) ?? .now
                let start = baseDate
                return start...end
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
