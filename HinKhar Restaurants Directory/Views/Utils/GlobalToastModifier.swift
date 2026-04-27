//
//  GlobalToastModifier.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 18/03/2026.
//
import SwiftUI
import Combine

struct GlobalToastModifier: ViewModifier {
    @EnvironmentObject var toast: ToastManager

    func body(content: Content) -> some View {
        ZStack {
            content

//            if toast.isShowing {
//                VStack {
//                    Spacer()
//                    ToastView(message: toast.message)
//                }
//                .zIndex(999) // ✅ VERY IMPORTANT
//                                .transition(.move(edge: .bottom).combined(with: .opacity))
//                                .animation(.easeInOut, value: toast.isShowing)
//            }
        }
    }
}
