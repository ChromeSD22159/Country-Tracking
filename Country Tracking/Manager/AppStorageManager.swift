//
//  AppStorageManager.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 25.06.23.
//

import Foundation
import SwiftUI

class AppStorageManager: ObservableObject {
    
    // AppConfig
    @AppStorage("AppGroup") var AppGroup = "group.countryTracking"
    
    @AppStorage("currentTheme", store: UserDefaults(suiteName: "group.fk.countryTracking")) var currentTheme: String = "default"

    @AppStorage("hasPro", store: UserDefaults(suiteName: "group.fk.countryTracking")) var hasPro: Bool = false
    
    @AppStorage("AppName") var AppName = "AppName"
    
    @AppStorage("showWidgetSheet") var showWidgetSheet = true
    
    @AppStorage("shopSheet") var shopSheet = true
    
    @AppStorage("AppIconChange") var AppIconChange = true
    
    @AppStorage("iCLoadSync") var iCLoadSync = false
    
    @AppStorage("CountdownFreeCounter") var CountdownFreeCounter = 0
    @AppStorage("CountdownFreeMaxCounter") var CountdownFreeMaxCounter = 1
    
    @AppStorage("useThemeColorForWidgetBG", store: UserDefaults(suiteName: "group.fk.countryTracking")) var useThemeColorForWidgetBG = true
    @AppStorage("toggleWidgetSortable", store: UserDefaults(suiteName: "group.fk.countryTracking")) var toggleWidgetSortable = true
    @State var isSetting = false
}

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}
