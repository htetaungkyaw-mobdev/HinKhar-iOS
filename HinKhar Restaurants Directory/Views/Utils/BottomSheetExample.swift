//
//  BottomSheetExample.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 03/12/2025.
//
import SwiftUI

struct BottomSheetExample: View {
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Button("Show Bottom Sheet") {
                withAnimation(.spring()) {
                    showSheet = true
                }
            }
        }
        .sheet(isPresented: $showSheet) {
                    VStack {
                        Text("This is a system bottom sheet")
                            .font(.title3)
                            .padding()
                    }
                    .presentationDetents([.height(500), .medium, .large])
//                    .presentationCornerRadius(20)
                }
    }
}

struct BottomSheetView: View {
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 10)
            
            Text("This is a bottom sheet")
                .font(.title3)
                .padding()

            Button("Close") {
                withAnimation {
                    show = false
                }
            }
            .padding(.bottom)

        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
        .ignoresSafeArea(edges: .bottom)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    BottomSheetExample()
}
