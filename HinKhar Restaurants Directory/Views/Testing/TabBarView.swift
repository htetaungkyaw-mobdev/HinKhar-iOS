//
//  TabBarView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        
        TabView {
            ContentView()
                .tabItem {
                    Label(String(localized: "home"), systemImage: "house")
                }

            ContentView()
                .tabItem {
                    Label(String(localized: "alerts"), systemImage: "bell")
                }

            ContentView()
                .tabItem {
                    Label(String(localized: "restaurants"), systemImage: "heart.fill")
                }

            ContentView()
                .tabItem {
                    Label(String(localized: "profile"), systemImage: "person.fill")
                }
        }
        
    }
}

#Preview {
    TabBarView()
}
