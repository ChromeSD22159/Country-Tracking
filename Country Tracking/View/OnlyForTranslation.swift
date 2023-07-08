//
//  OnlyForTranslation.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 01.07.23.
//

import SwiftUI

struct OnlyForTranslation: View {
    var body: some View {
        VStack {
            Text("Visited Countrys Today")
            Text("Visited Countrys Yesterday")
            
            Text("blue")
            Text("black")
            Text("orange")
            Text("green")
            
            Text("Today")
            Text("Last 7 Days")
            Text("Last 30 Days")
            Text("All Time")
            
        }
    }
}

struct OnlyForTranslation_Previews: PreviewProvider {
    static var previews: some View {
        OnlyForTranslation()
    }
}
