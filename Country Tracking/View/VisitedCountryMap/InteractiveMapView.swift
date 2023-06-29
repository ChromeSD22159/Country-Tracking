//
//  InterACtiveMap.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 29.06.23.
//

import SwiftUI
import InteractiveMap
import WidgetKit

struct InteractiveMapView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Countries.region, ascending: false)],
        animation: .default)
    var countries: FetchedResults<Countries>
    
    @State var isSettingsSheet = false
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    var allExistCountries: Int {
        return NSLocale.isoCountryCodes.count
    }
    @State var currentStatistic = "Last 7 Days"
    
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
                                VStack(alignment: .leading, spacing: 20) {
                                    Card()
                                    
                                    Picker("Appearance", selection: $currentStatistic) {
                                        ForEach([ "Last 7 Days", "Last 30 Days", "All Time"], id: \.self) { theme in
                                            Text(theme).tag(theme)
                                        }
                                    }
                                    .foregroundColor(currentTheme.text)
                                    .pickerStyle(.segmented)
                                    .padding(.horizontal)
                                    
                                    Content()
                                        .padding(.horizontal)
                                    
                                    Text(toSilvester(year: "2023"))
                                        .padding(.horizontal)
                                    
                                    Text(toXmas(year: "2023"))
                                        .padding(.horizontal)
                                }
                                .font(.body)
                                .padding(.top, 50)
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
                        
                        Button(action: { deleteAllCountries() } ) {
                            Image(systemName: "trash")
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
    func Card() -> some View {
        ZStack {
            currentTheme.text.opacity(0.5).colorInvert()
            
            Image("Background_Card_World")
                .resizable()
                .scaledToFit()
            
            HStack {
                Text("Your`ve visited **\(countries.count)/\(allExistCountries)** Countries")
                Spacer()
            }
            .padding()
            
        }
    }

    func Content() -> some View {
        VStack {
            
            switch currentStatistic {
            case "All Time": return self.ListSection(days: nil)
            case "Last 7 Days": return self.ListSection(days: 7)
            case "Last 30 Days": return self.ListSection(days: 30)
            default:
               return self.ListSection(days: nil)
            }
        }
        
    }
    
    @ViewBuilder
    func ListSection(days: Int?) -> some View {
        if let d = days {
            Section(content: {
                ForEach(countries) { country in
                    CountryButton(country: country, theme: theme, days: d)
                }
                .foregroundColor(currentTheme.text)
            }, header: {
                HStack {
                    Text("Last \(d) Time")
                    Spacer()
                }
            })
        } else {
            Section(content: {
                ForEach(countries) { country in
                    CountryButton(country: country, theme: theme)
                }
                
                .foregroundColor(currentTheme.text)
            }, header: {
                HStack {
                    Text("All Time")
                    Spacer()
                }
            })
        }
    }
    
    private func deleteAllCountries() {
        withAnimation {
            countries.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func toXmas(year: String) -> String {
        let calendar = Calendar.current

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        let date = dateFormatter.date(from: "18:00:00 24-12-" + year) ?? Date()

        let v = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date)

        if v.day! > 0 {
            return "\( v.day! ) Days left till Chrismas"
        } else {
            return "\( v.day! ) Days since Chrismas \(year)"
        }
    }
    
    func toSilvester(year: String) -> String {
        let calendar = Calendar.current

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        let date = dateFormatter.date(from: "23:59:59 31-12-" + year) ?? Date()

        let v = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date)

        if v.day! > 0 {
            return "\( v.day! ) Days left till Silvester \(year)"
        } else {
            return "\( v.day! ) Days since Silvester \(year)"
        }
    }
}

struct CountryButton: View {
    // MARK: Environments
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appStorage: AppStorageManager
    
    private var country: FetchedResults<Countries>.Element
    
    private var theme: Themes
    
    private var days: Int
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    // MARK: STATES
    @FetchRequest var fetchRequest: FetchedResults<VisitedCountry>

    init(country: FetchedResults<Countries>.Element, theme: Themes, days: Int? = -1) {
        self.theme = theme
        self.country = country
        self.days = days ?? -1
        
        if days == -1 {
            _fetchRequest = FetchRequest<VisitedCountry>(
                sortDescriptors: [],
                predicate: NSPredicate(format: "region == %@", country.region ?? "" )
            )
        } else {
            _fetchRequest = FetchRequest<VisitedCountry>(
                sortDescriptors: [],
                predicate: NSPredicate(format: "region == %@ and date > %@", country.region ?? "" , Calendar.current.date(byAdding: .day, value: -days!, to: Date())! as CVarArg)
            )
        }
        
    }
    
    var body: some View {
        
        if fetchRequest.count > 0 {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    // Do Someting
                }
            }, label: {
                HStack {
                    Text("\(country.region?.countryFlag() ?? "") \(country.region?.countryName() ?? "")")
                    
                    Spacer()
                    
                    Text("\(fetchRequest.count) days")
                }
                .foregroundColor(currentTheme.text)
            })
            .padding()
            .background(Material.ultraThinMaterial)
            .cornerRadius(10)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
        }
        
    }
    
}

struct InteractiveMap_Previews: PreviewProvider {
    static var theme: Theme = Theme(
        backgroundColor: Color(red: 5/255, green: 84/255, blue: 140/255),
        BackgroundImage: "BG_DARK",
        headerBackgroundColor: .blue.opacity(0.5),
        headerText: Color.white,
        text: Color.white,
        textInverse: Color.white,
        accentColor: Color.orange,
        badgeColor: Color.red
    )
    
    static var previews: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            InteractiveMapView(theme: .default)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AppStorageManager())
        }
    }
}
