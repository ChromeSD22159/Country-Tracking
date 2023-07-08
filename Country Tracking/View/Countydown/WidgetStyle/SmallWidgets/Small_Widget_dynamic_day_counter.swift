//
//  Small_Widget_dynamic_day_counter.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 05.07.23.
//

import SwiftUI

struct Small_Widget_dynamic_day_counter: View {
    @AppStorage("useThemeColorForWidgetBG", store: UserDefaults(suiteName: "group.fk.countryTracking")) var useThemeColorForWidgetBG = true
    
    var theme: Themes
    
    private var currentTheme: Theme {
        return self.theme.theme
    }
    
    var name: String
    var date: Date
    var icon: String
    var color: Color
    var bgImage: Bool
    var body: some View {
        VStack(alignment: .center, content: {
            ZStack {
                
                if useThemeColorForWidgetBG {
                    Color.black.ignoresSafeArea()
                    LinearGradient(
                        colors: [
                            currentTheme.backgroundColor.opacity(1),
                            currentTheme.backgroundColor.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    Color.black.ignoresSafeArea()
                    LinearGradient(
                        colors: [
                            color.opacity(1),
                            color.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                if bgImage {
                    Image("SmallWidgetTransparent")
                        .resizable()
                        .ignoresSafeArea()
                }
                
                VStack {
                    HStack {
                        Text("\(name)")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    numberOfDaysBetween(date, and: Date() )
                    
                    Spacer()
                    
                    HStack {
                        if icon == "12.square.fill" {
                            
                            let d = date.dateFormatte(date: "dd", time: "").date
                            
                            Image(systemName: "\(d).square.fill")
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: icon)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text(date.dateFormatte(date: "dd.MM.yyyy", time: "").date)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    
                }
                .padding()
                
            }
            .background(.black.opacity(0.9))
            .cornerRadius(20)
            .frame(width: 170, height: 170)
        })
    }
    
    
    func numberOfDaysBetween(_ from: Date, and to: Date) -> some View {
        let calendar = Calendar.current

        let numberOfDays = calendar.dateComponents([.day, .hour, .minute], from: from, to: to)

        if to < from {
            return resultView(days: abs(numberOfDays.day!), hours: abs(numberOfDays.hour!), min: abs(numberOfDays.minute!))
        } else {
            return resultView(days: -numberOfDays.day!, hours: -numberOfDays.hour!, min: -numberOfDays.minute!)
        }
    }
    
    @ViewBuilder
    func resultView(days: Int, hours: Int, min: Int) -> some View {
        
        
        if days != 0 && hours >= 0 {
            HStack(alignment: .lastTextBaseline) {
                Text("\(days)")
                    .foregroundColor(min < 0 || days < 0 ? .white.opacity(0.5) : .white.opacity(1))
                    .font(.system(size: 40, weight: .bold))
                
                Spacer()
                
                Text(days == 1 ? "Day" : "Days")
                    .foregroundColor(min < 0 || days < 0 ? .white.opacity(0.5) : .white.opacity(1))
                    .font(.system(size: 25, weight: .bold))
            }
        } else {
            HStack(alignment: .lastTextBaseline) {
                Text("\(hours):\(min >= 10 || min <= -10 ? String(abs(min)) : "0"+String(abs(min)))")
                    .foregroundColor(min < 0 || days < 0 ? .white.opacity(0.5) : .white.opacity(1))
                    .font(.system(size: 40, weight: .bold))

                Spacer()
                
                Text("h")
                    .foregroundColor(min < 0 || days < 0 ? .white.opacity(0.5) : .white.opacity(1))
                    .font(.system(size: 25, weight: .bold))
            }
        }
    }
}

struct Small_Widget_dynamic_day_counter_Previews: PreviewProvider {
    static var previews: some View {
        Small_Widget_dynamic_day_counter(theme: .default, name: "Teneriffa", date: Date(), icon: "airplane.departure", color: .blue, bgImage: true)
    }
}
