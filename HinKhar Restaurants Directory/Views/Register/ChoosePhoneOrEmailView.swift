//
//  ChoosePhoneOrEmailView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 02/12/2025.
//

import SwiftUI

struct ChoosePhoneOrEmailView: View {
    enum Language: String, CaseIterable, Identifiable {
        case mm = "MM"
        case en = "EN"
        var id: String { rawValue }
    }

    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    @State private var selectedLanguage: Language = .en
    
    @State private var navigateToLogin = false
    @State private var navigateToEnterPhone = false
    @State private var navigateToEnterEmail = false
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                Image("BackArrow")
                       .renderingMode(.template) // optional if you set Template Image
                       .foregroundStyle(.white)
                       .onTapGesture {
                           navigateToLogin = true
                       }
                       .frame(maxWidth: .infinity, alignment: .leading)
                       .padding(.leading, 24)
                
                VStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.tint)
                }
                
                Spacer()
                
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 12) {

                    Image("FlagEN")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Toggle("Language", isOn: Binding(
                        get: { selectedLanguageCode == "my" },
                        set: { newValue in selectedLanguageCode = newValue ? "my" : "en" }
                    ))
                    .labelsHidden()
                    .tint(.red)

                    Image("FlagMM")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
            }
            .overlay(alignment: .bottom) {
                VStack(alignment: .center, spacing: 0) {

                    Button {
                        navigateToEnterPhone = true
                    } label: {
                        Image("RegisterPhone")
                               .renderingMode(.template) // optional if you set Template Image
                               .foregroundStyle(Color("PrimaryColor"))
                               .frame(height: 40)
                               .padding(.leading, 24)
                        Text("choose.register.phone")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .foregroundStyle(Color("PrimaryColor"))
                            .frame(maxWidth: 250)
//                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color("SecondaryColor"), lineWidth: 3)
                    )
                    .padding(.top, 70)

                    Text("choose.or")
                        .font(.custom("Futura-Medium", size: 16.0))
                        .foregroundStyle(.white)
                        .padding(.top, 30)

                    Button {
                        navigateToEnterEmail = true
                    } label: {
                        Image("Email")
                               .renderingMode(.template) // optional if you set Template Image
                               .foregroundStyle(.white)
                               .frame(height: 40)
                               .padding(.leading, 24)
                        Text("choose.register.email")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 250)
//                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(.white, lineWidth: 2)
                    )
                    .padding(.top, 30)

                    // 👇 Only small bottom padding to avoid "extra space"
                    .padding(.bottom, 70)
                }
                .frame(maxWidth: .infinity)
                .background(
                    Color(Color("PrimaryColor"))
                        .opacity(0.7)
                        .clipShape(RoundedCornerForChoosePhoneOrEmail(radius: 45, corners: [.topLeft, .topRight]))
                        .overlay(
                            GeometryReader { proxy in
                                let w = proxy.size.width
                                let h = proxy.size.height
                                let r: CGFloat = 45
                                let lw: CGFloat = 2
                                Path { path in
                                    // Start at bottom-left up by radius to avoid bottom stroke
                                    path.move(to: CGPoint(x: 0, y: h - r))
                                    // Left vertical up to begin top-left arc
                                    path.addLine(to: CGPoint(x: 0, y: r))
                                    // Top-left corner arc
                                    path.addQuadCurve(to: CGPoint(x: r, y: 0), control: CGPoint(x: 0, y: 0))
                                    // Top horizontal to start top-right arc
                                    path.addLine(to: CGPoint(x: w - r, y: 0))
                                    // Top-right corner arc
                                    path.addQuadCurve(to: CGPoint(x: w, y: r), control: CGPoint(x: w, y: 0))
                                    // Right vertical down, stopping before bottom to avoid bottom stroke
                                    path.addLine(to: CGPoint(x: w, y: h - r))
                                }
                                .stroke(Color.white, lineWidth: lw)
                            }
                        )
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    Image("SplashBackground")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    Color(.systemGroupedBackground)
                        .opacity(0.2)
                        .ignoresSafeArea()
                }
            )
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToEnterPhone) {
                EnterPhoneNumberView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToEnterEmail) {
                EnterEmailView()
                    .navigationBarBackButtonHidden(true)
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

#Preview {
    ChoosePhoneOrEmailView()
}
