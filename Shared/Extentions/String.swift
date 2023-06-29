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
}
