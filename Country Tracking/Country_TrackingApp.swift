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
    
    @StateObject var iconNames = IconNames()
    
    @StateObject var themeManager = ThemeManager()
    
    @StateObject var calendar:CalendarViewModel = CalendarViewModel()

    @StateObject private var entitlementManager: EntitlementManager

    @StateObject private var purchaseManager: PurchaseManager
    
    init() {
        let entitlementManager = EntitlementManager()
        let purchaseManager = PurchaseManager(entitlementManager: entitlementManager)

        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._purchaseManager = StateObject(wrappedValue: purchaseManager)
    }
    
    @State var theme: Themes = .default
    
    var body: some Scene {
        
        WindowGroup {
            ContentView(theme: theme)
                .defaultAppStorage(UserDefaults(suiteName: "group.fk.countryTracking")!)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appStoregeManager)
                .environmentObject(themeManager)
                .environmentObject(calendar)
                .environmentObject(iconNames)
                .environmentObject(entitlementManager)
                .environmentObject(purchaseManager)
                .onAppear {
                    getPermissons()
                    theme = themeManager.currentTheme()
                    
                    
                    
                    print(appStoregeManager.hasPro)
                    
                    // Disable icloud when noPRo
                    if !appStoregeManager.hasPro {
                        try? persistenceController.container.viewContext.setQueryGenerationFrom(.current)
                        appStoregeManager.iCloudSync = false
                    }
                    
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
                .task {
                   await purchaseManager.updatePurchasedProducts()
                    
                    do {
                        try await purchaseManager.loadProducts()
                    } catch {
                        print(error.localizedDescription)
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
            
            if error != nil {
                // Handle the error here.
            }
            
            // Enable or disable features based on the authorization.
        }
    }
}
