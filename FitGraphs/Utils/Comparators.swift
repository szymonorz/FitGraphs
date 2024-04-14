//
//  Comparators.swift
//  FitGraphs
//
//  Created by b on 13/04/2024.
//

import Foundation

class Comparators {
    static let weekDayNumbers = [
        "Sunday": 0,
        "Monday": 1,
        "Tuesday": 2,
        "Wednesday": 3,
        "Thursday": 4,
        "Friday": 5,
        "Saturday": 6,
    ]
    
    static let monthNumbers = [
        "January": 0,
        "February": 1,
        "March": 2,
        "April": 3,
        "May": 4,
        "June": 5,
        "July": 6,
        "August": 7,
        "September": 8,
        "October": 9,
        "November": 10,
        "December": 11,
    ]
    
    static func compareWeekdays(first: (String, [ChartItem._ChartContent]), second: (String, [ChartItem._ChartContent])) -> Bool {
        return (weekDayNumbers[first.0] ?? 7) < (weekDayNumbers[second.0] ?? 7);
    }
    
    static func compareWeekdays(first: ChartItem._ChartContent, second: ChartItem._ChartContent) -> Bool {
        return (weekDayNumbers[first.key] ?? 7) < (weekDayNumbers[second.key] ?? 7);
    }
    
    static func compareMonths(first: (String, [ChartItem._ChartContent]), second: (String, [ChartItem._ChartContent])) -> Bool {
        return (monthNumbers[first.0] ?? 12) < (monthNumbers[second.0] ?? 12);
    }
    
    static func compareMonths(first: ChartItem._ChartContent, second: ChartItem._ChartContent) -> Bool {
        return (monthNumbers[first.key] ?? 12) < (monthNumbers[second.key] ?? 12);
    }
    
    static func compareDates(first: (String, [ChartItem._ChartContent]), second: (String, [ChartItem._ChartContent])) -> Bool {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let d1 = dateFormatter.date(from: String(first.0.prefix(10)))!
        let d2 = dateFormatter.date(from: String(second.0.prefix(10)))!
        return d1.compare(d2) == .orderedAscending
    }
    
    static func compareDates(first: ChartItem._ChartContent, second: ChartItem._ChartContent) -> Bool {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let d1 = dateFormatter.date(from: String(first.key.prefix(10)))!
        let d2 = dateFormatter.date(from: String(second.key.prefix(10)))!
        return d1.compare(d2) == .orderedAscending
    }
    
    static func compareDates(first: String, second: String) -> Bool {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let d1 = dateFormatter.date(from: String(first.prefix(10)))!
        let d2 = dateFormatter.date(from: String(second.prefix(10)))!
        return d1.compare(d2) == .orderedAscending
    }
}
