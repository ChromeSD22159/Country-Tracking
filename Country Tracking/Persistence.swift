//
//  Persistence.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 24.06.23.
//

import CoreData
import Foundation
import CloudKit
import SwiftUI

struct PersistenceController {
    @AppStorage("iCloudSync") var iCloudSync = false
    
    @AppStorage("hasPro", store: UserDefaults(suiteName: "group.fk.countryTracking")) var hasPro: Bool = false
    
    static let shared = PersistenceController()
    
    static var countries: [(country: String, region: String)] = [
        (country: "Spain", region: "ES"),
        (country: "Germany", region: "DE"),
        (country: "Swiss", region: "CH"),
        (country: "France", region: "FR"),
        (country: "Korea", region: "JPN"),
        (country: "Japan", region: "KOR"),
        (country: "Canada", region: "ES"),
        (country: "Usa", region: "US"),
        (country: "Austria", region: "AT"),
        (country: "Greece", region: "GR"),
        (country: "China", region: "CN")
    ]
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        
        let viewContext = result.container.viewContext
        
        for _ in 0..<20 {
            let newVisitedCountry = VisitedCountry(context: viewContext)
            newVisitedCountry.date = Calendar.current.date(byAdding: .day, value: Int.random(in: 0...30), to: Date())!
            newVisitedCountry.region = countries[Int.random(in: 0...10)].region
            newVisitedCountry.name = countries[Int.random(in: 0...10)].country
            
            let newCountries = Countries(context: viewContext)
            newCountries.date = Calendar.current.date(byAdding: .day, value: Int.random(in: 0...30), to: Date())!
            newCountries.region = countries[Int.random(in: 0...10)].region
        }
        
        for i in 0..<2 {
            
            let date = Date()
            
            let newCountdown = Countdown(context: viewContext)
            newCountdown.name = "Countdown \(i)"
            newCountdown.date = Calendar.current.date(byAdding: .day, value: 5, to: date)!
            newCountdown.creadet =  Calendar.current.date(byAdding: .day, value: -4, to: date)!
            newCountdown.color = "blue"
            newCountdown.icon = "countdown_icon_plane"
            newCountdown.creadet = date
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()

    let container = NSPersistentCloudKitContainer(name: "Country_Tracking")
    
    let iCloudIdentfier = "iCloud.countryTracking"
    
    let appGroupIdenfier = "group.countryTracking"
    
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Create a store description for a local store
        let localStoreLocation = URL.storeURL(for: appGroupIdenfier, databaseName: "Local")
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreLocation)
        localStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        localStoreDescription.configuration = "Local"

        if hasPro && iCloudSync {
            localStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: iCloudIdentfier)
        } else {
            localStoreDescription.cloudKitContainerOptions = nil
        }
        
        // Create a store description for a CloudKit-backed local store
        let cloudStoreLocation = URL.storeURL(for: appGroupIdenfier, databaseName: "cloud")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"


        // Set the container options on the cloud store
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: iCloudIdentfier)
        
        try? container.viewContext.setQueryGenerationFrom(.current)
        
         //   container.viewContext.refreshAllObjects()
    
        // Update the container's list of store descriptions
        container.persistentStoreDescriptions = [
            localStoreDescription
            //cloudStoreDescription
        ]
        
        // Load both stores
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
    }
}

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

/* BACKUP
 
 struct PersistenceController {
     static let shared = PersistenceController()
     
     static var countries: [(country: String, region: String)] = [
         (country: "Spain", region: "ES"),
         (country: "Germany", region: "DE"),
         (country: "Swiss", region: "CH"),
         (country: "France", region: "FR"),
         (country: "Korea", region: "JPN"),
         (country: "Japan", region: "KOR"),
         (country: "Canada", region: "ES"),
         (country: "Usa", region: "US"),
         (country: "Austria", region: "AT"),
         (country: "Greece", region: "GR"),
         (country: "China", region: "CN")
     ]
     
     static var preview: PersistenceController = {
         let result = PersistenceController(inMemory: true)
         
         let viewContext = result.container.viewContext
         
         for _ in 0..<20 {
             let newVisitedCountry = VisitedCountry(context: viewContext)
             newVisitedCountry.date = Calendar.current.date(byAdding: .day, value: Int.random(in: 0...30), to: Date())!
             newVisitedCountry.region = countries[Int.random(in: 0...10)].region
             newVisitedCountry.name = countries[Int.random(in: 0...10)].country
             
             let newCountries = Countries(context: viewContext)
             newCountries.date = Calendar.current.date(byAdding: .day, value: Int.random(in: 0...30), to: Date())!
             newCountries.region = countries[Int.random(in: 0...10)].region
         }
         
         for i in 0..<2 {
             
             let date = Date()
             
             let newCountdown = Countdown(context: viewContext)
             newCountdown.name = "Countdown \(i)"
             newCountdown.date = Calendar.current.date(byAdding: .day, value: 5, to: date)!
             newCountdown.creadet =  Calendar.current.date(byAdding: .day, value: -4, to: date)!
             newCountdown.color = "blue"
             newCountdown.icon = "countdown_icon_plane"
             newCountdown.creadet = date
         }
         
         do {
             try viewContext.save()
         } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             let nsError = error as NSError
             fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
         }
         
         return result
     }()

     let container: NSPersistentCloudKitContainer
     
     init(inMemory: Bool = false) {
         container = NSPersistentCloudKitContainer(name: "Country_Tracking")

         let storeURL = URL.storeURL(for: "group.countryTracking", databaseName: "Country_Trackingˆ")
         let storeDescription = NSPersistentStoreDescription(url: storeURL)
         container.persistentStoreDescriptions = [storeDescription]
         
         if inMemory {
             container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
         }
    
         container.loadPersistentStores(completionHandler: { (storeDescription, error) in
             if let error = error as NSError? {
                 fatalError("Unresolved error \(error), \(error.userInfo)")
             }
         })
         
         //container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
         container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
         container.viewContext.automaticallyMergesChangesFromParent = true
  
     }
 }

 public extension URL {
     /// Returns a URL for the given app group and database pointing to the sqlite database.
     static func storeURL(for appGroup: String, databaseName: String) -> URL {
         guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
             fatalError("Shared file container could not be created.")
         }

         return fileContainer.appendingPathComponent("\(databaseName).sqlite")
     }
 }
 */
