//
//  AddCountry.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 27.06.23.
//

import SwiftUI
import WidgetKit

struct AddRangeCountry: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone
    
    var date:Date
    
    var theme: Themes
    
    var List: [String]
    
    private var currentTheme: Theme {
        return self.theme.theme
    }
    
    #if targetEnvironment(simulator)
    @State var selectedCountries: [String] = ["DE"]
    #else
    @State var selectedCountries: [String] = []
    #endif
    
    @State var filteredCountries: [String] = []
    
    @State var searchCountry = ""
    
    @State var dateRange: Set<DateComponents> = []
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedCountry.region, ascending: true)],
        animation: .default)
    var countries: FetchedResults<Countries>
    
    
    var body: some View {
        ZStack(content: {
            currentTheme.backgroundColor.ignoresSafeArea()
            
            Image(currentTheme.BackgroundImage)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    
                    Button(action: {
                        selectedCountries.removeAll(keepingCapacity: true)
                        dismiss()
                    }, label: {
                        Text("Cancel")
                            .foregroundColor(currentTheme.text)
                    })
                    .padding()
                    .background(.ultraThinMaterial.opacity(1))
                    .cornerRadius(10)
                    
                    Spacer()   .foregroundColor(currentTheme.text)
                    
                    Text("Set for \(dateRange.count) Days")
                        .foregroundColor(currentTheme.text)
                    
                    Spacer()
                    
                    Button(action: {
                        addCountries(countries: selectedCountries, dates: dateRange)
                    }, label: {
                        Text("Save")
                            .foregroundColor(currentTheme.text)
                    })
                    .padding()
                    .background(isSelection() ? Material.ultraThinMaterial.opacity(0.3) : Material.ultraThinMaterial.opacity(1))
                    .cornerRadius(10)
                    .disabled(isSelection() ? true : false)
                }
                .padding()
                
                HStack {
                    MultiDatePicker("Dates Available", selection: $dateRange)
                        .pickerStyle(.segmented)
                        .tint(.orange)
                        .labelsHidden()
                        .background(currentTheme.backgroundColor.gradient, in: RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                
                ScrollView {
                    // SelectedList
                    if selectedCountries.count != 0 {
                        HStack {
                            Text("Selected Countries")
                            Spacer()
                        }
                        .padding(.horizontal)
                        .font(.footnote.bold())
                        .foregroundColor(currentTheme.text)
                        
                        ForEach(selectedCountries, id: \.self) { countryCode in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCountries = countryCode.removeFromSelection(selectedCountries)
                                    filteredCountries = filter("")
                                }
                            }, label: {
                                HStack {
                                    Text(countryCode.countryFlag())
                                    Text(countryCode.countryName())
                                    Spacer()
                                    Text(countryCode)
                                }
                                .foregroundColor(currentTheme.text)
                            })
                            .padding()
                            .background(Material.ultraThinMaterial)
                            .cornerRadius(10)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        }
                        .padding(.horizontal)
                        .foregroundColor(currentTheme.text)
                    }
                    
                    // MARK: - TextField
                    HStack {
                        TextField("Search Country", text: $searchCountry)
                            .foregroundColor(searchCountry.count == 0 ? currentTheme.text.opacity(0.3) : currentTheme.text.opacity(1))
                        .onChange(of: searchCountry, perform: { newSearchText in
                            filteredCountries = filter(newSearchText.uppercased())
                        })
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(currentTheme.text, lineWidth: 1)
                    )
                    .padding()
                    .padding(.horizontal)
                    
                    
                    // MARK: - Country List
                    HStack {
                        Text("All Countries")
                        Spacer()
                    }
                    .padding(.horizontal)
                    .font(.footnote.bold())
                    .foregroundColor(currentTheme.text)
                    
                    ForEach(filteredCountries, id: \.self) { countryCode in
                            
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCountries.append(countryCode)
                                filteredCountries = filteredCountries.filter({ return $0 != countryCode })
                                searchCountry = ""
                            }
                        }, label: {
                            HStack {
                                Text(countryCode.countryFlag())
                                Text(countryCode.countryName())
                                Spacer()
                                Text(countryCode)
                            }
                            .foregroundColor(currentTheme.text)
                        })
                        .padding()
                        .background(Material.ultraThinMaterial)
                        .cornerRadius(10)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    }
                    .padding(.horizontal)
                    .foregroundColor(currentTheme.text)
                    
                    Spacer()
                }
            }
            .onAppear{
                filteredCountries = NSLocale.isoCountryCodes
                
                if List.count == 0 {
                    filteredCountries = NSLocale.isoCountryCodes
                } else {
                    List.map { countryCode in
                        
                        print(countryCode)
                        filteredCountries = filteredCountries.filter({ $0 != countryCode })
                    }
                }
               
            }
        })
        
    }
    
    func isSelection() -> Bool {
        if self.selectedCountries.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func filter(_ input: String) -> [String] {
        let list = NSLocale.isoCountryCodes
        if input.count == 0 {
            return list
        } else {
            return list.filter{ Locale.current.localizedString(forRegionCode: $0)!.uppercased().contains(input) }
        }
    }

    private func addCountries(countries: [String], dates: Set<DateComponents>) {
        
        for day in dates {
            for country in countries {
                let newCountry = VisitedCountry(context: viewContext)
                newCountry.date = Calendar.current.date(from: day) 
                newCountry.name = country.countryName()
                newCountry.region = country
                
                CheckVisitedCountryList(region: country)
                
                do {
                    try viewContext.save()
                    dismiss()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func CheckVisitedCountryList(region: String) {
        let countryList = countries.filter { country in
            country.region == region
        }
        
        if countryList.count == 0 {
            print("\(region) add Country to CountryList")
            addCountryAllCountries(region: region)
        } else {
            print("\(region.countryName()) already exist in CountryList")
        }
    }
    
    private func addCountryAllCountries(region: String) {
        
        let newCountry = Countries(context: viewContext)
        newCountry.date = Date()
        newCountry.region = region
        
        do {
            try viewContext.save()
            
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct AddRangeCountry_Previews: PreviewProvider {
    static var previews: some View {
        AddRangeCountry(date: Date(), theme: .blue, List: [])
    }
}
