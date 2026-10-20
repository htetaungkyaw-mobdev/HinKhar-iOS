//
//  CommonLoading.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 08/04/2026.
//
import SwiftUI

struct CommonLoading: View {
    var body: some View {
        ZStack {
//                        Color.black.opacity(0.001) // allows taps to pass through visually subtle
//                            .ignoresSafeArea()
//                        ProgressView("Loading...")
//                            .padding()
//                            .background(.ultraThinMaterial)
//                            .cornerRadius(12)
            ZStack {
                LottieView(animationName: "loading_lottie")
                    .frame(width: 150, height: 150)
            }
            .frame(width: 170, height: 170)
//                        .background(.ultraThinMaterial)
            .background(Color("SecondaryColor"))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Loading")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .ignoresSafeArea()
    }
}

#Preview {
    CommonLoading()
}
