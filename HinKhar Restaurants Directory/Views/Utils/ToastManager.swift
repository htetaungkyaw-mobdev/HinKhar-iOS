//
//  ToastManager.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 17/03/2026.
//
import SwiftUI
import Combine

class ToastManager: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var message: String = ""

    func show(message: String, duration: Double = 2.0) {
        print("🔥 Toast triggered:", message) 
        self.message = message
        withAnimation {
            self.isShowing = true
        }
        print("isShowing:", isShowing)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.isShowing = false
            }
        }
    }
}
