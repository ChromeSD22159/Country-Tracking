//
//  VersionData.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 04.07.23.
//

import SwiftUI

class ChangeLog {
    var log = [
        VersionItem(
            versionNr: "v1.0.1",
            date: "04.07.2003",
            time: "19:15:00",
            tasks: [
                TaskItem(name: LocalizedStringKey("ChanceLog implemented")),
                TaskItem(name: LocalizedStringKey("Bugfix"))
            ]
        ),
        VersionItem(
            versionNr: "v1.1",
            date: "XXXXXX", // REPLACE BEFORE REVIEW
            time: "XXXXXX", // REPLACE BEFORE REVIEW
            tasks: [
                TaskItem(name: LocalizedStringKey("Countdown feature implemented")) ,
                TaskItem(name: LocalizedStringKey("Small countdown widget")),
                TaskItem(name: LocalizedStringKey("Optimize Responsitivity for iPad, iPhone")),
                TaskItem(name: LocalizedStringKey("Bugfix"))
            ]
        )
    ]
}
