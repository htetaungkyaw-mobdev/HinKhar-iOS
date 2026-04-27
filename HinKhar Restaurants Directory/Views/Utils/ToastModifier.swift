//
//  ToastModifier.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 17/03/2026.
//


import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    var duration: Double = 2.0

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                VStack {
                    Spacer()
                    
                    Text(message)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .onTapGesture {
                            isPresented = false
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                isPresented = false
                            }
                        }
                }
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: isPresented)
            }
        }
    }
}
