//
//  ToastView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//
import SwiftUI

struct ToastView: View {
    var message: String
    var body: some View {
        Text(message)
            .padding()
            .background(Color.green.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

#Preview {
    ToastView(message: "Hello!")
}
