//
//  ThemeManager.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 25.06.23.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    static let SelectedThemeKey = "SelectedTheme"
    
    func currentTheme() -> Themes {
        @AppStorage("currentTheme", store: UserDefaults(suiteName: "group.fk.countryTracking")) var currentTheme: String = "blue"
        
        switch currentTheme {
        case "default" : return .default
        case "black" : return .black
        case "blue" : return .blue
        case "orange" : return .orange
        case "green" : return .green
            
        default:
            return .default
        }
        
    }

    func applyTheme(theme: Themes) {
        @AppStorage("currentTheme", store: UserDefaults(suiteName: "group.fk.countryTracking")) var currentTheme: String = theme.themeName
    }
}

enum Themes: String , CaseIterable {
    case `default` = "default"
    case  black = "black"
    case  blue = "blue"
    case  orange = "orange"
    case  green = "green"
    
    var themeName: String {
        switch self {
        case .default : return "Black"
        case .black : return "Black"
        case .blue : return "Blue"
        case .orange: return "Orange"
        case .green : return "Green"
        }
    }
    
    var theme: Theme {
        switch self {
        case .default : return
            Theme(
                backgroundColor: .black,
                BackgroundImage: "BG_DARK",
                headerBackgroundColor: .black.opacity(0.85),
                headerText: .white,
                text: .white,
                textInverse: .black,
                accentColor: Color.yellow,
                badgeColor: Color.gray,
                iconName: "AppLogoBlack",
                description: ""

            )
        case .black : return
            Theme(
                backgroundColor: Color(red: 0/255, green: 0/255, blue: 0/255),
                BackgroundImage: "BG_BLACK",
                headerBackgroundColor: .blue.opacity(0.5),
                headerText: Color.white,
                text: Color.white,
                textInverse: Color.white,
                accentColor: Color.orange,
                badgeColor: Color.gray,
                iconName: "AppLogoBlack",
                description: "black"
            )
        case .blue : return
            Theme(
                backgroundColor: Color(red: 5/255, green: 85/255, blue: 140/255),
                BackgroundImage: "BG_BLUE",
                headerBackgroundColor: .blue.opacity(0.5),
                headerText: Color.white,
                text: Color.white,
                textInverse: Color.white,
                accentColor: Color.orange,
                badgeColor: Color(red: 5/255, green: 84/255, blue: 140/255),
                iconName: "AppLogoBlau",
                description: "blue"
            )
        case .orange : return
            Theme(
                backgroundColor: Color(red: 215/255, green: 35/255, blue: 0/255),
                BackgroundImage: "BG_ORANGE",
                headerBackgroundColor: .blue.opacity(0.5),
                headerText: Color.white,
                text: Color.white,
                textInverse: Color.white,
                accentColor: Color.orange,
                badgeColor: Color(red: 215/255, green: 35/255, blue: 0/255),
                iconName: "AppLogoOrange",
                description: "orange"
            )
        case .green : return
            Theme(backgroundColor: Color(red: 50/255, green: 60/255, blue: 5/255),
                  BackgroundImage: "BG_GREEN",
                  headerBackgroundColor: Color.green.opacity(0.5),
                  headerText: Color.white,
                  text: Color.white,
                  textInverse: Color.white,
                  accentColor: Color.yellow,
                  badgeColor: Color(red: 50/255, green: 60/255, blue: 5/255),
                  iconName: "AppLogoGreen",
                  description: "green"
            )
        }
    }
}

struct Theme {
    let id = UUID()
    var backgroundColor: Color
    var BackgroundImage: String
    var headerBackgroundColor: Color
    var headerText: Color
    var text: Color
    var textInverse: Color
    var accentColor: Color
    var badgeColor: Color
    var iconName: String
    var description: String
    var preview: UIImage {
        UIImage(named: iconName) ?? UIImage()
    }
}
