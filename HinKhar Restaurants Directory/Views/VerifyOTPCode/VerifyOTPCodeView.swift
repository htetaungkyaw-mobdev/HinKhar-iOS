//
//  VerifyOTPCodeView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 05/12/2025.
//
import SwiftUI

struct VerifyOTPCodeView: View {
    enum Language: String, CaseIterable, Identifiable {
        case mm = "MM"
        case en = "EN"
        var id: String { rawValue }
    }
    
    // Accept from caller
    let type: String
    let value: String

    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    @State private var selectedLanguage: Language = .en
    @State private var otpCode: String = ""
    
    @State private var navigateToLogin = false
    @State private var enterOTPCode = false
    @State private var showAlert = false
    @State private var navigateToRegister = false
    
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
                
                VStack {
                    Text(type == "email" ? "otp.verify.email" : "otp.verify.phone")
                        .font(.custom("Futura-Medium", size: 22.0))
                        .foregroundStyle(.white)
                        .padding(.bottom, 10)
                    
                    HStack {
                        if selectedLanguageCode == "my" {
                            Text(value)
                                .font(.custom("Futura-Medium", size: 12.0))
                                .bold()
                                .foregroundStyle(.white)
                            
                            Text("otp.6digits.code")
                                .font(.custom("Futura-Medium", size: 12.0))
                                .foregroundStyle(.white)
                        }
                        else {
                            Text("otp.6digits.code")
                                .font(.custom("Futura-Medium", size: 12.0))
                                .foregroundStyle(.white)
                            
                            Text(value)
                                .font(.custom("Futura-Medium", size: 12.0))
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Text("otp.code")
                        .font(.custom("Futura-Medium", size: 16.0))
                        .foregroundStyle(.white)
                        .padding(.top, 30)
                    
                    TextField("", text: $otpCode)
                        .font(.custom("Futura-Medium", size: 16.0))
                        .padding(.vertical, 12)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundStyle(Color("WhiteColor"))
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color("PrimaryColor"), lineWidth: 1)
                        )
                        .frame(width: 200)
                    
                    // Register button
                    Button {
                        if enterOTPCode {
                            navigateToRegister = true
                        } else {
                            showAlert = true
                        }
                    } label: {
                        Text("otp.button.verify")
                            .font(.custom("Futura-Medium", size: 18.0))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 120)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color("WhiteColor"), lineWidth: 2)
                    )
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .alert("Please enter OTP Code", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("You must need to enter OTP Code to verify.")
                    }
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
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView()
                    .navigationBarBackButtonHidden(true)
            }
            
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

#Preview {
    VerifyOTPCodeView(type: "phone", value: "09123456789")
}

