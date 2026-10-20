//
//  RootView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 17/03/2026.
//
import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var isShowedWelcome = KeychainManager.shared.get(KeychainKeys.isShowedWelcome) ?? "no"
    
    @State private var isLoggedIn = KeychainManager.shared.get(KeychainKeys.isLoggedIn) ?? "no"
    @State private var isShowingNetworkToast = false
    @State private var networkToastID = UUID()
    
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

            if isShowingNetworkToast {
                VStack {
                    Spacer()

                    ToastView(message: NetworkRequestGuard.noInternetMessage) {
                        withAnimation {
                            isShowingNetworkToast = false
                        }
                    }
                    .id(networkToastID)
                    .padding(.bottom, 48)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .onAppear {
            if isLoggedIn == "yes" {
                auth.isAuthenticated = true
            } else {
                auth.isAuthenticated = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .networkConnectionUnavailable)) { _ in
            networkToastID = UUID()
            withAnimation {
                isShowingNetworkToast = true
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
