//
//  EnterEmailView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 04/12/2025.
//

import SwiftUI

struct EnterEmailView: View {
    enum Language: String, CaseIterable, Identifiable {
        case mm = "MM"
        case en = "EN"
        var id: String { rawValue }
    }

    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    @State private var selectedLanguage: Language = .en
    @State private var email: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = "Please enter your email address to continue."
    
    @State private var expiredTime = 0
    
    @State private var navigateToLogin = false
    @State private var navigateToVerifyOTP = false
    @State private var navigateToRegister = false
    
    @StateObject var register_vm = RegisterViewModel()
    
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
                                Image("Email")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("SecondaryColor"))
                            )
                            
                            ZStack(alignment: .leading) {
                                if email.isEmpty {
                                    Text("register.placeholder.email")
                                        .font(.custom("Futura-Medium", size: 16.0))
                                        .foregroundStyle(Color("WhiteColor").opacity(0.6))
                                }
                                TextField("", text: $email)
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .padding(.vertical, 12)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
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
                            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                            if trimmedEmail.isEmpty {
                                alertMessage = "register.alert.email"
                                showAlert = true
                            } else if isValidEmail(trimmedEmail) {
                                Task {
                                    register_vm.phoneOrEmail = trimmedEmail
                                    await register_vm.sendOtp()
                                    
                                    if register_vm.apiSuccess {
                                        expiredTime = register_vm.expiredTime
                                        navigateToVerifyOTP = true
                                    }
                                }
                            } else {
                                alertMessage = "register.alert.email.format"
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
                      .alert("register.alert.email.title", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(LocalizedStringKey(alertMessage))
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
            .overlay(alignment: .bottom) {
                
                if register_vm.showError {
                    ToastView(message: register_vm.displayErrorMessage)
                        .padding(.bottom, 48)
                        .onDisappear { register_vm.showError = false }
                }
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
            .navigationDestination(isPresented: $navigateToVerifyOTP) {
                VerifyOTPCodeView(type: "email", value: email, expiredTime: expiredTime, comeFrom: "registration")
                    .navigationBarBackButtonHidden(true)
//                RegisterView(phoneOrEmail: phone).navigationBarBackButtonHidden(true)
            }
            
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
    
    private func isValidEmail(_ input: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: input)
    }
}

#Preview {
    EnterEmailView()
}
