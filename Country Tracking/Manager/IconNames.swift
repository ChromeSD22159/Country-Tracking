//
//  IconNames.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 30.06.23.
//

import Foundation
import SwiftUI

class IconNames: ObservableObject {
    var iconNames: [String?] = [nil]
    //exact index we're at inside our icon names
    @Published var currentIndex = 0
    
    init() {
        getAlternateIconNames()
        
        if let currentIcon = UIApplication.shared.alternateIconName{
            self.currentIndex = iconNames.firstIndex(of: currentIcon) ?? 0
        }
}
    
    func getAlternateIconNames(){
    //looking into our info.plist file to locate the specific Bundle with our icons
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
            let alternateIcons = icons["CFBundleAlternateIcons"] as? [String: Any] {
                     
                 for (_, value) in alternateIcons{
                    //Accessing the name of icon list inside the dictionary
                     guard let iconList = value as? Dictionary<String,Any> else{return}
                     //Accessing the name of icon files
                     guard let iconFiles = iconList["CFBundleIconFiles"] as? [String]
                         else{return}
                         //Accessing the name of the icon
                     guard let icon = iconFiles.first else{return}
                     iconNames.append(icon)
        
                 }
            }
    }
    
    
}


enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case darkMode = "AppIcon-Dark"

    var id: String { rawValue }
    var iconName: String? {
        switch self {
        case .primary:
            /// `nil` is used to reset the app icon back to its primary icon.
            return nil
        default:
            return rawValue
        }
    }

    var description: String {
        switch self {
        case .primary:
            return "Default"
        case .darkMode:
            return "Dark mode"
        }
    }

    var preview: UIImage {
        UIImage(named: rawValue + "-Preview") ?? UIImage()
    }
}
