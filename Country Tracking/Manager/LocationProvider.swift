//
//  LocationManager.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 24.06.23.
//

import Foundation
import CoreLocation

class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {

    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var geocoder: CLGeocoder!
    @Published var currentCountry: String?
    
    override init() {
        
        super.init()
        self.manager.delegate = self
        
        geocoder = CLGeocoder()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
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
}

extension LocationProvider {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
       // _print("didEnterRegion", region)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //_print("didUpdateLocations", locations)
        self.location = locations.first?.coordinate
        
       decodeLocation(locations.first!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //_print("didFailWithError", error)
    }
        
   
    
    func decodeLocation (_ l: CLLocation) {
        geocoder.reverseGeocodeLocation(l, completionHandler: { location, error in
            
            guard let location = location else { return }
            
            for i in location {
                self.currentCountry = i.name ?? "Unknown Country"
            }
        })
    }
    
    func _print(_ string: String, _ item: Any) {
        print("\(string): \(item)")
    }

}

