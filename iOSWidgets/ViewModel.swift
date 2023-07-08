//
//  ViewModel.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 25.06.23.
//

import SwiftUI
import CoreData
import WidgetKit

class ViewModel: ObservableObject {
    
    
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
}
