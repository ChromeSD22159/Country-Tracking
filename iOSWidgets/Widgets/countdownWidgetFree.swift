//
//  iOSWidgets.swift
//  iOSWidgets
//
//  Created by Frederik Kohler on 24.06.23.
//

import WidgetKit
import SwiftUI
import CoreData
import Intents

struct FreeCountDownProvider: TimelineProvider  { // TimelineProvider
    @Environment(\.managedObjectContext) private var viewContext
    //struct FreeCountDownProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> FreeCountDownEntry {
        //FreeCountDownEntry(date: Date(), configuration: ConfigurationIntent())
        FreeCountDownEntry(date: Date())
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (FreeCountDownEntry) -> ()) {
            //let entry = FreeCountDownEntry(date: Date(), configuration: ConfigurationIntent())
            let entry = FreeCountDownEntry(date: Date())
            completion(entry)
    }
    
    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<Entry>) -> ()) {

        var entries: [FreeCountDownEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            // let entry = FreeCountDownEntry(date: entryDate, configuration: ConfigurationIntent())
            let entry = FreeCountDownEntry(date: entryDate)
            entries.append(entry)
        }
        
        // IMPORTANT COREDATA SYNC
        try? PersistenceController.shared.container.viewContext.setQueryGenerationFrom(.current)
        PersistenceController.shared.container.viewContext.refreshAllObjects()
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct FreeCountDownEntry: TimelineEntry {
    let date: Date
    //let configuration: ConfigurationIntent
}

struct FreeCountDownEntryView : View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.widgetFamily) private var widgetFamily
    
    
    var entry: FreeCountDownProvider.Entry
    
    @State var theme: Themes = .default
    
    private var currentTheme: Theme {
        return self.theme.theme
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.date, ascending: true)],
        predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Date())  as CVarArg),
        animation: .default)
    var nextDateCountdowns: FetchedResults<Countdown>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.creadet, ascending: false)],
        predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Date())  as CVarArg),
        animation: .default)
    var sortCreatedCountdowns: FetchedResults<Countdown>
    
    @AppStorage("useThemeColorForWidgetBG", store: UserDefaults(suiteName: "group.fk.countryTracking")) var useThemeColorForWidgetBG = true
    
    @AppStorage("toggleWidgetSortable", store: UserDefaults(suiteName: "group.fk.countryTracking")) var toggleWidgetSortable = true
    
    var body: some View {
        ZStack {
            
            if !toggleWidgetSortable {
                
                if let SoCo = sortCreatedCountdowns.first {
                    
                    // DEBUG: - Text("last added")
                    
                    SmallWidget(countdown: SoCo)
                } else {
                    LinearGradient(
                        colors: [
                            currentTheme.backgroundColor.opacity(1),
                            currentTheme.backgroundColor.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(alignment: .center) {
                        Spacer()
                        
                        Text("No countdown available!")
                        
                        Spacer()
                    }
                }
                
                
            } else {
                
                if let NeCo = nextDateCountdowns.first {
                    // DEBUG: - Text("next Countdown")
                    SmallWidget(countdown: NeCo)
                } else {
                    LinearGradient(
                        colors: [
                            currentTheme.backgroundColor.opacity(1),
                            currentTheme.backgroundColor.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(alignment: .center) {
                        Spacer()
                        
                        Text("No countdown available!")
                        
                        Spacer()
                    }
                }
                
            }
            
            
        }
        .onAppear{
            theme = themeManager.currentTheme()
        }
    }
    
    @ViewBuilder
    func SmallWidget(countdown: Countdown) -> some View {
        if useThemeColorForWidgetBG {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [
                    currentTheme.backgroundColor.opacity(1),
                    currentTheme.backgroundColor.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            LinearGradient(
                colors: [
                    countdown.color?.getColor().opacity(1) ?? currentTheme.backgroundColor.opacity(1),
                    countdown.color?.getColor().opacity(0.5) ?? currentTheme.backgroundColor.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        if countdown.bgImage {
            Image("SmallWidgetTransparent")
                .resizable()
                .ignoresSafeArea()
        }
        
        
        VStack {
            HStack {
                Text("\(countdown.name ?? "")")
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Spacer()
            
            numberOfDaysBetween(countdown.date ?? Date(), and: Date() )
            
            Spacer()
            
            HStack {
                /*
                if (countdown.icon != nil) {
                    let d = countdown.date?.dateFormatte(date: "dd", time: "").date ?? Date().dateFormatte(date: "dd", time: "").date
                    
                    Image(systemName: "\(d).square.fill")
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "airplane.departure")
                        .foregroundColor(.white)
                }*/
                
                if countdown.icon == "12.square.fill" {
                    
                    let d = countdown.date?.dateFormatte(date: "dd", time: "").date ?? Date().dateFormatte(date: "dd", time: "").date
                    
                    Image(systemName: "\(d).square.fill")
                        .foregroundColor(.white)
                } else {
                    Image(systemName: countdown.icon ?? "airplane.departure")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(countdown.date?.dateFormatte(date: "dd.MM.yyyy", time: "").date ?? Date().dateFormatte(date: "dd", time: "").date)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            
        }
        .padding()
        
    }
    
    func Background() -> some View {
        ZStack {
            currentTheme.backgroundColor.ignoresSafeArea()
        }
    }
    
    func numberOfDaysBetween(_ from: Date, and to: Date) -> some View {
        let calendar = Calendar.current

        let numberOfDays = calendar.dateComponents([.day, .hour, .minute], from: from, to: to)

        if to < from {
            return resultView(days: abs(numberOfDays.day!), hours: abs(numberOfDays.hour!), min: abs(numberOfDays.minute!))
        } else {
            return resultView(days: -numberOfDays.day!, hours: -numberOfDays.hour!, min: -numberOfDays.minute!)
        }
    }
    
    @ViewBuilder
    func resultView(days: Int, hours: Int, min: Int) -> some View {
        
        
        if days != 0 && hours >= 0 {
            HStack(alignment: .lastTextBaseline) {
                Text("\(days)")
                    .foregroundColor(min < 0 || days < 0 ? .white.opacity(0.5) : .white.opacity(1))
                    .font(.system(size: 40, weight: .bold))
                
                Spacer()
                
                Text(days == 1 ? LocalizedStringKey("Day") : LocalizedStringKey("Days"))
                    .foregroundColor(min < 0 || days < 0 ? .white.opacity(0.5) : .white.opacity(1))
                    .font(.system(size: 25, weight: .bold))
            }
        } else {
            HStack(alignment: .lastTextBaseline) {
                Text("\(hours):\(min >= 10 || min <= -10 ? String(abs(min)) : "0"+String(abs(min)))")
                    .foregroundColor(min < 0 || days < 0 ? .white.opacity(0.5) : .white.opacity(1))
                    .font(.system(size: 40, weight: .bold))

                Spacer()
                
                Text("h")
                    .foregroundColor(min < 0 || days < 0 ? .white.opacity(0.5) : .white.opacity(1))
                    .font(.system(size: 25, weight: .bold))
            }
        }
    }
}

struct FreeCountDownWidget: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "FreeCountDownWidget"

    @ObservedObject var themeManager = ThemeManager()
    
    var body: some WidgetConfiguration {
        /*
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: FreeCountDownProvider()
        ) { entry in
         FreeCountDownEntryView(entry: entry)
             .environment(\.managedObjectContext, persistenceController.container.viewContext)
             .environmentObject(themeManager)
        }
        .configurationDisplayName("MyText Widget")
        .description("Show you favorite text!")
        .supportedFamilies([
            .systemSmall,
        ])
         */
        
        StaticConfiguration(kind: kind, provider: FreeCountDownProvider()) { entry in
            FreeCountDownEntryView(entry: entry)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(themeManager)
                .onAppear{
                    persistenceController.container.viewContext.refreshAllObjects()
                }
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Single countdown")
        .description("Always keep an eye on your event.")
        
    }
}

struct FreeCountDownWidget_Previews: PreviewProvider {
    static var previews: some View {
        FreeCountDownEntryView(entry: FreeCountDownEntry(date: Date()))
        //FreeCountDownEntryView(entry: FreeCountDownEntry(date: Date(), configuration: ConfigurationIntent()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(LocationWidgetProvider())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
           
    }
}
