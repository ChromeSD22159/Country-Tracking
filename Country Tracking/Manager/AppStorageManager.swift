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
    
    @AppStorage("currentTheme") var currentTheme: String = "default"
    
    @AppStorage("AppName") var AppName = "AppName"
    
    @AppStorage("Debug") var Debug = false
}
