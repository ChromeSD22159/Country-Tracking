//
//  DateExtension.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 19.05.23.
//

import Foundation

public extension Date {
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
    
    func isSameDay(d1: Date, d2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(d1, inSameDayAs: d2)
    }
    
    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func startEndOfDay() -> (start: Date, end: Date) {
        let date = self
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        
        return (start: startTime, end: endTime)
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.year], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Get all Dates of the Month
    func getAllDatesdeomMonth() -> [Date] {
        let calendar = Calendar.current
        
        // getting the first date from Month
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self ))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        // getting date
        return range.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
    
    /// yyyy-MM-dd'T'HH:mm:ssZZZZZ
    /// date.date -> "dd.MM" - date.time -> String "HH:mm"
    /// return 24.05. 10:45
    func dateFormatte(date: String, time: String) -> (date:String, time:String) {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = date
        
        let formattedTime = DateFormatter()
        formattedTime.dateFormat = time
        return (date: formattedDate.string(from: self), time: formattedTime.string(from: self))
    }
    
    func convertDateToDayNames() -> String {
        
        let day = self.dateFormatte(date: "EEEE", time: "HH:mm").date
        
        switch day {
        case "Monday": return "Mo"
        case "Tuesday": return "Di"
        case "Wednesday": return "Mi"
        case "Thursday": return "Do"
        case "Friday": return "Fr"
        case "Saturday": return "Sa"
        case "Sunday": return "So"
        default:
            return ""
        }
    }
    
    func CountDown() -> (days: Int, hours: Int) {
        let calendar = Calendar.current
        
        let timeValue = calendar.dateComponents([.day, .hour], from: Date.now, to: self)
        
        return (days: timeValue.day!, hours: timeValue.hour!)
    }
}
