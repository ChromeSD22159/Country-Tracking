//
//  CountdownEntry.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 05.07.23.
//

import SwiftUI
import WidgetKit

struct CountdownEntry: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appStorage: AppStorageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.date, ascending: true)],
        animation: .default)
    private var countdowns: FetchedResults<Countdown>
    
    @State var isCountDownSheet = false
    
    @State var isSettingsSheet = false
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    @State var selectedContdown: Countdown?
    
    @State var toggleListStlye = true
    
    var body: some View {
        ZStack {

            VStack {
                ZStack {
                    VStack {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 10) {
                                
                                if !appStorage.hasPro {
                                    Text("**Free Version:** \(appStorage.CountdownFreeCounter)/\(appStorage.CountdownFreeMaxCounter) Counter")
                                        .padding(.horizontal)
                                }
                                
                                HStack(spacing: 24) {
                                    Button(action: {
                                        withAnimation(.easeInOut) {
                                            toggleListStlye.toggle()
                                        }
                                    }, label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "square.stack.3d.forward.dottedline.fill")
                                                .rotationEffect(.degrees(toggleListStlye ? 0 : 90))
                                                .font(.body)
                                            
                                            Text(toggleListStlye ? "Widget Preview" : "List")
                                                .font(.caption)
                                            
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                    })
                                    
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut) {
                                            appStorage.toggleWidgetSortable.toggle()
                                            WidgetCenter.shared.reloadAllTimelines()
                                        }
                                    }, label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.up.arrow.down")
                                                .rotationEffect(.degrees(appStorage.toggleWidgetSortable ? 0 : 180))
                                                .font(.body)
                                            
                                            Text(appStorage.toggleWidgetSortable ? "Show Next Event" : "Show last added")
                                                .font(.caption)
                                            
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                    })
                                    
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                                
                                if toggleListStlye {
                                    ScrollCountDowns()
                                } else {
                                    ListCountDowns()
                                        .padding(.horizontal)
                                }
                                
                                Button(action: {
                                    // ADD NEW COUNTDOWN
                                    isCountDownSheet.toggle()
                                }, label: {
                                    HStack {
                                        Spacer()
                                        
                                        Label("New Countdown", systemImage: "plus")
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                    }
                                })
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                                
                                .padding(.horizontal)
                            }
                            .font(.body)
                            .padding(.top, 70)
                        }
                    } // Content
                    
                    
                    Header()
                }
            }
            
        }
        .foregroundColor(currentTheme.text)
        .sheet(isPresented: $isCountDownSheet, content: {
            
            CountdownSheet(theme: theme, isCountdownSheet: $isCountDownSheet, selectedCountdown: $selectedContdown)
            
        })
        .sheet(isPresented: $isSettingsSheet, content: {
            
            SettingsSheetBody(theme: theme, isSettingsSheet: $isSettingsSheet)
            
        })
        .onAppear{
            
            if countdowns.count > 0 && appStorage.CountdownFreeCounter == 0 {
                appStorage.CountdownFreeCounter = countdowns.count
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
                    
                    Button(action: { }) {
                        Image(systemName: "square.stack")
                            .font(.title3)
                    }
                    
                }
                .font(.callout)
                .foregroundColor(currentTheme.headerText)
                
                Spacer()
                
                Text("Countdown")
                
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
    func ListCountDowns() -> some View {
        Section{
            
            
            ForEach(countdowns, id: \.id) { countdown in
                Button(action: {
                    self.isCountDownSheet.toggle()
                    self.selectedContdown = countdown
                }, label: {
                    HStack {
                        Text("\(countdown.name ?? "Unknown Name")")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                })
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
        }
    }
    
    func ScrollCountDowns() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if countdowns.count > 0 {
                    ForEach(countdowns.indices, id: \.self) { i in
                        
                        Button(action: {
                            self.isCountDownSheet.toggle()
                            self.selectedContdown = countdowns[i]
                        }, label: {
                            Small_Widget_dynamic_day_counter(theme: theme, name: countdowns[i].name ?? "", date: countdowns[i].date ?? Date(), icon: countdowns[i].icon ?? "", color: countdowns[i].color?.getColor() ?? .orange, bgImage: countdowns[i].bgImage)
                                .shadow(radius: 20)
                        })
                        .padding()
                        .padding(.vertical)
                    }
                } else {
                    
                }
            }
        }
    }
    
}

struct CountdownSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appStorage: AppStorageManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.date, ascending: true)],
        animation: .default)
    private var countdowns: FetchedResults<Countdown>
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    @Binding var isCountdownSheet: Bool

    @Binding var selectedCountdown: Countdown?
    
    @State var name = ""
    @State var color = ""
    @State var date = Date()
    @State var created = Date()
    @State var icon = "airplane.departure"
    @State var bgImage = true
   
    var body: some View {
        ZStack(content: {
            currentTheme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                ScrollView(showsIndicators: false) {
                    
                    HStack {
                        
                        Spacer()
                        
                        
                        Button(action: {
                            isCountdownSheet.toggle()
                            selectedCountdown = nil
                        }){
                            Image(systemName: "xmark")
                                .foregroundColor(currentTheme.text)
                        }
                    }
                    .padding()

                    Small_Widget_dynamic_day_counter(theme: theme, name: name, date: date, icon: icon, color: color.getColor(), bgImage: bgImage)
                        .shadow(radius: 20)
                        .padding(.vertical)
                    
                    Section(content: {
                        HStack {
                            Text("Name:")
                                .foregroundColor(currentTheme.text)
                            
                            Spacer()
                            
                            TextField("", text: $name)
                                .onChange(of: self.name, perform: { value in
                                   if value.count > 13 {
                                       self.name = String(name.prefix(11))
                                  }
                              })
                        }
                    })
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Section(content: {
                        VStack{
                            HStack {
                                Text("Color:")
                                    .foregroundColor(currentTheme.text)
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    ForEach(CountdownColors.allCases, id: \.self) { c in
                                        Circle()
                                            .stroke(color == c.colorString() ? currentTheme.text.opacity(1) : currentTheme.text.opacity(0), lineWidth: 2)
                                            .background(
                                                Circle()
                                                    .fill(c.color())
                                                    .frame(width: 30)
                                            )
                                            .opacity(appStorage.useThemeColorForWidgetBG ? 0.5 : 1)
                                            .frame(width: 30)
                                            .onTapGesture {
                                                if !appStorage.useThemeColorForWidgetBG {
                                                    color = c.colorString()
                                                }
                                            }
                                    }
                                }
                                
                            }
                            
                            HStack {
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Toggle("Theme Color", isOn: $appStorage.useThemeColorForWidgetBG)
                                        .onChange(of: appStorage.useThemeColorForWidgetBG) { state in
                                            WidgetCenter.shared.reloadAllTimelines()
                                        }
                                }
                                
                            }
                            
                        }
                    })
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Section(content: {
                        VStack{
                            HStack {
                                Text("Icon:")
                                    .foregroundColor(currentTheme.text)
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    ForEach(CountdownIcons.allCases, id: \.self) { ic in
                                        
                                        VStack(alignment: .center) {
                                            
                                            if ic.iconString() == "12.square.fill" {
                                                
                                                let d = date.dateFormatte(date: "dd", time: "").date
                                                
                                                Image(systemName: "\(d).square.fill")
                                                    .scaledToFit()
                                                    .padding(5)
                                                    .foregroundColor(.white)
                                            } else {
                                                Image(systemName: ic.iconString())
                                                    .scaledToFit()
                                                    .padding(5)
                                                    .foregroundColor(.white)
                                            }
                                            
                                        }
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(icon == ic.iconString() ? .white.opacity(1) : .white.opacity(0), lineWidth: 1)
                                        )
                                        .onTapGesture {
                                            icon = ic.iconString()
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("Background Image:")
                                    .foregroundColor(currentTheme.text)
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Toggle("", isOn: $bgImage)
                                }
                            }
                        }
                    })
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Section(content: {
                        VStack(content: {
                            
                            HStack {
                                Text("Date:")
                                    .foregroundColor(currentTheme.text)
                                
                                Spacer()
                                
                                DatePicker("", selection: $date, displayedComponents: .date)
                            }
                            
                            HStack {
                                Text("Time:")
                                    .foregroundColor(currentTheme.text)
                                
                                Spacer()
                                
                                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                            }
                            
                        })
                    })
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Section(content: {
                        VStack(content: {
                            
                            HStack {
                                Text("Start Date:")
                                    .foregroundColor(currentTheme.text)
                                
                                Spacer()
                                
                                DatePicker("", selection: $created, displayedComponents: .date)
                            }
                            
                            HStack {
                                Text("Start Time:")
                                    .foregroundColor(currentTheme.text)
                                
                                Spacer()
                                
                                DatePicker("", selection: $created, displayedComponents: .hourAndMinute)
                            }
                          
                            HStack(alignment: .top) {
                                Image(systemName: "info.circle")
                                    .font(.caption2)
                                    .foregroundColor(currentTheme.text.opacity(0.75))
                                
                                Text("The start date is used for calculating the progress in the widgets. By default, the creation date and time is used.")
                                    .font(.caption2)
                                    .foregroundColor(currentTheme.text.opacity(0.75))
                            }
                            
                            Spacer(minLength: 30)
                            
                            HStack {
                                
                                Button(
                                    action: {
                                        selectedCountdown = nil
                                        isCountdownSheet.toggle()
                                    },
                                    label: {
                                        HStack {
                                            Spacer()
                                            Text("Cancel")
                                            Spacer()
                                        }
                                })
                                .padding()
                                .foregroundColor(.primary)
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                                
                                
                                Button(
                                    action: {
                                        
                                        // EDIT
                                        if let countdown = selectedCountdown {
                                            countdown.name = name
                                            countdown.color = color
                                            countdown.date = date
                                            countdown.creadet = created
                                            countdown.icon = icon
                                            countdown.bgImage = bgImage
                                            
                                            do {
                                                try viewContext.save()
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                    self.isCountdownSheet.toggle()
                                                })
                                                
                                                WidgetCenter.shared.reloadAllTimelines()
                                            } catch {
                                                print(error)
                                            }
                                        }
                                        
                                        // GET PREMIUM
                                        if !appStorage.hasPro && appStorage.CountdownFreeCounter > 0  && selectedCountdown == nil {
                                            self.isCountdownSheet = false
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                appStorage.shopSheet.toggle()
                                            })
                                            WidgetCenter.shared.reloadAllTimelines()
                                        }
                                        
                                        // FREE OR PREMIUM
                                        if !appStorage.hasPro && appStorage.CountdownFreeCounter == 0 && selectedCountdown == nil || appStorage.hasPro && selectedCountdown == nil {
                                            let newCountdown = Countdown(context: viewContext)
                                            newCountdown.name = name
                                            newCountdown.color = color
                                            newCountdown.date = date
                                            newCountdown.icon = icon
                                            newCountdown.creadet = created
                                            newCountdown.bgImage = bgImage
                                            
                                            do {
                                                try viewContext.save()
                                                
                                                viewContext.refresh(newCountdown, mergeChanges:true)
                                                
                                                appStorage.CountdownFreeCounter += 1
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                    self.isCountdownSheet.toggle()
                                                })
                                                WidgetCenter.shared.reloadAllTimelines()
                                            } catch {
                                                print("error")
                                            }
                                        }
                                        
                                        
                                    },
                                    label: {
                                        // EDIT
                                        if selectedCountdown != nil {
                                            HStack {
                                                Spacer()
                                                Text("Save")
                                                Spacer()
                                            }
                                        }
                                        
                                        //  GET PREMIUM
                                        if !appStorage.hasPro && appStorage.CountdownFreeCounter > 0  && selectedCountdown == nil {
                                            HStack {
                                                Spacer()
                                                Text("Get Premium")
                                                Spacer()
                                            }
                                        }
                                        
                                        // FREE OR PREMIUM
                                        if !appStorage.hasPro && appStorage.CountdownFreeCounter == 0 && selectedCountdown == nil || appStorage.hasPro && selectedCountdown == nil {
                                            HStack {
                                                Spacer()
                                                Text("Create")
                                                Spacer()
                                            }
                                        }
                                        
                                })
                                .padding()
                                .foregroundColor(.primary)
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                                
                            }
                            
                            if selectedCountdown != nil {
                                Button(
                                    action: {
                                        viewContext.delete(selectedCountdown!)
                                        do {
                                            try viewContext.save()
                                            
                                            selectedCountdown = nil
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                
                                                self.isCountdownSheet = false
                                            })
                                        } catch {
                                            print("error")
                                        }
                                    },
                                    label: {
                                        HStack {
                                            Spacer()
                                            Label("Delete \"\(selectedCountdown?.name ?? "")\"", systemImage: "trash")
                                            Spacer()
                                        }
                                })
                                .foregroundColor(currentTheme.text)
                                .padding(.top)
                            }
                            
                        })
                    })
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
            }
        }) // ZSTACK
        .onAppear {
            if let countdown = selectedCountdown {
                name = countdown.name ?? ""
                color = countdown.color ?? "black"
                date = countdown.date!
                created = countdown.creadet!
                icon = countdown.icon ?? ""
                bgImage = countdown.bgImage
            } else {
                let now = Date()
                var target = Calendar.current.date(byAdding: .day, value: 1, to: now)!
                target = Calendar.current.date(byAdding: .hour, value: 1, to: target)!
                name = "\(countdowns.count + 1). Countdown"
                color = currentTheme.description
                date = target
                icon = "airplane.departure"
                created = now
                bgImage = true
            }
        }
    }
}

struct CountdownEntry_Previews: PreviewProvider {
    static var previews: some View {
        Group {

            ZStack {
                Color.orange.ignoresSafeArea()

                CountdownEntry(theme: .orange)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                    .environmentObject(AppStorageManager())
                    .environmentObject(ThemeManager())
                }
            }
            .previewDisplayName("Default preview")
    
        Small_Widget_dynamic_day_counter(theme: .default, name: "Teneriffa", date: Date(), icon: "airplane.departure", color: .blue, bgImage: true)
                .previewDisplayName("Small Widget")
    }
}




enum CountdownColors: String, CaseIterable {
    
    // Add Colors to string Extention!!!!!!
    
    case black = "black"
    case orange = "orange"
    case blue = "blue"
    case green = "green"
    
    func color() -> Color {
        switch self {
            case .black: return     Color(red: 0/255, green: 0/255, blue: 0/255)
            case .orange: return    Color(red: 215/255, green: 35/255, blue: 0/255)
            case .blue: return      Color(red: 5/255, green: 85/255, blue: 140/255)
            case .green: return     Color(red: 50/255, green: 60/255, blue: 5/255)
        }
    }
    
    func colorString() -> String {
        switch self {
            case .black: return "black"
            case .orange: return "orange"
            case .blue: return "blue"
            case .green: return "green"
        }
    }
}

enum CountdownIcons: String, CaseIterable {
    
    case flying, car, ferry, friends, calendar

    func iconString() -> String {
        switch self {
        case .flying:   return "airplane.departure"
        case .car:      return "car.side.fill"
        case .ferry:    return "ferry.fill"
        case .friends:  return "figure.wave"
        case .calendar: return "12.square.fill"
        }
    }
}

