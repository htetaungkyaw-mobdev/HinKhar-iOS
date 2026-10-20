//
//  ToastView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//
import SwiftUI

struct ToastView: View {
    var message: String
    var isSuccess: Bool = false
    var autoHideDuration: Duration = .seconds(3)
    var onDismiss: (() -> Void)? = nil

    @State private var isVisible = true
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"

    var body: some View {
        Group {
            if isVisible {
                Text(LocalizedStringKey(message))
                    .padding()
                    .background(isSuccess ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .task(id: message) {
            isVisible = true

            do {
                try await Task.sleep(for: autoHideDuration)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut) {
                isVisible = false
            }
            onDismiss?()
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
    }
}

#Preview {
    ToastView(message: "Hello!")
}
