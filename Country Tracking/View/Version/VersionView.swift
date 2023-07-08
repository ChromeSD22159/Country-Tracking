//
//  VersionView.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 04.07.23.
//

import SwiftUI

struct VersionView: View {
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    var body: some View {
        NavigationLink(destination: {
            ZStack {
                
                currentTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    ForEach(ChangeLog().log, id: \.versionNr) { item in
                        Section(content: {
                            VStack(spacing: 10, content: {
                                HStack {
                                    Text(LocalizedStringKey(item.versionNr))
                                        .font(.body.bold())
                                        .foregroundColor(currentTheme.text)
                                    Spacer()
                                    Text(item.date)
                                        .font(.body.bold())
                                        .foregroundColor(currentTheme.text)
                                }
                                
                                ForEach(item.tasks, id: \.self) { task in
                                    HStack {
                                        Text(LocalizedStringKey("- \( task )")  )
                                            .foregroundColor(currentTheme.text)
                                        Spacer()
                                    }
                                }
                                
                            })
                        })
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                    
                    
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }) {
            HStack {
                Text("ChangeLog")
                    .foregroundColor(currentTheme.text)

                Spacer()
            }
        }
    }
    
    
}

struct VersionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            
            Color.red.ignoresSafeArea()
            
            VersionView(theme: .orange)
        }
    }
}

struct VersionItem {
    var id = UUID()
    var versionNr: String
    var date: String
    var time: String
    var tasks: [String]
}
