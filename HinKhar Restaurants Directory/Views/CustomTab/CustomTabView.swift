//
//  CustomTabView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//

import SwiftUI

struct CustomTabView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var selectedTab: TabItem = .home
    @State private var previousTab: TabItem = .home
    @State private var showLogin: Bool = false
    
    @State private var isTabBarHidden: Bool = false
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
//    @State private var isLoggedIn = KeychainManager.shared.get(KeychainKeys.isLoggedIn) ?? "no"
    
    // Computed property
    
    init(selectedTab: TabItem = .home) {
          _selectedTab = State(initialValue: selectedTab)
      }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Main Content
            Group {
                switch selectedTab {
                case .home: HomeView(isTabBarHidden: $isTabBarHidden)
                case .promotion: PromotionsView(isTabBarHidden: $isTabBarHidden)
                case .restaurant: RestaurantsView(isTabBarHidden: $isTabBarHidden)
                case .profile: ProfileView(isTabBarHidden: $isTabBarHidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
                .opacity(isTabBarHidden ? 0 : 1)
                .animation(.default, value: isTabBarHidden)
                .id(selectedLanguageCode)
        }
//        .environment(\.locale, Locale(identifier: selectedLanguageCode))
//        .id(selectedLanguageCode)
//        // 1. Listen for tab changes
                .onChange(of: selectedTab) { newValue in
//                    if newValue == .profile {
//                            if !auth.isAuthenticated {
//                                // 1. Show the login overlay
//                                showLogin = true
//                                
//                                // 2. Roll back the selection to the previous tab
//                                // so the background view doesn't change to Profile
//                                selectedTab = previousTab
//                            } else {
//                                // User is logged in, allow the change and update previous
//                                previousTab = newValue
//                            }
//                        } else {
//                            // User is navigating to Home, Restaurant, etc.
//                            // Update previousTab so we know where to return to later
//                            previousTab = newValue
//                        }
                    print("CustomTabView onChange selectedTab:", newValue)
                    if newValue == .profile && !auth.isAuthenticated {
                        showLogin = true
                    }
                }
        // Show Login on top of EVERYTHING
                .fullScreenCover(isPresented: $showLogin) {
                    LoginView()
                }
        .onAppear {
            print("CustomTabView onAppear selectedTab:", selectedTab)
            print("CustomTabView onAppear isAuthenticated:", auth.isAuthenticated)
            let isLoggedIn = KeychainManager.shared.get(KeychainKeys.isLoggedIn) ?? "no"
            auth.isAuthenticated = (isLoggedIn == "yes")
            print("CustomTabView onAppear isLoggedIn:", isLoggedIn)
            print("CustomTabView onAppear isAuthenticated>>>2:", auth.isAuthenticated)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    CustomTabView(selectedTab: .home)
        .environmentObject(AuthViewModel())
}
