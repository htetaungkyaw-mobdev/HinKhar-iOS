//
//  WelcomeScreensView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 10/02/2026.
//

import Foundation
import SwiftUI

struct FullscreenImageView: View {
    var imageName: String
    
    var body: some View {
        GeometryReader { proxy in
            Image(imageName)
                .resizable()
//                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
        }
    }
}

struct PageIndicatorView: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct WelcomeScreensView: View {
    @State private var currentPage = 0
    @State private var isIntroduction = true
    
    let pages: [AnyView] = [
        AnyView(FullscreenImageView(imageName: "WelcomeScreen1")),
        AnyView(FullscreenImageView(imageName: "WelcomeScreen2")),
        AnyView(FullscreenImageView(imageName: "WelcomeScreen3")),
        AnyView(FullscreenImageView(imageName: "WelcomeScreen4")),
        AnyView(FullscreenImageView(imageName: "WelcomeScreen5"))
    ]
    
    var body: some View {
        if isIntroduction {
            ZStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pages[index]
                            .tag(index)
                            .ignoresSafeArea()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                VStack {
                    HStack {
                        Spacer()
                        if currentPage != pages.count - 1 {
                            Button("Skip") {
                                goToLogin()
                            }
                            .font(.custom("Futura-Medium", size: 18.0))
                            .buttonStyle(.plain)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                        }
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Spacer()
                            PageIndicatorView(numberOfPages: pages.count,
                                              currentPage: currentPage)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                        
                        if currentPage == pages.count - 1 {
                            Button(action: {
                                goToLogin()
                            }) {
                                Text("Get Started")
                                    .font(.custom("SukhumvitSet-Bold", size: 16.0))
                                    .foregroundColor(Color("PrimaryColor"))
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .ignoresSafeArea()
                }
            }
            .ignoresSafeArea()
        } else {
            LoginView()
        }
    }
    
    func goToLogin() {
        isIntroduction = false
        KeychainManager.shared.save("yes", forKey: KeychainKeys.isShowedWelcome)
    }
}

#Preview {
    WelcomeScreensView()
}
