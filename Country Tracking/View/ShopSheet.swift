//
//  ShopSheet.swift
//  Country Tracking
//
//  Created by Frederik Kohler on 01.07.23.
//

import SwiftUI
import StoreKit
import WebKit

struct ShopSheet: View {
    @EnvironmentObject var appStorage: AppStorageManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    @Environment(\.dismiss) private var dismiss
    
    var theme: Themes
    
    var currentTheme: Theme {
        return self.theme.theme
    }
    
    @Binding var shopSheet: Bool
    
    @State private var isPresentWebView = false
     
    @State var link: URL = URL(string: "https://www.frederikkohler.com/country-tracking/datenschutz/")!
    
    @State var orientation = UIDeviceOrientation.unknown
    @State var deviceWidth: CGFloat?
    
    var body: some View {
        ZStack(content: {
            currentTheme.backgroundColor.ignoresSafeArea()
            
            Image("BG_TRANSPARENT")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Header()
                
                ViewThatFits(content: {
                    // LANDSCAPE
                    HStack {
                        
                        Spacer()
                          
                        VStack{
                            sheetContent()
                                .frame(maxWidth: 430)
                        }
                        
                        Spacer()
                    }
                    
                    // PORTRAIT
                    VStack {
                        sheetContent()
                            .frame(maxWidth: 430)
                    }
                })
            }
            
            
            
        })
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
    
    @ViewBuilder
    func Header() -> some View {
        HStack {
            Text("Unlock Country Tracking Pro")
                .font(.title3.bold())
                .foregroundColor(currentTheme.text)
            
            Spacer()
            
            
            Button(action: {shopSheet.toggle()}){
                Image(systemName: "xmark")
                    .foregroundColor(currentTheme.text)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func sheetContent() -> some View {
        VStack(spacing: 20) {
            
            ScrollView(showsIndicators: false) {
                
                ZStack {
                    Image("ProCities")
                        .resizable()
                        .scaledToFill()
                    
                    VStack {
                        Spacer()
                        VStack(spacing: 5) {
                            HStack {
                                Spacer()
                                Image(systemName: "lock.open.fill")
                                    .foregroundColor(currentTheme.accentColor)
                                
                                Text("Show Visited Countries for any numbers of days")
                                    .foregroundColor(currentTheme.text)
                                    .font(.caption)
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                Image(systemName: "lock.open.fill")
                                    .foregroundColor(currentTheme.accentColor)
                                    .font(.title3)
                                
                                Text("Show Visited Cities for any numbers of days")
                                    .foregroundColor(currentTheme.text)
                                    .font(.caption)
                                Spacer()
                            }
                        }
                        .padding(10)
                        .background(.ultraThinMaterial.opacity(0.75))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 449)
                .cornerRadius(20)
                .padding(.vertical, 20)
                
                ForEach(purchaseManager.products.sorted(by: { $0.price < $1.price })) { product in // 12 - Eine Woche
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("\(product.displayName)")
                                .font(.title3.bold())
                            Spacer()
                        }
                        
                        if product.id == "12" {
                            HStack {
                                Text("Only \(product.displayPrice) per month, billed per Month.")
                                
                                Spacer()
                            }
                            
                            Button {
                               Task {
                                   do {
                                       try await purchaseManager.purchase(product)
                                   } catch {
                                       print(error)
                                   }
                               }
                           } label: {
                               Text("\(product.description)")
                                   .foregroundColor(.white)
                           }
                           .frame(maxWidth: .infinity, alignment: .center)
                           .padding()
                           .background(currentTheme.accentColor)
                           .cornerRadius(20)
                            
                            HStack {
                                Text("There are no fees during your trial period. After that, you will pay \(product.displayPrice) per month until you cancel.")
                                    .font(.caption2)
                                
                                Spacer()
                            }
                        }
                        
                        if product.id == "11" {
                            HStack {
                                Text("Only \(product.displayPrice) per year, billed per year.")
                                
                                Spacer()
                            }
                            
                            Button {
                               Task {
                                   do {
                                       try await purchaseManager.purchase(product)
                                   } catch {
                                       print(error)
                                   }
                               }
                           } label: {
                               Text("\(product.description)")
                                   .foregroundColor(.white)
                           }
                           .frame(maxWidth: .infinity, alignment: .center)
                           .padding()
                           .background(currentTheme.accentColor)
                           .cornerRadius(20)
                            
                            HStack {
                                Text("There are no fees during your trial period. After that there is a charge of \(product.displayPrice) per year until cancellation.")
                                    .font(.caption2)
                                
                                Spacer()
                            }
                        }
                        
                        if product.id ==  "20" {
                            HStack {
                                
                                Text("Buy once for \(product.displayPrice) and use all Pro features for life.")
                                
                                Spacer()
                            }
                            
                            Button {
                               Task {
                                   do {
                                       try await purchaseManager.purchase(product)
                                   } catch {
                                       print(error)
                                   }
                               }
                           } label: {
                               Text("\(product.description)")
                                   .foregroundColor(.white)
                           }
                           .frame(maxWidth: .infinity, alignment: .center)
                           .padding()
                           .background(currentTheme.accentColor)
                           .cornerRadius(20)
                        }
                        
                        
                    }
                    .padding()
                    .background(Material.ultraThinMaterial)
                    .cornerRadius(20)
                    
                    
                    
                    /*
                    if product.id == "12" {
                        Button {
                           Task {
                               do {
                                   try await purchaseManager.purchase(product)
                               } catch {
                                   print(error)
                               }
                           }
                       } label: {
                          
                           Text("One week free trial, then \(product ) per month")
                               .foregroundColor(.white)
                       }
                       .frame(maxWidth: .infinity, alignment: .center)
                       .padding()
                       .background(Material.ultraThinMaterial)
                       .cornerRadius(20)
                        
                        //Text("\(product.subscription)")
                    } else {
                        
                    }
                     */
                }
                
                
                Button {
                    Task {
                        do {
                            try await AppStore.sync()
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Restore")
                        .foregroundColor(.white)
                }
                .padding(.top)
                
                HStack {
                    Text("Autom. extension. Cancelable at any time.")
                    .foregroundColor(.white)
                    .font(.caption2)
                    
                }
                
                HStack {
                    Button("Privacy Policy") {
                        // 2
                        isPresentWebView = true
                        link = URL(string: "https://www.frederikkohler.com/country-tracking/datenschutz/")!
                    }
                    .foregroundColor(.white)
                    .font(.caption2)
                    
                    Button("Terms and Conditions") {
                        // 2
                        isPresentWebView = true
                        link = URL(string: "https://www.frederikkohler.com/country-tracking/nutzungsbedingungen/")!
                    }
                    .foregroundColor(.white)
                    .font(.caption2)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ShopSheet_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShopSheet(theme: .blue, shopSheet: .constant(true))
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                .previewDisplayName("ipad landscape")
                .environmentObject(AppStorageManager())
                .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
                .environmentObject(EntitlementManager())
            
            ShopSheet(theme: .blue, shopSheet: .constant(true))
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                .previewDisplayName("ipad portrait")
                .environmentObject(AppStorageManager())
                .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
                .environmentObject(EntitlementManager())
            
            ShopSheet(theme: .blue, shopSheet: .constant(true))
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max landscape")
                .environmentObject(AppStorageManager())
                .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
                .environmentObject(EntitlementManager())
            
            ShopSheet(theme: .blue, shopSheet: .constant(true))
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max portrait")
                .environmentObject(AppStorageManager())
                .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
                .environmentObject(EntitlementManager())
        }
    }
}



struct WebView: UIViewRepresentable {
    // 1
    let url: URL
    // 2
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}



// Our custom view modifier to track rotation and
// call our action



struct DeviceRotationViewModifier: ViewModifier {
    let action: (_ orientation: UIDeviceOrientation, _ width: CGFloat) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation, UIScreen.main.bounds.size.width)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (_ orientation: UIDeviceOrientation, _ width: CGFloat) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
