//
//  iOSWidgets.swift
//  iOSWidgets
//
//  Created by Frederik Kohler on 24.06.23.
//

import WidgetKit
import SwiftUI
import CoreData
/*
struct CountryTrackerSevenDaysProvider: TimelineProvider {
  
    func placeholder(in context: Context) -> CountryTrackerSevenDaysEntry {
        CountryTrackerSevenDaysEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CountryTrackerSevenDaysEntry) -> ()) {
        let entry = CountryTrackerSevenDaysEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [CountryTrackerSevenDaysEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = CountryTrackerSevenDaysEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct CountryTrackerSevenDaysEntry: TimelineEntry {
    let date: Date
}

struct CountryTrackerSevenDaysEntryView : View {
    
    
    @EnvironmentObject var location: LocationWidgetProvider
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // List All Visited Countrys in Calendar
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.date, ascending: true)],
        predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Date())  as CVarArg),
        animation: .easeInOut
    ) private var VisitedCountriesToday: FetchedResults<VisitedCountry>
 
    
    // Only get Visited Country once
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.date, ascending: true)],
        animation: .default)
    var countries: FetchedResults<Countries>
    
    var entry: CountryTrackerSevenDaysProvider.Entry

    @AppStorage("currentCountry") var currentCountry: String = ""
    @AppStorage("currentCity") var currentCity: String = ""
    @AppStorage("currentRegion") var currentRegion: String = ""

    
    var body: some View {
        ViewThatFits {
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 5) {
                    
                    // Header
                    Header()
                    
                    // Content
                    Content()
                    // Footer
                    Footer()
                }
                .padding()
                .onAppear{
                    checkVisitedCountryToday()
                    
                    CheckVisitedCountryList()
                }
            }
            
        }
    }
    
    private func checkVisitedCountryToday() {
        let visitedCountriesToday = VisitedCountriesToday.filter { country in
            country.name == currentCountry
        }
        
        if visitedCountriesToday.count == 0 {
            print("\(currentRegion.countryName()) add Country to Calendar")
            addCountryTodayCalendar()
        } else {
            print("\(currentRegion.countryName()) already exist in Calendar")
        }
    }
    
    private func addCountryTodayCalendar() {
        
        let newCountry = VisitedCountry(context: viewContext)
        newCountry.date = Date()
        newCountry.name = currentCountry
        newCountry.region = currentRegion
        
        do {
            try viewContext.save()
            
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func CheckVisitedCountryList() {
        let countryList = countries.filter { country in
            country.region == currentRegion
        }
        
        if countryList.count == 0 {
            print("\(currentRegion) add Country to CountryList")
            addCountryAllCountries(region: currentRegion)
        } else {
            print("\(currentRegion.countryName()) already exist in CountryList")
        }
    }
    
    private func addCountryAllCountries(region: String) {
        
        let newCountry = Countries(context: viewContext)
        newCountry.date = Date()
        newCountry.region = currentRegion
        
        do {
            try viewContext.save()
            
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    @ViewBuilder
    func Header() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if currentCity.count > 0 {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(Color.mint)
                    
                    Text(currentCity)
                        .font(.caption2)
                        .foregroundColor(Color.mint)
                    
                    Spacer()
                }
                .padding(.bottom, 5)
               
            }
            
            HStack {
                Text("Today:")
                    .font(.caption.bold())
                    .foregroundColor(Color.mint)
                Spacer()
            }
            
        }
    }
    
    @ViewBuilder
    func Content() -> some View {
        VStack(spacing: 6) {
            ForEach(VisitedCountriesToday.prefix(3)) { country in
                HStack {
                    
                    Text(country.region?.countryFlag() ?? "")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text(country.region?.countryName() ?? "")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func Footer() -> some View {
        HStack {
            Spacer()
            Text("Updated:")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text(entry.date,style: .time)
                .font(.caption2)
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
}

struct SevenDays: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "iOSWidgets"
    
    @AppStorage("currentCountry") var currentCountry: String = ""
    @AppStorage("currentCity") var currentCity: String = ""
    @AppStorage("currentRegion") var currentRegion: String = ""
    @ObservedObject private var location: LocationWidgetProvider = LocationWidgetProvider()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountryTrackerSevenDaysProvider()) { entry in
            CountryTrackerSevenDaysEntryView(entry: entry)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(location)
                .task {
                    location.requestLocation()
                    location.StartLocation()
                    
                    if let loc = location.location {
                        location.decodeLocation( loc , completion:{ city , country, region,<#arg#>,<#arg#>   in
                            if city.count > 0 {
                                currentCountry = city
                                currentCity =  country
                                currentRegion = region
                            }
                            
                        })
                    }
                }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        
    }
}

struct SevenDays_Previews: PreviewProvider {
    static var previews: some View {
        CountryTrackerSevenDaysEntryView(entry: CountryTrackerSevenDaysEntry(date: Date()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(LocationWidgetProvider())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
           
    }
}
*/
