//
//  MyFeatureView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 17/03/2026.
//
import SwiftUI

struct MyFeatureView: View {
    // Access the global manager
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Settings or Profile Page")
                .font(.title)
            
            Button(action: {
                // This triggers the logic defined in your ToastManager
                toastManager.show(message: "Changes Saved! 💾")
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Changes")
                }
                .font(.headline)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    MyFeatureView()
        .environmentObject(ToastManager())
}
