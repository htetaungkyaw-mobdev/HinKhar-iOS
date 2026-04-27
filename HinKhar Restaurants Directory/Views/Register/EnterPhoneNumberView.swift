//
//  EnterPhoneNumberView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 04/12/2025.
//

import SwiftUI

struct EnterPhoneNumberView: View {
    enum Language: String, CaseIterable, Identifiable {
        case mm = "MM"
        case en = "EN"
        var id: String { rawValue }
    }

    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    @State private var selectedLanguage: Language = .en
    @State private var phone: String = ""
    
    @State private var enterPhone = false
    @State private var showAlert = false
    
    @State private var navigateToLogin = false
    @State private var navigateToVerifyOTP = false
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
                
                VStack(alignment: .center, spacing: 16) {
                    VStack {
                        Text("register.title")
                            .font(.custom("Futura-Medium", size: 20.0))
                            .foregroundStyle(.primary)
                        
                        Text("register.to.be")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .foregroundStyle(.primary)
                    }

                    VStack(spacing: 12) {
                        // Phone number field
                        HStack {
                            VStack {
                                Image(systemName: "phone.fill")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("SecondaryColor"))
                            )
                            
                            ZStack(alignment: .leading) {
                                if phone.isEmpty {
                                    Text("register.placeholder.phone")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundStyle(Color("WhiteColor").opacity(0.6))
                                }
                                TextField("", text: $phone)
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .padding(.vertical, 12)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .foregroundStyle(Color("WhiteColor"))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("PrimaryColor"))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("PrimaryColor"))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.top, 30)

                        // Continue button
                        Button {
                            if enterPhone {
                                navigateToRegister = true
                            } else {
                                showAlert = true
                            }
                        } label: {
                            Text("register.button.continue")
                                .font(.custom("Futura-Medium", size: 18.0))
                                .foregroundStyle(Color("PrimaryColor"))
                                .frame(maxWidth: 160)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("SecondaryColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color("PrimaryColor"), lineWidth: 2)
                        )
                        .padding(.top, 30)
                      .alert("Enter phone number", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Please enter your phone number to continue.")
                    }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 32)
                
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
//                VerifyOTPCodeView(type: "phone", value: phone)
//                    .navigationBarBackButtonHidden(true)
                RegisterView().navigationBarBackButtonHidden(true)
            }
            
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

#Preview {
    EnterPhoneNumberView()
}
