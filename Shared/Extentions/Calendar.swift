//
//  Calendar.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 26.06.23.
//

import Foundation

extension Calendar {
    private var currentDate: Date { return Date() }

    func isDateInThisWeek(_ date: Date) -> Bool {
      return isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
    }

    func isDateInThisMonth(_ date: Date) -> Bool {
      return isDate(date, equalTo: currentDate, toGranularity: .month)
    }
}
