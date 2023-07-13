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
        animation: .default)
    private var visitedCountries: FetchedResults<VisitedCountry>
    
    @Binding var tab: Tab
    
    @State var isSettingsSheet = false
    
    @State var orientation = UIDeviceOrientation.unknown
    
    @State var deviceWidth: CGFloat?
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }

    private var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let max = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return min...max
    }
    
    var body: some View {
        ZStack {
            VStack {

                ScrollView(showsIndicators: false) {
                   
                    ViewThatFits(content: {
                        // LANDSCAPE
                        HStack {
                            
                            Spacer()
                              
                            VStack{
                                CalendarView(control: true, theme: theme)
                                    .frame(maxWidth: 430)
                                    .padding(.top, 70)
                            }
                            
                            Spacer()
                        }
                        
                        
                        // PORTRAIT
                        VStack(spacing: 10) {
                            CalendarView(control: true, theme: theme)
                                .frame(maxWidth: 430)
                        }
                        .font(.body)
                        
                    })
                }
                    .blur( radius: calendar.showPicker ? 4 : 0)
                
            } // Content
            
            if calendar.showPicker {
              
                VStack {
                    ZStack {
                        Color.black.opacity(0.5).ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        calendar.showPicker = false
                                    }
                                }, label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                })
                            }
                            .padding(.horizontal, 50)
                            
                            DatePicker(
                                "",
                                selection: $calendar.selectedDate,
                                in: dateClosedRange,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            
                            Spacer()
                        }
                    }
                    
                    
                    
                    Spacer()
                }
                
            }
            
            Header()
        }
        .onAppear {
            orientation = UIDevice.current.orientation
            deviceWidth = UIScreen.main.bounds.size.width
            
        }
        .onRotate { newOrientation, newdeviceWidth  in
            orientation = newOrientation
            deviceWidth = newdeviceWidth
        }
        .foregroundColor(currentTheme.text)
        .sheet(isPresented: $isSettingsSheet, content: {
            
            SettingsSheetBody(theme: theme, isSettingsSheet: $isSettingsSheet)
            
        })
       
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
                
                Text("Visited Countries")
                //CalendarControls(color: currentTheme.text)
                
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
        ContentView(theme: .default)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppStorageManager())
            .environmentObject(ThemeManager())
            .environmentObject(CalendarViewModel())
            .environmentObject(IconNames())
            .environmentObject(EntitlementManager())
            .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
            //.previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
    }
}
