//
//  HinKhar_Restaurants_DirectoryApp.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 27/11/2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct HinKhar_Restaurants_DirectoryApp: App {
    @StateObject private var auth = AuthViewModel()
    
    @State private var isShowedWelcome = KeychainManager.shared.get(KeychainKeys.isShowedWelcome) ?? "no"
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
//            ZStack {
//                if isShowedWelcome == "yes" {
//                    LoginView()
//                        .environmentObject(auth)
//                        .preferredColorScheme(.light)
//                }
//                else {
//                    WelcomeScreensView()
//                        .preferredColorScheme(.light)
//                }
//                
//                if toast.isShowing {
//                    VStack {
//                        Spacer()
//                        ToastView(message: toast.message)
//                    }
//                    .transition(.move(edge: .bottom))
//                    .zIndex(1)
//                }
//            }
//            .environmentObject(toast)
            
            RootView()
                .environmentObject(auth)
                .environment(\.locale, Locale(identifier: selectedLanguageCode))
                .onAppear {
                    sleep(2)
                }
            
        }
    }
}
