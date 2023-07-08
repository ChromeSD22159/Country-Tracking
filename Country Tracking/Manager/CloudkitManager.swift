//
//  CloudkitManager.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 06.07.23.
//

import SwiftUI
import CloudKit

class CloudkitManager: ObservableObject {
    
    init (){
        getCloudStatus()
        fetchCloudUserRecordID()
    }
    
    @Published var isSignInToiCloud = false
    @Published var error:String?
    @Published var userName:String?
    
    func getCloudStatus() {
        CKContainer.default().accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isSignInToiCloud = true
                case .couldNotDetermine:
                    self?.error = CloudKitError.iCLoudAccountNotDetermined.rawValue
                case .restricted:
                    self?.error = CloudKitError.iCLoudAccountRestricted.rawValue
                case .noAccount:
                    self?.error = CloudKitError.iCLoudAccountNotFound.rawValue
                case .temporarilyUnavailable:
                    self?.error = CloudKitError.iCLoudTemporarilyUnavailable.rawValue
                @unknown default:
                    self?.error = CloudKitError.iCLoudAccountUnknown.rawValue
                }
            }
        }
    }
 
    func fetchCloudUserRecordID(){
        CKContainer(identifier: "iCloud.countryTracking").fetchUserRecordID { [weak self] id, error in
                if let userID = id {
                    self?.discoverCloudUser(id: userID)
                } else {
                    print(error?.localizedDescription as Any)
                }
        }
    }
    
    func discoverCloudUser(id: CKRecord.ID) {
        CKContainer(identifier: "iCloud.countryTracking").discoverUserIdentity(withUserRecordID: id) { [weak self] identifiy, error in
            DispatchQueue.main.async {
                if let name = identifiy?.nameComponents?.givenName {
                    self?.userName = name
                } else {
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }
    
    enum CloudKitError: String ,LocalizedError {
        case iCLoudAccountNotFound, iCLoudAccountNotDetermined, iCLoudAccountRestricted, iCLoudAccountUnknown, iCLoudTemporarilyUnavailable
    }
}

struct CloudkitView: View {
    @StateObject var cloudManager = CloudkitManager()
    var body: some View {
        VStack {
            Text(LocalizedStringKey("Signed in: \(cloudManager.isSignInToiCloud.description.uppercased())"))
        }
    }
}

struct CloudkitView_Previews: PreviewProvider {
    static var previews: some View {
        CloudkitView()
    }
}
