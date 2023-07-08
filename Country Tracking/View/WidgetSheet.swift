//
//  SettingsSheetBody.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 30.06.23.
//

import SwiftUI
import WidgetKit

struct WidgetSheetBody: View {
    
    @EnvironmentObject var appStorage: AppStorageManager
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    @Binding var isWidgetSheet: Bool
    @State var tabIndex = 0
    @State var text = [
        LocalizedStringKey("Long press on a free space on your homescreen"),
        LocalizedStringKey("Press the + icon in the upper left corner"),
        LocalizedStringKey("Search the list for \"Country Tracking\""),
        LocalizedStringKey("Add one of the widgets to your home screen."),
        LocalizedStringKey("Press the \"Done\" icon in the upper right corner")
    ]
    
    let minDragTranslationForSwipe: CGFloat = 50
    let numTabs = 5
    
    var body: some View {
        ZStack(content: {
            currentTheme.backgroundColor.ignoresSafeArea()
            
            Image("BG_TRANSPARENT")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("How to Add Widgets?")
                        .font(.title3.bold())
                        .foregroundColor(currentTheme.text)
                    
                    Spacer()
                    
                    Button(action: {isWidgetSheet.toggle()}){
                        Image(systemName: "xmark")
                            .foregroundColor(currentTheme.text)
                    }
                }
                .padding()
                .padding(.horizontal)
                
                Text("To automatically enter the countries or places you will visit in the future, you should install one of the widgets.")
                    .font(.callout)
                    .foregroundColor(currentTheme.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.horizontal)
                
                TabView(selection: $tabIndex) {
                    VStack{
                        Image("InstallWidget1")
                            .resizable()
                            .scaledToFit()
                        
                        Button("next step") {
                            withAnimation(.easeInOut(duration: 0.2)){
                                tabIndex += 1
                            }
                        }
                        .textCase(.uppercase)
                        .padding()
                        .background(.ultraThinMaterial)
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                        
                    }
                    .highPriorityGesture(
                        DragGesture()
                            .onEnded({
                                self.handleSwipe(translation: $0.translation.width)
                            })
                    )
                    .tag(0)
                    
                    VStack{
                        Image("InstallWidget2")
                            .resizable()
                            .scaledToFit()
                        
                        Button("next step") {
                            withAnimation(.easeInOut(duration: 0.2)){
                                tabIndex += 1
                            }
                        }
                        .textCase(.uppercase)
                        .padding()
                        .background(.ultraThinMaterial)
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                    }
                    .highPriorityGesture(
                        DragGesture()
                            .onEnded({
                                self.handleSwipe(translation: $0.translation.width)
                            })
                    )
                    .tag(1)
                    
                    VStack{
                        Image("InstallWidget3")
                            .resizable()
                            .scaledToFit()
                        
                        Button("next step") {
                            withAnimation(.easeInOut(duration: 0.2)){
                                tabIndex += 1
                            }
                        }
                        .textCase(.uppercase)
                        .padding()
                        .background(.ultraThinMaterial)
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                        
                    }
                    .highPriorityGesture(
                        DragGesture()
                            .onEnded({
                                self.handleSwipe(translation: $0.translation.width)
                            })
                    )
                    .tag(2)
                    
                    VStack{
                        Image("InstallWidget4")
                            .resizable()
                            .scaledToFit()
                        
                        Button("next step") {
                            withAnimation(.easeInOut(duration: 0.2)){
                                tabIndex += 1
                            }
                        }
                        .textCase(.uppercase)
                        .padding()
                        .background(.ultraThinMaterial)
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                        
                    }
                    .highPriorityGesture(
                        DragGesture()
                            .onEnded({
                                self.handleSwipe(translation: $0.translation.width)
                            })
                    )
                    .tag(3)
                    
                    VStack{
                        Image("InstallWidget5")
                            .resizable()
                            .scaledToFit()
                        
                        Button("done!") {
                            withAnimation(.easeInOut(duration: 0.2)){
                                isWidgetSheet = false
                            }
                        }
                        .textCase(.uppercase)
                        .padding()
                        .background(.ultraThinMaterial)
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                        
                    }
                    .highPriorityGesture(
                        DragGesture()
                            .onEnded({
                                self.handleSwipe(translation: $0.translation.width)
                            })
                    )
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                
                Text(text[tabIndex])
                    .foregroundColor(currentTheme.text)
                
                Spacer()
            } 
        })
    }
    
    private func handleSwipe(translation: CGFloat) {
        if translation > minDragTranslationForSwipe && tabIndex > 0 {
            withAnimation(.easeInOut(duration: 0.2)){
                tabIndex -= 1
            }
        } else  if translation < -minDragTranslationForSwipe && tabIndex < numTabs-1 {
            withAnimation(.easeInOut(duration: 0.2)){
                tabIndex += 1
            }
        }
    }
}

struct WidgetSheetBody_Previews: PreviewProvider {
    static var previews: some View {
        WidgetSheetBody(theme: .blue, isWidgetSheet: .constant(true))
            .environmentObject(AppStorageManager())
    }
}
