//
//  String.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 29.06.23.
//

import SwiftUI


extension String {
    func removeFromSelection(_ selection: [String]) -> [String] {
        return selection.filter({ return $0 != self })
    }
    
    func countryFlag() -> String {
        return String(String.UnicodeScalarView(self.unicodeScalars.compactMap {
            UnicodeScalar(127397 + $0.value)
        }))
    }
    
    func countryName() -> String {
        return Locale.current.localizedString(forRegionCode: self) ?? ""
    }
    
    func getColor() -> Color {
        switch self {
            case "black":   return Color(red: 0/255, green: 0/255, blue: 0/255)
            case "orange":  return Color(red: 215/255, green: 35/255, blue: 0/255)
            case "blue":    return Color(red: 5/255, green: 85/255, blue: 140/255)
            case "green":   return Color(red: 50/255, green: 60/255, blue: 5/255)
        default:
            return .black
        }
    }
}
