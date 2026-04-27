//
//  HinKhar_Restaurants_DirectoryApp.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 27/11/2025.
//

import SwiftUI

@main
struct HinKhar_Restaurants_DirectoryApp: App {
    @StateObject private var auth = AuthViewModel()
    
    @State private var isShowedWelcome = KeychainManager.shared.get("isShowedWelcome") ?? "no"
    
    @StateObject private var toast = ToastManager()
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
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
                .environmentObject(toast)
                .modifier(GlobalToastModifier())
                .environment(\.locale, Locale(identifier: selectedLanguageCode))
                .onAppear {
                    sleep(2)
                }
            
        }
    }
}
