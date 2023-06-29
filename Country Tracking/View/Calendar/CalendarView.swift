//
//  Calendar.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 26.06.23.
//

import SwiftUI
import FlagKit
import CountryKit

struct CalendarView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var control: Bool
    
    var theme: Themes
    
    private var currentTheme: Theme {
        return self.theme.theme
    }
    
    @EnvironmentObject var calendar: CalendarViewModel
    
    private let days: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    @State var viewState = CGSize.zero
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.date, ascending: true)],
        predicate: NSPredicate(format: "date > %@", Date().startOfMonth as CVarArg ),
        animation: .default)
    private var visitedCountries: FetchedResults<VisitedCountry>
    
    var body: some View {
       GeometryReader { screen in
           VStack(spacing: 20) {
               
               if control {
                   HStack{
                       Button(action: {
                           calendar.currentMonth -= 1
                       }, label: {
                           Image(systemName: "chevron.left")
                               .font(.title2)
                               .foregroundColor(.white)
                       })
                       
                       Spacer()
                       
                       Text(calendar.currentDate.dateFormatte(date: "MMMM YYYY", time: "HH:mm").date)
                           .foregroundColor(.white)
                       
                       Spacer()
                       
                       Button(action: {
                           calendar.currentMonth += 1
                       }, label: {
                           Image(systemName: "chevron.right")
                               .font(.title2)
                               .foregroundColor(.white)
                       })
                   }
                   .padding(.horizontal, 20)
               }
               
               /// Header Days
               HStack(spacing: 0) {
                  
                   ForEach(days, id: \.self) { day in
                       Text("\(day)")
                           .font(.callout)
                           .fontWeight(.semibold)
                           .frame(maxWidth: .infinity)
                           .foregroundColor(.white)
                   }
                   
               }
               .padding(.horizontal, 20)
               
               /// Calendar View
               LazyVGrid(columns: columns, spacing: 10) {
                   ForEach(calendar.currentDates) { value in
                       DayButton(date: value, screenSize: screen.size, theme: theme)
                   }
               }
               .padding(.horizontal, 20)
               .gesture(
                   DragGesture()
                     .onChanged() { value in
                         viewState = value.translation
                     }
                     .onEnded { proxy in
                         let height = proxy.translation.height
                         let width = proxy.translation.width
                         
                         if width <= -150 && height > -30 && height < 30  {
                             calendar.currentMonth += 1
                         }
                         
                         if width >= 150 && height > -30 && height < 30  {
                             calendar.currentMonth -= 1
                         }
                     }
             ) // gesture
               
               
           }
           .onAppear {
               calendar.currentDate = Date()
               calendar.currentDates = calendar.extractMonth()
           }
           .onChange(of: calendar.currentMonth, perform: { value in
               calendar.currentDates = calendar.extractMonth()
               calendar.getCurrentMonth()
               calendar.currentDate = (calendar.currentDates.first?.date)!
           })
       }
        
    }
    
}

struct DayButton:View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var calendar: CalendarViewModel
    
    private var date: DateValue
    
    var screenSize: CGSize
    
    var theme: Themes
    
    private var currentTheme: Theme {
        return self.theme.theme
    }
    
    var request: FetchRequest<VisitedCountry>
    var visitedCountries: FetchedResults<VisitedCountry>{ request.wrappedValue }

    var countries: [(id: UUID, name: String, iso: String)] = {

        var arrayOfCountries: [(id: UUID, name: String, iso: String)] = []

        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            arrayOfCountries.append((id: UUID(), name: name, iso: id))
        }

        return arrayOfCountries
    }()
    
    init(
        //predicate: NSPredicate = NSPredicate(value: true),
        predicate: NSPredicate = NSPredicate(format: "date >= %@ && date <= %@ ", Date().startEndOfDay().start as CVarArg , Date().startEndOfDay().end as CVarArg),
        sortDescriptors: [NSSortDescriptor] = [],
        date: DateValue,
        screenSize: CGSize,
        theme: Themes
    ) {
        self.date = date
        self.screenSize = screenSize
        self.theme = theme
        //self.request = FetchRequest( entity: VisitedCountry.entity(), sortDescriptors: sortDescriptors, predicate: predicate )
        self.request = FetchRequest(
            entity: VisitedCountry.entity(),
            sortDescriptors: sortDescriptors,
            predicate: NSPredicate(format: "date >= %@ && date <= %@ ", self.date.date.startEndOfDay().start as CVarArg , self.date.date.startEndOfDay().end as CVarArg)
        )
        
    }
    
    @State var addCountry = false
    
    @State var isPresentingConfirm = false
    
    @State var setDate: Date?
    
    @State var dateSheet = false
    
    @State var dateRangeSheet = false
    
    var body: some View {
        VStack(spacing: 10) {
            if date.day != -1 {
                
                if let country = visitedCountries.first(where: { return calendar.isSameDay(d1: $0.date ?? Date(), d2: date.date) }) {
                    
                    let countriesList = visitedCountries.filter({ calendar.isSameDay(d1: $0.date ?? Date(), d2: date.date) })
                    // Countrys Found
                    
                    CalendarDaySheet(
                     button: {
                        VStack(spacing: 5){
                            
                            Circle()
                                .strokeBorder(date.date > Date() ? .white.opacity(0.05) : .white.opacity(0.5), lineWidth: 1)
                                .background{
                                    ZStack{
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .foregroundColor( calendar.isSameDay(d1: country.date ?? Date() , d2: date.date) ? .gray : Color.white.opacity(0))
                                             .frame(width: screenSize.width / 9, height: screenSize.width / 9 )
                                        
                                        HStack(spacing: 2) {
                                            if countriesList.count > 2 {
                                                Image(systemName: "ellipsis.circle")
                                            } else {
                                                ForEach(countriesList, id: \.self) { co in
                                                    Text(countryFlag(co.region ?? "DE"))
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                .frame(width: screenSize.width / 9, height: screenSize.width / 9 )
                            
                            VStack{
                                Text("\(date.day)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(calendar.isSameDay(d1: date.date , d2: calendar.currentDate) ? Color.white.opacity(0.1) : Color.white.opacity(0))
                            .cornerRadius(20)
                        }
                        .padding(5)
                    },
                     sheetContent: {
                        ZStack(content: {
                            currentTheme.backgroundColor.ignoresSafeArea()
                            Color.gray.opacity(0.1).ignoresSafeArea()
                            
                            ScrollView {
                                VStack {
                                    HStack {
                                        Spacer()
                                        
                                        
                                        AddCalendarDaySheet(
                                            button: {
                                                Label("Add Country", systemImage: "plus")
                                            }, sheetContent: {
                                                AddCountry(date: country.date ?? Date(), theme: theme, List: countriesList.map{ $0.region ?? "" })
                                            }, presentation: .infinity
                                        )
                                        
                                        
                                    }
                                    .padding()
                                    
                                    HStack {
                                        Text("Visited Countries at \(date.date.dateFormatte(date: "dd.MM.YYYY", time: "").date)")
                                            .font(.title3.bold())
                                            .foregroundColor(currentTheme.text)
                                            .padding(.leading, 5)
                                        
                                        Spacer()
                                    }
                                    
                                    
                                    ForEach(visitedCountries) { country in
                                        HStack(spacing:20) {
                                            HStack {
                                                Text(countryFlag(country.region ?? "DE"))
                                                
                                                Text(countryName(country.region ?? "DE"))
                                                
                                                Spacer()
                                            }
                                            .padding()
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(20)
                                            
                                            ZStack {
                                                Circle()
                                                    .fill(.red)
                                                    .frame(width: 30, height: 30)
                                                
                                                Image(systemName: "trash")
                                                    .font(.callout)
                                            }
                                            .onTapGesture {
                                                viewContext.delete(country)
                                                do {
                                                    try? viewContext.save()
                                                } catch let error {
                                                    print("delete Country: \(error)")
                                                }
                                            }   
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .padding(.vertical)
                            }
                            
                        })
                     },
                     presentation: addCountry ? .infinity : CGFloat((visitedCountries.count * 80) + 100)
                 )
                    
                    
                } else {
                    // none Country
                    /*
                    CalendarDaySheet(
                        button: {
                            
                        }, sheetContent: {
                            AddCountry(date: date.date, theme: theme, List: [])
                        }, presentation: .infinity
                    )
                    */
                    Button(action: {
                        setDate = date.date
                        isPresentingConfirm.toggle()
                    }, label: {
                        VStack(spacing: 5){
                            Circle()
                                .strokeBorder(date.date > Date() ? .white.opacity(0.05) : .white.opacity(0.5), lineWidth: 1)
                                .background(
                                    ZStack{
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .foregroundColor( date.date > Date() ? Color.white.opacity(0.05) : Color.white.opacity(0.1))
                                            
                                        if date.date > Date() {
                                            Text("\(date.day)")
                                               .font(.footnote)
                                               .foregroundColor(.white.opacity(0.3))
                                        } else {
                                            Text("\(date.day)")
                                               .font(.footnote)
                                               .foregroundColor(.white.opacity(0.3))
                                        }
                                    }
                                )
                                .frame(width: screenSize.width / 9, height: screenSize.width / 9 )
                            
                            VStack{
                                Text(date.date > Date() ? "" : "\(date.day)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(calendar.isSameDay(d1: date.date , d2: calendar.currentDate) ? Color.white.opacity(0.1) : Color.white.opacity(0))
                            .cornerRadius(20)
                        }
                        .padding(5)
                    })
                    
                }
                    
            }
        }
        .confirmationDialog("Add new Country?", isPresented: $isPresentingConfirm) {
            if let date = setDate {
                Button {
                    dateSheet = true
                } label: {
                   Text("Add for \( (date.dateFormatte(date: "dd.MM.yy", time: "").date) )?")
                }
                
                Button {
                    dateRangeSheet = true
                } label: {
                   Text("Add Range?")
                }
            }
            
            Button("Cancel", role: .cancel) {
               setDate = nil
            }
        }
        .sheet(isPresented: $dateSheet, onDismiss: {}, content: {
            if let date = setDate {
                AddCountry(date: date, theme: theme, List: [])
            }
        })
        .sheet(isPresented: $dateRangeSheet, onDismiss: {}, content: {
            if let date = setDate {
                AddRangeCountry(date: date, theme: theme, List: [])
            }
        })
        .onTapGesture(perform: {
            calendar.currentDate = date.date
        })
    }
    
    func countryFlag(_ countryCode: String) -> String {
        return String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap {
            UnicodeScalar(127397 + $0.value)
        }))
    }
    
    func countryName(_ countryCode: String) -> String {
        return Locale.current.localizedString(forRegionCode: countryCode) ?? ""
    }
}

struct CalendarControls: View {

    @EnvironmentObject var viewModel: CalendarViewModel
    
    var spacing: CGFloat?
    
    var color: Color?
    
    var font: Font?
    
    init(
        spacing: CGFloat? = 20,
        color: Color? = .white,
        font: Font? = .body
    ) {
        self.spacing = spacing
        self.color = color
        self.font = font
    }
    
    var body: some View {
        HStack(spacing: spacing){
            
            Spacer()
            
            Button(action: {
                viewModel.currentMonth -= 1
            }, label: {
                Image(systemName: "chevron.left")
                    .font(font)
                    .foregroundColor(color)
            })
            
            Text(viewModel.currentDate.dateFormatte(date: "MMMM YYYY", time: "HH:mm").date)
                .foregroundColor(color)
                .font(font)
            
            
            Button(action: {
                viewModel.currentMonth += 1
            }, label: {
                Image(systemName: "chevron.right")
                    .font(font)
                    .foregroundColor(color)
            })
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct AddCalendarDaySheet<Label:View,SheetContent:View>: View {
    @State var isPresentation = false
    
    private var sheetContent: () -> SheetContent
   
    private var button: () -> Label
    
    var presentation: CGFloat
    
    init(@ViewBuilder button: @escaping () -> Label, @ViewBuilder sheetContent: @escaping () -> SheetContent, presentation: CGFloat) {
        self.sheetContent = sheetContent
        self.button = button
        self.presentation = presentation
    }
    
    var body: some View {
        Button(
            action: {
                isPresentation.toggle()
            },
            label: {
                button()
            })
            .sheet(isPresented: $isPresentation, content: {
                sheetContent()
                    .presentationDetents([.height(presentation)])
                    .presentationDragIndicator(.visible)
            })
    }
}

struct CalendarDaySheet<Label:View,SheetContent:View>: View {
    @State var isPresentation = false
    
    private var sheetContent: () -> SheetContent
   
    private var button: () -> Label
    
    var presentation: CGFloat
    
    init(@ViewBuilder button: @escaping () -> Label, @ViewBuilder sheetContent: @escaping () -> SheetContent, presentation: CGFloat) {
        self.sheetContent = sheetContent
        self.button = button
        self.presentation = presentation
    }
    
    var body: some View {
        Button(
            action: {
                isPresentation.toggle()
            },
            label: {
                button()
            })
            .sheet(isPresented: $isPresentation, content: {
                sheetContent()
                    .presentationDetents([.height(presentation)])
                    .presentationDragIndicator(.visible)
            })
    }
}



struct CalendarControls_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            CalendarControls()
                .environmentObject(AppStorageManager())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(ThemeManager())
                .environmentObject(CalendarViewModel())
            
                .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                .colorScheme(.dark)
        }
    }
}

struct CalendarDaySheet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            CalendarDaySheet(button: { Text("Button") }, sheetContent: { Text("Sheet") }, presentation: 200)
                .environmentObject(AppStorageManager())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(ThemeManager())
                .environmentObject(CalendarViewModel())
            
                .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                .colorScheme(.dark)
        }
    }
}

struct Calendar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            CalendarView(control: true, theme: .blue)
                .environmentObject(AppStorageManager())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(ThemeManager())
                .environmentObject(CalendarViewModel())
            
                .defaultAppStorage(UserDefaults(suiteName: "group.FK.Pro-these-")!)
                .colorScheme(.dark)
        }
    }
}
