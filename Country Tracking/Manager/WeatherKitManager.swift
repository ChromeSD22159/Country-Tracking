//
//  WeatherKitManager.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 30.06.23.
//

import Foundation
import WeatherKit

@MainActor class WeatherKitManager: ObservableObject {
    
    @Published var weather: Weather?
    
    
    func getWeather() async {
        do {
            weather = try await Task.detached(priority: .userInitiated) {
                return try await WeatherService.shared.weather(for: .init(latitude: 37.322998, longitude: -122.032181))  // Coordinates for Apple Park just as example coordinates
            }.value
        } catch {
            fatalError("\(error)")
        }
    }
    
    var symbol: String {
        weather?.currentWeather.symbolName ?? "xmark"
    }
    
    var temp: String {
        let temp =
        weather?.currentWeather.temperature
        
        let convert = temp?.converted(to: .fahrenheit).description
        return convert ?? "Loading Weather Data"
        
    }
    
}
