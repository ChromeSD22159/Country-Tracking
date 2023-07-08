//
//  VisitedCitys.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 30.06.23.
//

import SwiftUI
import MapKit
import CoreData

struct VisitedCitys: View {
    @EnvironmentObject var appStorage: AppStorageManager
    
    @Binding var tab: Tab
    
    var theme: Themes
    
    private var currentTheme: Theme {
        return self.theme.theme
    }
    
    @State private var showPlaces:[Places] = []
    @State private var townsToday:[Places] = []
    @State private var townsYesterday:[Places] = []
    @State private var townsAll:[Places] = []
    @State private var countries:[Places] = []
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.date, ascending: true)],
        predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Date())  as CVarArg),
        animation: .default)
    private var visitedTownsToday: FetchedResults<VisitedTown>
    
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.date, ascending: true)],
        predicate: NSPredicate(format: "date > %@ and date < %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())!.startEndOfDay().start as CVarArg, Calendar.current.date(byAdding: .day, value: -1, to: Date())!.startEndOfDay().end as CVarArg),
        animation: .default)
    private var visitedTownsYesterday: FetchedResults<VisitedTown>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.date, ascending: true)],
        animation: .default)
    private var visitedTownsAll: FetchedResults<VisitedTown>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.date, ascending: true)],
        predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Date())  as CVarArg),
        animation: .default)
    private var visitedCountrys: FetchedResults<Countries>
    
    @State private var coordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.539887, longitude: 9.983621),
        span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
    )
    
    @State var isSettingsSheet = false
    
    @State var mapSwitcher = "Visited Countrys Today"
    
    var body: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            VStack {
                ZStack {
                    MapView()
                    
                    switcher()
                    
                    Header()
                }
            }
            
        }
        .sheet(isPresented: $isSettingsSheet, content: {
            
            SettingsSheetBody(theme: theme, isSettingsSheet: $isSettingsSheet)
            
        })
        .onAppear{
           loadCitys()
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        VStack {
            HStack {
                HStack(spacing: 20) {
                    if appStorage.hasPro == false {
                        Button(action: { appStorage.shopSheet.toggle() }) {
                            Image(systemName: "trophy.fill")
                                .font(.title3)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)){
                            tab = .countdown
                        }
                    }) {
                        Image(systemName: "square.stack")
                            .font(.title3)
                    }
                }
                .font(.callout)
                .foregroundColor(currentTheme.headerText)
                
                Spacer()
                
                Text("Visited Cities")
                
                Spacer()
                
                HStack(spacing: 20) {
                    
                    Button(action: { isSettingsSheet.toggle() }) {
                        Image(systemName: "gear")
                            .font(.title3)
                    }
                   
                }
                .font(.callout)
                .foregroundColor(currentTheme.headerText)
            }
            .padding(.all)
            .background(Material.ultraThinMaterial)
            
            Spacer()
        } // Header
    }
    
    @ViewBuilder
    func switcher() -> some View {
        VStack {
            HStack {
                
                Spacer()
                
                Picker("Theme", selection: $mapSwitcher) {
                    ForEach(["Visited Cities Today", "Visited Cities Yesterday", "all Visited Cities"], id: \.self) { theme in
                        Text(LocalizedStringKey(theme)).tag(theme)
                            .foregroundColor(currentTheme.text)
                    }
                }
                .foregroundColor(currentTheme.text)
                .pickerStyle(.segmented)
                
                Spacer()
                
            }
            .padding(.all)
            .background(Material.ultraThinMaterial)
            .cornerRadius(20)
            .padding()
            .offset(y: 50)
            
            Spacer()
        } // Header
    }
    
    @ViewBuilder
    func MapView() -> some View {
        ZStack {
            Map(coordinateRegion: $coordinateRegion, annotationItems: showPlaces) { place in
                MapMarker(coordinate: place.coordinate, tint: currentTheme.badgeColor)
            }
            .ignoresSafeArea()
            .onChange(of: mapSwitcher, perform: { state in
                switch mapSwitcher {
                case "Visited Cities Today": showPlaces = townsToday
                case "Visited Cities Yesterday": showPlaces = townsYesterday
                case "all Visited Cities": showPlaces = townsAll
                default:
                    showPlaces = townsToday
                }
            })
            
            if !appStorage.hasPro && mapSwitcher == "Visited Cities Yesterday" {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appStorage.shopSheet.toggle()
                        }
                    }, label: {
                        VStack(spacing: 20) {
                            Image(systemName: "trophy.fill")
                                .font(.title)
                                .foregroundColor(currentTheme.accentColor)
                            
                            Text("Pro Feature")
                                .foregroundColor(currentTheme.accentColor)
                        }
                        .padding(50)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    })
                    .disabled(appStorage.hasPro)
                    .padding()
                    .cornerRadius(10)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial.opacity(0.92))
            } else if !appStorage.hasPro && mapSwitcher == "all Visited Cities" {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appStorage.shopSheet.toggle()
                        }
                    }, label: {
                        VStack(spacing: 20) {
                            Image(systemName: "trophy.fill")
                                .font(.title)
                                .foregroundColor(currentTheme.accentColor)
                            
                            Text("Pro Feature")
                                .foregroundColor(currentTheme.accentColor)
                        }
                        .padding(50)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    })
                    .disabled(appStorage.hasPro)
                    .padding()
                    .cornerRadius(10)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial.opacity(0.92))
            }
        }
    }
    
    func loadCitys() {
        let _ = visitedTownsToday.filter({ return $0.latitude != 0.0 }).map {
            townsToday.append(Places(name: $0.name ?? "", date: $0.date ?? Date(), latitude: $0.latitude, longitude: $0.longitude))
            showPlaces.append(Places(name: $0.name ?? "", date: $0.date ?? Date(), latitude: $0.latitude, longitude: $0.longitude))
        }
        
        if appStorage.hasPro {
            let _ = visitedTownsYesterday.filter({ return $0.latitude != 0.0 }).map {
                townsYesterday.append(Places(name: $0.name ?? "", date: $0.date ?? Date(), latitude: $0.latitude, longitude: $0.longitude))
            }
            
            let _ = visitedTownsAll.filter({ return $0.latitude != 0.0 }).map {
                townsAll.append(Places(name: $0.name ?? "", date: $0.date ?? Date(), latitude: $0.latitude, longitude: $0.longitude))
            }
        } else {
            townsYesterday.removeAll(keepingCapacity: true)
            
            townsAll.removeAll(keepingCapacity: true)
        }
        
        
        coordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: visitedTownsToday.last?.latitude ?? 53.539887, longitude: visitedTownsToday.last?.longitude ?? 9.983621),
            span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
        )
    }
}

struct VisitedCitys_Previews: PreviewProvider {
    static var previews: some View {
        VisitedCitys(tab: .constant(.calendar), theme: .blue)
            .environmentObject(AppStorageManager())
    }
}

struct Places: Identifiable {
    var id = UUID()
    let name: String
    let date: Date
    let latitude: Double
    let longitude: Double
  
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
