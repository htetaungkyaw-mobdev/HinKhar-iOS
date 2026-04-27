//
//  RootView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 17/03/2026.
//
import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var toast: ToastManager
    
    @State private var isShowedWelcome = KeychainManager.shared.get("isShowedWelcome") ?? "no"
    
    @State private var isLoggedIn = KeychainManager.shared.get("isLoggedIn") ?? "no"
    
    var body: some View {
        ZStack {
            if isShowedWelcome == "yes" {
                if isLoggedIn == "yes" {
                    CustomTabView()
                        .preferredColorScheme(.light)
                }
                else {
                    LoginView()
                        .preferredColorScheme(.light)
                }
            } else {
                WelcomeScreensView()
                    .preferredColorScheme(.light)
            }
        }
        .onAppear {
            if isLoggedIn == "yes" {
                auth.isAuthenticated = true
            } else {
                auth.isAuthenticated = false
            }
        }
        .onChange(of: isLoggedIn) { newValue in
            auth.isAuthenticated = (newValue == "yes")
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}

