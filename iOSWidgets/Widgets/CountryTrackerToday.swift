//
//  iOSWidgets.swift
//  iOSWidgets
//
//  Created by Frederik Kohler on 24.06.23.
//

import WidgetKit
import SwiftUI
import CoreData

struct CountryTrackerTodayProvider: TimelineProvider {
  
    func placeholder(in context: Context) -> CountryTrackerTodayEntry {
        CountryTrackerTodayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CountryTrackerTodayEntry) -> ()) {
        let entry = CountryTrackerTodayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [CountryTrackerTodayEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = CountryTrackerTodayEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct CountryTrackerTodayEntry: TimelineEntry {
    let date: Date
}

struct CountryTrackerTodayEntryView : View {
    
    
    @EnvironmentObject var location: LocationWidgetProvider
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.widgetFamily) private var widgetFamily
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
    
    // Get all Visited Citys Today
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedTown.date, ascending: true)],
        predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Date())  as CVarArg),
        animation: .default)
    var visitedTowns: FetchedResults<VisitedTown>
    
    var entry: CountryTrackerTodayProvider.Entry
    
    @State var theme: Themes = .default
    
    private var currentTheme: Theme {
        return self.theme.theme
    }
    
    @AppStorage("currentCountry") var currentCountry: String = ""
    @AppStorage("currentCity") var currentCity: String = ""
    @AppStorage("currentRegion") var currentRegion: String = ""
    @AppStorage("currentLatitide") var currentLatitide: Double = 0.0
    @AppStorage("currentLongitude") var currentLongitude: Double = 0.0
    
    var body: some View {
        ViewThatFits {
            
            
            ZStack {
                Background()
                
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
                    
                    checkVisitedLocationToday()
                    
                    theme = themeManager.currentTheme()
                }
            }
            
        }
    }
    
    func Background() -> some View {
        ZStack {
            currentTheme.backgroundColor.ignoresSafeArea()
            
            switch widgetFamily {
            case .systemSmall:
                
                switch theme {
                case .default:
                    Image("SmallBlack").resizable().scaledToFill()
                case .black:
                    Image("SmallBlack").resizable().scaledToFill()
                case .blue:
                    Image("SmallBlue").resizable().scaledToFill()
                case .orange:
                    Image("SmallOrange").resizable().scaledToFill()
                case .green:
                    Image("SmallGreen").resizable().scaledToFill()
                }
                
                
            case .systemMedium:
                switch theme {
                case .default:
                    Image("MediumBlack").resizable().scaledToFill()
                case .black:
                    Image("MediumBlack").resizable().scaledToFill()
                case .blue:
                    Image("MediumBlue").resizable().scaledToFill()
                case .orange:
                    Image("MediumOrange").resizable().scaledToFill()
                case .green:
                    Image("MediumGreen").resizable().scaledToFill()
                }
            
            case .systemLarge: Image("LargeWidgetTransparent").resizable().scaledToFill()
                switch theme {
                case .default:
                    Image("LargeBlack").resizable().scaledToFill()
                case .black:
                    Image("LargeBlack").resizable().scaledToFill()
                case .blue:
                    Image("LargeBlue").resizable().scaledToFill()
                case .orange:
                    Image("LargeOrange").resizable().scaledToFill()
                case .green:
                    Image("LargeGreen").resizable().scaledToFill()
                }
            
            
            case .systemExtraLarge:
                Image("SmallWidgetTransparent").resizable().scaledToFill()
            case .accessoryCircular:
                Image("SmallWidgetTransparent").resizable().scaledToFill()
            case .accessoryRectangular:
                Image("SmallWidgetTransparent").resizable().scaledToFill()
            case .accessoryInline:
                Image("SmallWidgetTransparent").resizable().scaledToFill()
            @unknown default:
                Image("SmallWidgetTransparent").resizable().scaledToFill()
            }
        }
    }
    
    private func checkVisitedCountryToday() {
        let visitedCountriesToday = VisitedCountriesToday.filter { country in
            country.region == currentRegion
        }
        
        if visitedCountriesToday.count == 0 {
            print("\(currentRegion.countryName()) add Country to Calendar")
            addCountryTodayCalendar()
        } else {
            print("\(currentRegion.countryName()) already exist in Calendar")
        }
    }
    
    private func addCountryTodayCalendar() {
        
        if currentRegion == "" {
            
        } else {
            let newCountry = VisitedCountry(context: viewContext)
            newCountry.date = Date()
            newCountry.name = currentCountry  // Germany
            newCountry.city = currentCity // Waldshut
            newCountry.region = currentRegion // DE
            newCountry.latitude = currentLatitide // 5646546
            newCountry.longitude = currentLongitude // 6546546
            
            do {
                try viewContext.save()
                
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
        
        if currentRegion == "" {
            
        } else {
            let newCountry = Countries(context: viewContext)
            newCountry.date = Date()
            newCountry.region = currentRegion
            
            do {
                try viewContext.save()
                
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func checkVisitedLocationToday() {
        let visitedTownsToday = visitedTowns.filter { city in
            city.name == currentCity
        }
        
        if visitedTownsToday.count == 0 {
            print(" add \(currentCity) to visited Locations")
            addLocationToday()
        } else {
            print("\(currentCity) already exist")
        }
    }
    
    private func addLocationToday() {
        
        if currentRegion == "" {
            
        } else {
            let newLocation = VisitedTown(context: viewContext)
            newLocation.date = Date()
            newLocation.name = currentCity // Waldshut
            newLocation.country = currentCountry // Germany
            newLocation.region = currentRegion // DE
            newLocation.latitude = currentLatitide // 5646546
            newLocation.longitude = currentLongitude // 6546546
            
            do {
                try viewContext.save()
                
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
                        .foregroundColor(currentTheme.accentColor)
                    
                    Text(currentCity)
                        .font(.caption2.bold())
                        .foregroundColor(currentTheme.accentColor)
                    
                    Spacer()
                }
                .padding(.bottom, 5)
               
            }
            
            HStack {
                Text("Today:")
                    .font(.caption.bold())
                    .foregroundColor(currentTheme.text)
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
        VStack {
            HStack {
                Spacer()
                Text("Updated:")
                    .font(.caption2)
                    .foregroundColor(currentTheme.text)
                
                Text(entry.date,style: .time)
                    .font(.caption2)
                    .foregroundColor(currentTheme.text)
                
                if widgetFamily != .systemMedium {
                    Spacer()
                }
            }
        }
    }
    
}

struct CountryTrackerToday: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "iOSWidgets"
    
    @AppStorage("currentCountry") var currentCountry: String = ""
    @AppStorage("currentCity") var currentCity: String = ""
    @AppStorage("currentRegion") var currentRegion: String = ""
    @AppStorage("currentLatitide") var currentLatitide: Double = 0.0
    @AppStorage("currentLongitude") var currentLongitude: Double = 0.0
    
    @ObservedObject private var location: LocationWidgetProvider = LocationWidgetProvider()
    @ObservedObject var themeManager = ThemeManager()
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountryTrackerTodayProvider()) { entry in
            CountryTrackerTodayEntryView(entry: entry)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(location)
                .environmentObject(themeManager)
                .task {
                    location.requestLocation()
                    location.StartLocation()
                    
                    if let loc = location.location {
                        location.decodeLocation( loc , completion:{ city , country, region, latitude, longitude  in
                            if city.count > 0 {
                                currentCountry = city
                                currentCity =  country
                                currentRegion = region
                                currentLatitide = latitude
                                currentLongitude = longitude
                            }
                            
                        })
                    }
                }
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("County Visited Today")
        .description("List of countries which you`ve visited today.")
        
    }
}

struct iOSWidgets_Previews: PreviewProvider {
    static var previews: some View {
        CountryTrackerTodayEntryView(entry: CountryTrackerTodayEntry(date: Date()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(LocationWidgetProvider())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
           
    }
}
