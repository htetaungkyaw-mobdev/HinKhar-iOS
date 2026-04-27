//
//  TabBarView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        
        // 1.
        TabView {
            Tab(String(localized: "home"), systemImage: "house") {
                ContentView()
            }
            Tab(String(localized: "alerts"), systemImage: "bell") {
                ContentView()
            }
            Tab(String(localized: "restaurants"), systemImage: "heart.fill") {
              ContentView()
            }
            Tab(String(localized: "profile"), systemImage: "person.fill") {
              ContentView()
            }
//            Tab(role: .search) {
//                ContentView()
//            } label: {
//                Image(systemName: "magnifyingglass")
//            }
        }
    
        
        // 2.
//        .tabViewBottomAccessory {
//            // 3.
//            Image(systemName: "star.fill")
//        }
        
    }
}

#Preview {
    TabBarView()
}
