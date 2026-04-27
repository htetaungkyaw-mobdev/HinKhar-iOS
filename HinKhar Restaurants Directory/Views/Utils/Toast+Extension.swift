//
//  ToastExtension.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 17/03/2026.
//
import SwiftUI

extension View {
    func toast(isPresented: Binding<Bool>, message: String, duration: Double = 2.0) -> some View {
        self.modifier(ToastModifier(isPresented: isPresented, message: message, duration: duration))
    }
}
