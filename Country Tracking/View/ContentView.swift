//
//  ContentView.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 24.06.23.
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var iconSettings:IconNames
    @EnvironmentObject var appStorageManager: AppStorageManager
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }

    init(theme: Themes) {
        UITabBarItem.appearance().badgeColor = UIColor(theme.theme.badgeColor)   // << here !!e
        
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().barTintColor = UIColor(theme.theme.backgroundColor)
        UITabBar.appearance().backgroundColor = UIColor(theme.theme.backgroundColor)
        UITabBar.appearance().unselectedItemTintColor = UIColor(theme.theme.text.opacity(0.5)) // normal icon color
        
        let appeareance = UITabBarAppearance()
        appeareance.backgroundColor = UIColor(theme.theme.backgroundColor)
        self.theme = theme
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.region, ascending: true)],
        animation: .default)
    var countries: FetchedResults<Countries>
    
    @State var Tab: Tab = .calendar
    @State var isSettingsSheet = false
    
    var body: some View {
        ZStack {
            
            currentTheme.backgroundColor.ignoresSafeArea()
            
            Image("BG_TRANSPARENT")
                .resizable()
                .ignoresSafeArea()
            
            switch Tab {
            case .calendar: CalendarEntry(tab: $Tab, theme: theme).edgesIgnoringSafeArea(.bottom)
            case .visitedMap: VisitedCountries(tab: $Tab, theme: theme)
            case .map: VisitedCitys(tab: $Tab, theme: theme)
            case .countdown: CountdownEntry(theme: theme)
            case .settings: ZStack{}
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)){
                            Tab = .calendar
                        }
                    }, label: {
                        VStack(spacing: 5) {
                            Image(systemName: "calendar")
                                .font(.title2)
                            
                            Text("Visited\nCalendar")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                    })
                    .foregroundColor(Tab == .calendar ? .white : .white.opacity(0.7))
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)){
                            Tab = .visitedMap
                        }
                    }, label: {
                        VStack(spacing: 5) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.title2)
                            
                            Text("Visited\nCountries")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                    })
                    .foregroundColor(Tab == .visitedMap ? .white : .white.opacity(0.7))

                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)){
                            Tab = .map
                        }
                    }, label: {
                        VStack(spacing: 5) {
                            Image(systemName: "map")
                                .font(.title2)
                            
                            Text("Map\nVisited Places")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                    }) .foregroundColor(Tab == .map ? .white : .white.opacity(0.7))
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)){
                            //Tab = .settings
                            isSettingsSheet = true
                        }
                    }, label: {
                        VStack(spacing: 5) {
                            Image(systemName: "gear")
                                .font(.title2)
                            
                            Text("User\nSettings")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                    }) .foregroundColor(Tab == .settings ? .white : .white.opacity(0.7))
                    
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Material.ultraThinMaterial)
                .cornerRadius(50)
                .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $isSettingsSheet, content: {
            
            SettingsSheetBody(theme: theme, isSettingsSheet: $isSettingsSheet)
            
        })
        .fullScreenCover(isPresented: $appStorageManager.showWidgetSheet, content: {
            
            WidgetSheetBody(theme: theme, isWidgetSheet: $appStorageManager.showWidgetSheet)
            
        })
        .fullScreenCover(isPresented: $appStorageManager.shopSheet, content: {
            
            ShopSheet(theme: theme, shopSheet: $appStorageManager.shopSheet)
            
        })
        .onReceive([self.iconSettings.currentIndex].publisher.first()){ value in
            let i = self.iconSettings.iconNames.firstIndex(of: UIApplication.shared.alternateIconName) ?? 0
            if value != i{
                UIApplication.shared.setAlternateIconName(self.iconSettings.iconNames[value], completionHandler: {
                    error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Success!")
                    }
                })
            }
        }
        
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(theme: .blue)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppStorageManager())
            .environmentObject(ThemeManager())
            .environmentObject(CalendarViewModel())
            .environmentObject(IconNames())
            .environmentObject(EntitlementManager())
            .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
    }
}


enum Tab {
    case calendar, visitedMap, map, settings, countdown
}
