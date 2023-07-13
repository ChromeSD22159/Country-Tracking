//
//  CalendarViewModel.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 26.06.23.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    // MARK: - Calendar States
    @Published var currentMonth:Int = 0
    @Published var currentDate: Date = Date()
    @Published var currentDates: [DateValue] = []
    
    @Published var selectedDate = Date()
    @Published var showPicker = false
    
    // MARK: - Formatte Date to "May 2023"
    func extractDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        let date = formatter.string(from: self.currentDate)
        return date.components(separatedBy: " ")
    }
    
    // MARK: - Get the Current Month by the Date
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        
        let firstDayOfMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth))
        
        if calendar.isDateInThisMonth(firstDayOfMonth!) {
            self.currentDate = Date()
            
            return Date()
        } else {
            self.currentDate = firstDayOfMonth!
            
            print(firstDayOfMonth!)
            return firstDayOfMonth!
        }
        
    }
    
    // MARK: - Extract the month
    func extractMonth() -> [DateValue] {
       
        let calendar = Calendar.current
        
        /// get current month
        let currentMonth = getCurrentMonth()
        
        /// get only the daynumber and save it as Model Array
        var days = currentMonth.getAllDatesdeomMonth().compactMap{ date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        /// Get the first day of the Month
        let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())

        if firstWeekDay == 1 {
            for _ in 1...6 {
                days.insert(DateValue(day: -1, date: Date()), at: 0)
            }
        } else {
            for _ in 1..<(firstWeekDay) - 1 {
                days.insert(DateValue(day: -1, date: Date()), at: 0)
            }
        }
        
        return days
    }
    
    // MARK: - Get the Current Month by the Date
    func getCurrentMonthByDate() -> Date {
        let calendar = Calendar.current
        
        let firstDayOfMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self.selectedDate))
        
        if calendar.isDateInThisMonth(firstDayOfMonth!) {
            self.currentDate = Date()
            
            return Date()
        } else {
            self.currentDate = firstDayOfMonth!
            return firstDayOfMonth!
        }
        
    }
    
    // MARK: - Extract the month
    func extractMonthByDate() -> [DateValue] {
       
        let calendar = Calendar.current
        
        /// get current month
        let currentMonth = getCurrentMonthByDate()
        
        /// get only the daynumber and save it as Model Array
        var days = currentMonth.getAllDatesdeomMonth().compactMap{ date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        /// Get the first day of the Month
        let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())

        if firstWeekDay == 1 {
            for _ in 1...6 {
                days.insert(DateValue(day: -1, date: Date()), at: 0)
            }
        } else {
            for _ in 1..<(firstWeekDay) - 1 {
                days.insert(DateValue(day: -1, date: Date()), at: 0)
            }
        }
        
        return days
    }
    
    // MARK: - check if two dates are the same day
    func isSameDay(d1: Date, d2: Date) -> Bool {
       return Calendar.current.isDate(d1, inSameDayAs: d2)
    }
    
}


struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}


