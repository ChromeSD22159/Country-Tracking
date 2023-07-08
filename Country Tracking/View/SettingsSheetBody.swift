//
//  SettingsSheetBody.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 30.06.23.
//

import SwiftUI
import WidgetKit
import StoreKit
import WebKit

struct SettingsSheetBody: View {
    @EnvironmentObject var iconSettings:IconNames
    @EnvironmentObject var appStorage: AppStorageManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    @StateObject var cloudManager = CloudkitManager()
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    @Binding var isSettingsSheet: Bool

    @State private var isPresentWebView = false
     
    @State var link: URL = URL(string: "https://www.frederikkohler.com/country-tracking/datenschutz/")!
    
    @State var orientation = UIDeviceOrientation.unknown
    
    @State var deviceWidth: CGFloat?
    
    var body: some View {
        NavigationStack {
            ZStack(content: {
                currentTheme.backgroundColor.ignoresSafeArea()

                ScrollView(showsIndicators: false, content: {
                    VStack {
                        Header()
                        
                        ViewThatFits(content: {
                            // LANDSCAPE
                            HStack {
                                
                                Spacer()
                                  
                                VStack{
                                    SettingsContent()
                                        .frame(maxWidth: 430)
                                }
                                
                                Spacer()
                            }
                            
                            // PORTRAIT
                            VStack {
                                SettingsContent()
                                    .frame(maxWidth: 430)
                            }
                        })
                    }
                })
                
            })
            
        }
        .tint(theme.theme.text)
        .onAppear {
            orientation = UIDevice.current.orientation
            deviceWidth = UIScreen.main.bounds.size.width
            
        }
        .onRotate { newOrientation, newdeviceWidth  in
            orientation = newOrientation
            deviceWidth = newdeviceWidth
        }
        .sheet(isPresented: $isPresentWebView) {
            WebView(url: link)
                .ignoresSafeArea()
                .presentationDragIndicator(.visible)
        }
    }
    
    func LinkSection(text: LocalizedStringKey, url: String, PresentWebView: Bool) -> some View {
        Section(content: {
            if PresentWebView {
                Button(action: {
                    isPresentWebView = true
                    link = URL(string: url)!
                }, label: {
                    HStack {
                        Text(text)
                            .foregroundColor(currentTheme.text)
                        
                        Spacer()
                    }
                })
            } else {
                HStack {
                    Link(
                        text,
                        destination: URL(string: url)!
                    )
                    .foregroundColor(currentTheme.text)
                    
                    Spacer()
                }
            }
            
            
        })
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
    
    @ViewBuilder
    func Header() -> some View {
        HStack {
            Text("Settings")
                .font(.title3.bold())
                .foregroundColor(currentTheme.text)
            
            Spacer()
            
            
            Button(action: {isSettingsSheet.toggle()}){
                Image(systemName: "xmark")
                    .foregroundColor(currentTheme.text)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func SettingsContent() -> some View {
        VStack(spacing: 20) {
            Section(content: {
                
                HStack {
                    
                    Label(cloudManager.isSignInToiCloud ? LocalizedStringKey("Signed In") : LocalizedStringKey("Not Signed") , systemImage: cloudManager.isSignInToiCloud ? "person.icloud" : "lock.icloud")
                        .foregroundColor(currentTheme.text)
                        .font(.footnote.bold())
                    
                    Spacer()
                    
                    Button(action: {
                        WidgetCenter.shared.reloadAllTimelines()
                    }, label: {
                        Label("Update Widgets", systemImage: "arrow.2.squarepath")
                            .foregroundColor(currentTheme.text)
                            .font(.footnote.bold())
                    })
                }
               
                
                HStack {
                    Text("Theme")
                        .foregroundColor(currentTheme.text)
                    
                    Spacer()
                    
                    Picker("Theme", selection: $appStorage.currentTheme) {
                        
                        ForEach(["black", "blue", "orange", "green"], id: \.self) { theme in
                            Text(LocalizedStringKey(theme)).tag(theme)
                                .foregroundColor(currentTheme.text)
                        }
                    }
                    .foregroundColor(currentTheme.text)
                    .pickerStyle(.segmented)
                    .onReceive([appStorage.currentTheme].publisher.first()){ value in
                        if appStorage.AppIconChange {
                            Task { @MainActor in
                                guard UIApplication.shared.alternateIconName != theme.theme.iconName else {
                                    /// No need to update since we're already using this icon.
                                    return
                                }

                                do {
                                    try await UIApplication.shared.setAlternateIconName(theme.theme.iconName)
                                } catch {
                                    /// We're only logging the error here and not actively handling the app icon failure
                                    /// since it's very unlikely to fail.
                                    print("Updating icon to \(String(describing: theme.theme.iconName)) failed.")

                                    /// Restore previous app icon
                                    //selectedAppIcon = previousAppIcon
                                }
                            }
                        }
                    }
                    .onSubmit {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            })
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            
            
            Section(content: {
                Button(action: {
                    DispatchQueue.main.async {
                        dismiss()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        appStorage.showWidgetSheet.toggle()
                    }
                }, label: {
                    HStack {
                        Text("How to install a Widget?")
                            .foregroundColor(currentTheme.text)
                        
                        Spacer()
                    }
                })
            })
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            Section(content: {
                VStack {
                    HStack {
                        Text("AppIcon change")
                            .foregroundColor(currentTheme.text)
                        
                        Spacer()
                        
                        Toggle("", isOn: $appStorage.AppIconChange)
                    }
                    HStack {
                        Text("Allow AppIcon change with theme color")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
            })
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            Section(content: {
                VStack {
                    HStack {
                        Text("iCloud Auto Sync")
                            .foregroundColor(currentTheme.text)
                        
                        Spacer()
                        
                        Toggle("", isOn: $appStorage.iCloudSync)
                            .disabled(!appStorage.hasPro)
                    }
                    HStack {
                        Text("Pro Feature: Enables automatic syncing and saving with iCloud")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
            })
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            Section(content: {
                Button(action: {
                    requestReview()
                }, label: {
                    HStack {
                        Text("Rate the App")
                            .foregroundColor(currentTheme.text)
                        
                        Spacer()
                    }
                })
            })
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            LinkSection(
                text: LocalizedStringKey("Ask the Developer"),
                url: "https://www.frederikkohler.com/country-tracking/kontakt/",
                PresentWebView: false
            )
            
            LinkSection(
                text: LocalizedStringKey("Terms and Conditions"),
                url: "https://www.frederikkohler.com/country-tracking/nutzungsbedingungen/",
                PresentWebView: true
            )
            
            LinkSection(
                text: LocalizedStringKey("Privacy Policy"),
                url: "https://www.frederikkohler.com/country-tracking/datenschutz/",
                PresentWebView: true
            )
            
            VStack {
                Section(content: {
                    
                    VersionView(theme: theme)
                        .accentColor(currentTheme.accentColor)
                })
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                
                Text("by Frederik Kohler")
                    .font(.caption)
                    .foregroundColor(currentTheme.text.opacity(0.5))
                
                Text("v\(Bundle.main.releaseVersionNumber ?? "r")")
                    .font(.caption)
                    .foregroundColor(currentTheme.text.opacity(0.5))
                
                
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct SettingsSheetBody_Previews: PreviewProvider {
    static var previews: some View {
        
        
        Group {
            SettingsSheetBody(theme: .orange, isSettingsSheet: .constant(true))
                .environmentObject(IconNames())
                .environmentObject(AppStorageManager())
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                .previewDisplayName("ipad landscape")
            
            SettingsSheetBody(theme: .orange, isSettingsSheet: .constant(true))
                .environmentObject(IconNames())
                .environmentObject(AppStorageManager())
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                .previewDisplayName("ipad portrait")
            
            SettingsSheetBody(theme: .orange, isSettingsSheet: .constant(true))
                .environmentObject(IconNames())
                .environmentObject(AppStorageManager())
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max landscape")
            
            SettingsSheetBody(theme: .orange, isSettingsSheet: .constant(true))
                .environmentObject(IconNames())
                .environmentObject(AppStorageManager())
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max portrait")
        }
    }
}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
