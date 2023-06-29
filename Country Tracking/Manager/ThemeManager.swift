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
        
        @AppStorage("currentTheme") var currentTheme: String = "default"
        
        switch currentTheme {
            case "default" : return .default
            case "blue" : return .blue
            case "green" : return .green
        default:
            return .default
        }
        
    }

    
    func applyTheme(theme: Themes) {
        @AppStorage("currentTheme") var currentTheme: String = theme.themeName
    }
}

enum Themes: String {
    case `default` = "default"
    case  blue = "blue"
    case  green = "green"
    
    var themeName: String {
        switch self {
        case .default : return "default"
        case .blue : return "default"
        case .green : return "default"
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
                badgeColor: Color.red
            )
        case .blue : return
            Theme(
                backgroundColor: Color(red: 5/255, green: 84/255, blue: 140/255),
                BackgroundImage: "BG_DARK",
                headerBackgroundColor: .blue.opacity(0.5),
                headerText: Color.white,
                text: Color.white,
                textInverse: Color.white,
                accentColor: Color.orange,
                badgeColor: Color.red
            )
        case .green : return
            Theme(backgroundColor: Color(red: 50/255, green: 60/255, blue: 5/255),
                  BackgroundImage: "BG_DARK",
                  headerBackgroundColor: Color.green.opacity(0.5),
                  headerText: Color.white,
                  text: Color.white,
                  textInverse: Color.white,
                  accentColor: Color.yellow,
                  badgeColor: Color.red
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
}
