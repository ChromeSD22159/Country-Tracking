//
//  ContentView.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 24.06.23.
//

import SwiftUI
import CoreData

struct ContentView: View {
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
    
    var body: some View {
        ZStack {
            
            currentTheme.backgroundColor.ignoresSafeArea()
            
            Image("BG_DARK")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                
                switch Tab {
                case .calendar: CalendarEntry(theme: theme)
                case .visitedMap: InteractiveMapView(theme: theme)
                case .settings: ZStack{}
                }
                
                Spacer()
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
                            Tab = .settings
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
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(theme: .blue)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppStorageManager())
            .environmentObject(ThemeManager())
            .environmentObject(CalendarViewModel())
    }
}


enum Tab {
    case calendar, visitedMap, settings
}
