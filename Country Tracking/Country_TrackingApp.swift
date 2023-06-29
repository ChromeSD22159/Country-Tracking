//
//  Country_TrackingApp.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 24.06.23.
//

import SwiftUI
import Foundation
import WidgetKit

@main
struct Country_TrackingApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    @StateObject var appStoregeManager = AppStorageManager()
    @StateObject var themeManager = ThemeManager()
    @State var theme: Themes = .default
    @StateObject var calendar:CalendarViewModel = CalendarViewModel()
    var body: some Scene {
        
        WindowGroup {
            ContentView(theme: theme)
            //ContentEntry(theme: theme)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appStoregeManager)
                .environmentObject(themeManager)
                .environmentObject(calendar)
                .onAppear {
                    getPermissons()
                    theme = themeManager.currentTheme()
                }
                .onChange(of: appStoregeManager.currentTheme, perform: { newTheme in
                    theme = themeManager.currentTheme()
                })
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        print("ScenePhase Active")
                        WidgetCenter.shared.reloadAllTimelines()
                    } else if newPhase == .inactive {
                        print("ScenePhase Inactive")
                        WidgetCenter.shared.reloadAllTimelines()
                    } else if newPhase == .background {
                        print("ScenePhase Background")
                    }
                }
        }
    }
}

extension Country_TrackingApp {
    func getPermissons() {
        self.requestPushNotificationAuthorization()
    }
    
    func requestPushNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                // Handle the error here.
            }
            
            // Enable or disable features based on the authorization.
        }
    }
}
