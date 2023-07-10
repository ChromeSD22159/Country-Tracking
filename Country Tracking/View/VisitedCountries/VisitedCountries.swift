//
//  InterACtiveMap.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 29.06.23.
//

import SwiftUI
import WidgetKit

struct VisitedCountries: View {
    @EnvironmentObject var appStorage: AppStorageManager
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Countries.region, ascending: false)],
        animation: .default)
    var countries: FetchedResults<Countries>
    
    private var uniqueCountries: [Countries] {
        var mapped:[Countries] = []
        
        let _ = countries.map({ co in
            let x = mapped.first(where: { $0.region!.contains(co.region!) })
            
            if x == nil {
                mapped.append(co)
            }
        })
        
        return mapped
    }
    
    @State var isSettingsSheet = false
    
    @Binding var tab: Tab
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    var allExistCountries: Int {
        return NSLocale.isoCountryCodes.count
    }
    
    @State var currentStatistic = "Today"
    
    var body: some View {
        ZStack {
            
            VStack {
                ZStack {
                    VStack {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 20) {
                                Card()
                                
                                Picker("Appearance", selection: $currentStatistic) {
                                    ForEach([ "Today", "Last 7 Days", "Last 30 Days", "All Time"], id: \.self) { theme in
                                        Text(LocalizedStringKey(theme)).tag(theme)
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
        .foregroundColor(currentTheme.text)
        .sheet(isPresented: $isSettingsSheet, content: {
            
            SettingsSheetBody(theme: theme, isSettingsSheet: $isSettingsSheet)
            
        })
        .onAppear{
            let _ = countries.map {
                print("Entity `Countries`:\($0.id) \($0.region!)")
            }
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
                
                Text("Visited Countries")
                
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
    func Card() -> some View {
        ZStack {
            currentTheme.text.opacity(0.5).colorInvert()
            
            Image("Background_Card_World")
                .resizable()
                .scaledToFit()
            
            HStack {
                Text("Your`ve visited **\(uniqueCountries.count)/\(allExistCountries)** Countries")
                Spacer()
            }
            .padding()
            
        }
    }

    func Content() -> some View {
        VStack {
            
            switch currentStatistic {
            case "All Time": return self.ListSection(days: nil)
            case "Today": return self.ListSection(days: 1)
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
                
                ForEach(uniqueCountries) { country in
                    ZStack {
                        
                        if d == 30 {
                            CountryButton(country: country, theme: theme, days: d)
                                .blur(radius:  appStorage.hasPro ? 0 : 5)
                        } else {
                            CountryButton(country: country, theme: theme, days: d)
                        }
                        
                       
                        // PRO Overlay
                        if !appStorage.hasPro && d == 30 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    appStorage.shopSheet.toggle()
                                }
                            }, label: {
                                HStack {
                                    Spacer()
                                    
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(currentTheme.accentColor)
                                    
                                    Text("Pro Feature")
                                        .foregroundColor(currentTheme.accentColor)
                                    
                                    Spacer()
                                }
                                .foregroundColor(currentTheme.text)
                            })
                            .disabled(appStorage.hasPro)
                            .padding()
                            .background(Material.ultraThinMaterial.opacity(0.5))
                            .cornerRadius(10)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        } // PRO Overlay
                    }
                }
                .foregroundColor(currentTheme.text)
            })
        } else {
            
            // all time
            Section(content: {
                ForEach(uniqueCountries) { country in
                    ZStack {
                        
                        CountryButton(country: country, theme: theme)
                            .blur(radius: appStorage.hasPro ? 0 : 5)
                        
                        // PRO Overlay
                        if !appStorage.hasPro {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    appStorage.shopSheet.toggle()
                                }
                            }, label: {
                                HStack {
                                    Spacer()
                                    
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(currentTheme.accentColor)
                                    
                                    Text("Pro Feature")
                                        .foregroundColor(currentTheme.accentColor)
                                    
                                    Spacer()
                                }
                                .foregroundColor(currentTheme.text)
                            })
                            .disabled(appStorage.hasPro)
                            .padding()
                            .background(Material.ultraThinMaterial.opacity(0.5))
                            .cornerRadius(10)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        } // PRO Overlay
                    }
                }
                .foregroundColor(currentTheme.text)
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
    
    func toXmas(year: String) -> LocalizedStringKey {
        let calendar = Calendar.current

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        let date = dateFormatter.date(from: "18:00:00 24-12-" + year) ?? Date()

        let v = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date)

        if v.day! > 0 {
            return LocalizedStringKey("\( v.day! ) Days until christmas")
        } else {
            return LocalizedStringKey("\( v.day! ) days since last christmas")
        }
    }
    
    func toSilvester(year: String) -> LocalizedStringKey {
        let calendar = Calendar.current

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        let date = dateFormatter.date(from: "23:59:59 31-12-" + year) ?? Date()

        let v = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date)

        if v.day! > 0 {
            return LocalizedStringKey("\( v.day! ) days until the end of the year")
        } else {
            return LocalizedStringKey("\( v.day! ) days since new year's eve")
        }
    }
}

struct CountryButton: View {
    // MARK: Environments
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appStorage: AppStorageManager
    
    private var country: FetchedResults<Countries>.Element
    
    private var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    private var days: Int
    
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
            let date = Date().startEndOfDay().end
            _fetchRequest = FetchRequest<VisitedCountry>(
                sortDescriptors: [],
                predicate: NSPredicate(format: "region == %@ and date > %@", country.region ?? "" , Calendar.current.date(byAdding: .day, value: -days!, to: date)! as CVarArg)
            )
        }
        
    }
    
    var body: some View {
        
        if fetchRequest.count > 0 {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if !appStorage.hasPro {
                        appStorage.shopSheet.toggle()
                    }
                }
            }, label: {
                HStack {
                    Text("\(country.region?.countryFlag() ?? "") \(country.region?.countryName() ?? "")")
                    
                    Spacer()
                    
                    if fetchRequest.count == 1 {
                        Text("\(fetchRequest.count) day")
                    } else if fetchRequest.count > 1 {
                        Text("\(fetchRequest.count) days")
                    }
                }
                .foregroundColor(currentTheme.text)
            })
            .disabled(appStorage.hasPro)
            .padding()
            .background(Material.ultraThinMaterial)
            .cornerRadius(10)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
        }
        
    }
    
}

struct VisitedCountries_Previews: PreviewProvider {
    static var theme: Theme = Theme(
        backgroundColor: Color(red: 5/255, green: 84/255, blue: 140/255),
        BackgroundImage: "BG_DARK",
        headerBackgroundColor: .blue.opacity(0.5),
        headerText: Color.white,
        text: Color.white,
        textInverse: Color.white,
        accentColor: Color.orange,
        badgeColor: Color.red,
        iconName: "AppLogoBlack",
        description: ""
    )
    
    static var previews: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VisitedCountries(tab: .constant(.calendar), theme: .default)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AppStorageManager())
        }
    }
}
