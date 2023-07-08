//
//  LocationManager.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 24.06.23.
//

import Foundation
import CoreLocation
import WidgetKit
import CoreData

class LocationWidgetProvider: NSObject, ObservableObject, CLLocationManagerDelegate {

    let manager: CLLocationManager?
    
    @Published var location: CLLocation?
    @Published var geocoder: CLGeocoder!
    @Published var currentCountry: String?
    @Published var currentCity: String?
    @Published var countryData: Country?
    
    override init() {
        manager = CLLocationManager()
        super.init()
        self.manager!.delegate = self
        manager!.requestLocation()
        manager!.desiredAccuracy = kCLLocationAccuracyBest;
        manager!.distanceFilter = 50;
        geocoder = CLGeocoder()
    }
    
    func requestLocation() {
        manager!.requestLocation()
        manager!.requestAlwaysAuthorization()
    }
    
    func StartLocation() {
        manager!.startMonitoringSignificantLocationChanges()
    }

    func StopLocation() {
        manager!.startMonitoringSignificantLocationChanges()
    }
    
    func fetchCountriesfromCoreData(_ date: Date, complition: @escaping ([VisitedCountry]) -> Void ) {
        let viewContext = PersistenceController.shared.container.viewContext
        
        let request = NSFetchRequest<VisitedCountry>(entityName: "VisitedCountry")
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        
        var endDate: Date {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            return Calendar(identifier: .gregorian).date(byAdding: components, to: startDate)!
        }

        let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", startDate as CVarArg, endDate as CVarArg);
        request.predicate = predicate
        
        do {
           let data = try viewContext.fetch(request)
            complition(data)
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
        
    }
    
    func createNewCountry(country: String, region: String){
        let viewContext = PersistenceController.shared.container.viewContext
        
        let newCounty = VisitedCountry(context: viewContext)
        newCounty.name = country
        newCounty.date = Date()
        newCounty.region = region
        
        do {
            try? viewContext.save()
            print("saved: \(newCounty)")
            WidgetCenter.shared.reloadAllTimelines()
        } 
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _print("didUpdateLocations", locations)
        
        self.location = locations.first
        
        // when the widget get new location
        
        geocoder.reverseGeocodeLocation(locations.first!, completionHandler: { [self] location, error in
            
            guard let location = location else { return }
            
            self.currentCountry = location.first?.country
            
            self.fetchCountriesfromCoreData(Date(), complition: { data in

                let result = data.filter { return $0.region! == location.first?.isoCountryCode! }.count // entry.region! == location.first?.country!
                
                
                // save only if theres no entry for today
                if result == 0 {
                  //  self.createNewCountry(country: (location.first?.country!)!, region: (location.first?.isoCountryCode!)!)
                }
                 
                
                
            })

        })
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        _print("didEnterRegion", region)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       _print("didFailWithError", error)
    }
    
    func locationManager(_manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func decodeLocation (_ l: CLLocation, completion: @escaping (_ city: String, _ country: String, _ region: String, _ latitude: Double, _ longitude: Double) -> Void) {
         geocoder.reverseGeocodeLocation(l, completionHandler: { location, error in
            
            guard let location = location else { return }
             
             completion( location.first!.country!, location.first!.locality!, location.first!.isoCountryCode! , Double(l.coordinate.latitude) ,Double(l.coordinate.longitude))
            
        })
    }

    func _print(_ string: String, _ item: Any) {
        print("\(string): \(item)")
    }

}

struct Country: Identifiable{
    let id = UUID()

    let name: Name?
    let tld: [String]?
    let cca2, ccn3, cca3, cioc: String?
    let independent: Bool?
    let status: Status?
    let unMember: Bool?
    let currencies: Currencies?
    let idd: Idd?
    let capital, altSpellings: [String]?
    let region: Region?
    let subregion: String?
    let languages: [String: String]?
    let translations: [String: Translation]?
    let latlng: [Double]?
    let landlocked: Bool?
    let area: Double?
    let demonyms: Demonyms?
    let flag: String?
    let maps: Maps?
    let population: Int?
    let fifa: String?
    let car: Car?
    let timezones: [String]?
    let continents: [Continent]?
    let flags, coatOfArms: ImageType?
    let startOfWeek: StartOfWeek?
    let capitalInfo: CapitalInfo?
    let postalCode: PostalCode?
    let borders: [String]?
    let gini: [String: Double]?
    
    init(_ countriesResponseElement: CountriesResponseElement) {
        self.name = countriesResponseElement.name
        self.tld = countriesResponseElement.tld
        self.cca2 = countriesResponseElement.cca2
        self.ccn3 = countriesResponseElement.ccn3
        self.cca3 = countriesResponseElement.cca3
        self.cioc = countriesResponseElement.cioc
        self.independent = countriesResponseElement.independent
        self.status = countriesResponseElement.status
        self.unMember = countriesResponseElement.unMember
        self.currencies = countriesResponseElement.currencies
        self.idd = countriesResponseElement.idd
        self.capital  = countriesResponseElement.capital
        self.altSpellings = countriesResponseElement.altSpellings
        self.region = countriesResponseElement.region
        self.subregion = countriesResponseElement.subregion
        self.languages = countriesResponseElement.languages
        self.translations = countriesResponseElement.translations
        self.latlng = countriesResponseElement.latlng
        self.landlocked = countriesResponseElement.landlocked
        self.area = countriesResponseElement.area
        self.demonyms = countriesResponseElement.demonyms
        self.flag = countriesResponseElement.flag
        self.maps = countriesResponseElement.maps
        self.population = countriesResponseElement.population
        self.fifa = countriesResponseElement.fifa
        self.car = countriesResponseElement.car
        self.timezones = countriesResponseElement.timezones
        self.continents = countriesResponseElement.continents
        self.flags = countriesResponseElement.flags
        self.coatOfArms = countriesResponseElement.coatOfArms
        self.startOfWeek = countriesResponseElement.startOfWeek
        self.capitalInfo = countriesResponseElement.capitalInfo
        self.postalCode = countriesResponseElement.postalCode
        self.borders = countriesResponseElement.borders
        self.gini = countriesResponseElement.gini
    }
    
    
    init() {
        self.name = nil
        self.tld = nil
        self.cca2 = ""
        self.ccn3 = ""
        self.cca3 = ""
        self.cioc = ""
        self.independent = nil
        self.status = nil
        self.unMember = nil
        self.currencies = nil
        self.idd = nil
        self.capital  = nil
        self.altSpellings = nil
        self.region = nil
        self.subregion = ""
        self.languages = nil
        self.translations = nil
        self.latlng = nil
        self.landlocked = nil
        self.area = nil
        self.demonyms = nil
        self.flag = ""
        self.maps = nil
        self.population = nil
        self.fifa = ""
        self.car = nil
        self.timezones = nil
        self.continents = nil
        self.flags = nil
        self.coatOfArms = nil
        self.startOfWeek = nil
        self.capitalInfo = nil
        self.postalCode = nil
        self.borders = nil
        self.gini = nil
    }
}
