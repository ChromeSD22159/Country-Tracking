//
//  VersionItem.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 08.07.23.
//

import SwiftUI

struct VersionItem: Identifiable {
    var id = UUID()
    var versionNr: String
    var date: String
    var time: String
    var tasks: [TaskItem]
}


struct TaskItem: Identifiable {
    var id = UUID()
    var name: LocalizedStringKey
}
