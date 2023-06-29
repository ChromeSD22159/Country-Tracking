//
//  ContentEntry.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 24.06.23.
//

import SwiftUI
import Foundation
import WidgetKit

struct CalendarEntry: View {
    
    let countries: [(name: String, iso: String)] = [
        (name: "Spain", iso: "ES"),
        (name: "Germany", iso: "DE"),
        (name: "Swiss", iso: "CH"),
        (name: "France", iso: "FR"),
        (name: "Austria", iso: "AT"),
        (name: "Croatia", iso: "HR")
    ]
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appStorage: AppStorageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var calendar: CalendarViewModel
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.date, ascending: true)],
        predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -7, to: Date())! ) as CVarArg),
        animation: .default)
    private var visitedCountries: FetchedResults<VisitedCountry>
    
    @State var isSettingsSheet = false
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                currentTheme.backgroundColor.ignoresSafeArea()
                
                Image(currentTheme.BackgroundImage)
                    .resizable()
                    .ignoresSafeArea()
                
                
                VStack {
                    ZStack {
                        VStack {
                            ScrollView {
                                VStack(spacing: 10) {
                                    
                                    CalendarView(control: false, theme: theme)
                                    
                                    // MARK: - SORTED ENTRIES
                                    //sortedEntries()

                                    // MARK: - ALL ENTRIES
                                    //allEntries()
                                }
                                .font(.body)
                                .padding(.top, 70)
                            }
                        } // Content
                        
                        
                        Header()
                    }
                }
                
            }
        }
        .foregroundColor(currentTheme.text)
        .fullScreenCover(isPresented: $isSettingsSheet, content: {
            
            ZStack(content: {
                currentTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 20) {
                      
                    HStack {
                        Spacer()
                        
                        
                        Button(action: {isSettingsSheet.toggle()}){
                            Image(systemName: "xmark")
                                .foregroundColor(currentTheme.text)
                        }
                    }
                    .padding()
                    
                    Text("Settings")
                        .font(.title3.bold())
                        .foregroundColor(currentTheme.text)
                    
                    
                    Section(content: {
                        HStack {
                            Text("Theme")
                                .foregroundColor(currentTheme.text)
                            
                            Spacer()
                            
                            Picker("Appearance", selection: $appStorage.currentTheme) {
                                ForEach(["default", "blue", "green"], id: \.self) { theme in
                                    Text(theme).tag(theme)
                                }
                            }
                            .foregroundColor(currentTheme.text)
                            .pickerStyle(.menu)
                        }
                    })
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    
                    Section(content: {
                        HStack {
                            Text("Theme")
                                .foregroundColor(currentTheme.text)
                            
                            Spacer()
                            
                            Picker("Theme", selection: $appStorage.currentTheme) {
                                ForEach(["default", "blue", "green"], id: \.self) { theme in
                                    Text(theme).tag(theme)
                                        .foregroundColor(currentTheme.text)
                                }
                            }
                            .foregroundColor(currentTheme.text)
                            .pickerStyle(.segmented)
                        }
                    })
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    
                    Section(content: {
                        HStack {
                            Text("Debug")
                                .foregroundColor(currentTheme.text)
                            
                            Spacer()
                            
                            Toggle("", isOn: appStorage.$Debug)
                        }
                    })
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    
                    Spacer()
                }
                .padding(.horizontal)
            })
            
        })
       
    }

    @ViewBuilder
    func Header() -> some View {
        VStack {
            HStack {
                HStack(spacing: 10) {
                    if appStorage.Debug {
                        Button(action: { isSettingsSheet.toggle() }) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .font(.callout)
                .foregroundColor(currentTheme.headerText)
                
                Spacer()
                
                CalendarControls(color: currentTheme.text)
                
                Spacer()
                
                HStack(spacing: 10) {
                    
                    if appStorage.Debug {
                        
                        Button(action: { deleteAllVisitedCountry() } ) {
                            Image(systemName: "trash")
                        }
                    } else {
                        Button(action: { isSettingsSheet.toggle() }) {
                            Image(systemName: "gear")
                        }
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
    func sortedEntries() -> some View {
        VStack {
            HStack{
                Text("Saved Entries:")
                    .font(.title3.bold())
                    .padding(.horizontal)
                
                Spacer()
            }
            
            // MARK: - SORTET ENTRIES
            List {
                ForEach(visitedCountries, id: \.id) { country in
                    HStack(spacing: 20) {
                        
                      //  Image(uiImage: getFlagString(iso ?? "ES"))
                        
                        Text("\(country)")
                            .font(.callout.bold())
                            .foregroundColor(currentTheme.text)
                        
                        Spacer()
                    }
                    .listRowBackground(currentTheme.backgroundColor)
                }
                .listRowBackground(currentTheme.backgroundColor)

            }
        }
        
    }
    
    @ViewBuilder
    func allEntries() -> some View {
        VStack {
            HStack{
                Text("All Entries:")
                    .font(.title3.bold())
                    .padding(.horizontal)
                
                Spacer()
            }
            
            ForEach(visitedCountries, id: \.id) { country in
                HStack(spacing: 20) {
                    Text("\(country.name ?? "") (\(country.region ?? ""))")
                        .font(.callout.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Spacer()
                    
                    Text(country.date!, style: .date)
                        .font(.caption2.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Text(country.date!, style: .time)
                        .font(.caption2.bold())
                        .foregroundColor(currentTheme.text)
                    
                }
                .listRowBackground(currentTheme.backgroundColor)
            }
            .listRowBackground(currentTheme.backgroundColor)
        }
    }
    
    private func deleteVisitedCountry(offsets: IndexSet) {
        withAnimation {
            offsets.map { visitedCountries[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteAllVisitedCountry() {
        withAnimation {
            //offsets.map { visitedCountries[$0] }.forEach(viewContext.delete)

            visitedCountries.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentEntry_Previews: PreviewProvider {
    static var previews: some View {
        CalendarEntry(theme: .blue)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppStorageManager())
            .environmentObject(ThemeManager())
            .environmentObject(CalendarViewModel())
    }
}
