//
//  LoginView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var toast: ToastManager
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @Environment(\.dismiss) var dismiss

    enum Language: String, CaseIterable, Identifiable {
        case mm = "MM"
        case en = "EN"
        var id: String { rawValue }
    }

    @State private var selectedLanguage: Language = .en
    @State private var phoneOrEmail: String = "09123456789" // testing purpose
    @State private var password: String = "12345678" // testing purpose
    @State private var isPasswordVisible: Bool = false
    @State private var isEnglish: Bool = true
    @State private var navigateToHome: Bool = false
    @State private var navigateToChoosePhoneOrEmail = false
    @State private var navigateToForgotPassword = false
    
    @StateObject var vm = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // App icon at the top
                VStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.tint)
                }
                .padding(.top, 22)

                // Card containing login form
                VStack(alignment: .center, spacing: 16) {
//                    Text(String(localized: "login.title"))
                    Text("login.title")
                        .font(.custom("Futura-Medium", size: 22.0))
                        .foregroundStyle(Color("PrimaryColor"))

                    VStack(spacing: 12) {
                        // Phone number field
                        HStack {
                            VStack {
                                Image(systemName: "person.fill")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("SecondaryColor"))
                            )
                            
                            TextField("", text: $vm.phoneOrEmail, prompt: Text( "login.placeholder.phoneOrEmail").foregroundStyle(Color("WhiteColor").opacity(0.6)))
                                .padding(.vertical, 12)
                                .keyboardType(.default)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundStyle(Color("WhiteColor"))
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("PrimaryColor"))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        // Password field
                        HStack {
                            VStack {
                                Image(systemName: "lock.fill")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("SecondaryColor"))
                            )

                            Group {
                                if isPasswordVisible {
                                    TextField("", text: $vm.password, prompt: Text( "login.placeholder.password").foregroundStyle(Color("WhiteColor").opacity(0.6)))
                                        .foregroundStyle(Color("WhiteColor"))
                                        .textContentType(.password)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                } else {
                                    SecureField("", text: $vm.password, prompt: Text( "login.placeholder.password").foregroundStyle(Color("WhiteColor").opacity(0.6)))
                                        .foregroundStyle(Color("WhiteColor"))
                                        .textContentType(.password)
                                }
                            }
                            .padding(.vertical, 12)

                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(.white)
                                    .padding(8)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("PrimaryColor"))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        // Login button
                        Button {
//                            navigateToHome = true
                            Task { await vm.login() }
                        } label: {
                            Text("login.button.login")
                                .font(.custom("Futura-Medium", size: 18.0))
                                .foregroundStyle(.white)
                                .frame(maxWidth: 160)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("SecondaryColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 26)
//                                .stroke(Color("PrimaryColor"), lineWidth: 2)
//                        )
                        .padding(.top, 12)
//                        .disabled(phone.isEmpty || password.isEmpty)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 32)
                
                Text("login.forgotPassword")
                    .font(.custom("Futura-Medium", size: 16.0))
                    .foregroundStyle(Color("PrimaryColor"))
                    .onTapGesture {
                        navigateToForgotPassword = true
                    }
                
                HStack {
                    Text("login.registerPrompt")
                        .font(.custom("Futura-Medium", size: selectedLanguageCode == "my" ? 16.0 : 18.0))
                        .foregroundStyle(.white)
                    
                    Text("login.register")
                        .font(.custom("Futura-Medium", size: selectedLanguageCode == "my" ? 17.0 : 20.0))
                        .bold()
                        .foregroundStyle(.white)
                        .onTapGesture {
                            navigateToChoosePhoneOrEmail = true
                        }
                    
                    Image("RegisterRightArrow")
                           .renderingMode(.template) // optional if you set Template Image
                           .foregroundStyle(.white)
                           .onTapGesture {
                               navigateToChoosePhoneOrEmail = true
                           }
                }
                .padding(.leading, 30)
                .padding(.trailing, 30)
                
                Button {
                    auth.isAuthenticated = false
                    KeychainManager.shared.save("no", forKey: "isLoggedIn")
                    navigateToHome = true
                } label: {
                    Text("login.continueAsGuest")
                        .font(.custom("Futura-Medium", size: selectedLanguageCode == "my" ? 12 : 16.0))
                        .foregroundStyle(Color("PrimaryColor"))
                        .frame(maxWidth: 240)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color("PrimaryColor"), lineWidth: 2)
                )
                
                Spacer()
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 12) {
//                    Text("language.en")
//                        .font(.subheadline)
//                        .foregroundStyle(selectedLanguageCode == "en" ? Color("PrimaryColor") : .secondary)
                    Image("FlagEN")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Toggle("Language", isOn: Binding(
                        get: { selectedLanguageCode == "my" },
                        set: { newLanguage in selectedLanguageCode = newLanguage ? "my" : "en" }
                    ))
                    .labelsHidden()
                    .tint(.red)

//                    Text("language.mm")
//                        .font(.subheadline)
//                        .foregroundStyle(selectedLanguageCode == "my" ? Color("PrimaryColor") : .secondary)
                    Image("FlagMM")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
            }
            .overlay(alignment: .bottom) {
                Text(String(format: String(localized: "app.version"), "1.0.0"))
                    .font(.custom("Futura-Medium", size: 12.0))
                    .foregroundStyle(.white)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
                ZStack {
                    Image("LoginBackground")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    Color(.systemGroupedBackground)
                        .opacity(0.2)
                        .ignoresSafeArea()
                }
            )
            .navigationDestination(isPresented: $vm.loginSuccess) {
                CustomTabView(selectedTab: .home)
                    .environmentObject(auth)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToChoosePhoneOrEmail) {
                ChoosePhoneOrEmailView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToForgotPassword) {
                ForgotPasswordView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToHome) {
                CustomTabView(selectedTab: .home)
                    .environmentObject(auth)
                    .navigationBarBackButtonHidden(true)
            }
            
            if vm.isLoading {
                ProgressView("login.loading")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            if vm.showError {
//                VStack {
//                    Spacer()
//                    ToastView(message: vm.errorMessage)
//                        .onTapGesture { vm.showError = false }
//                }
//                .animation(.easeInOut, value: vm.showError)
            }
            
//            if vm.loginSuccess {
//                VStack {
//                    Spacer()
//                    ToastView(message: "Successfully Login")
//                }
//                .animation(.default, value: "Login Success")
//            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
        .onChange(of: vm.loginSuccess) { oldValue, newValue in
            if newValue {
                auth.isAuthenticated = true
                
                toast.show(message: String(localized: "login.success"))
            }
        }
        .onAppear {
            print("Login View")
        }
//        .onAppear {
//                        for family in UIFont.familyNames {
//                            print("Family: \(family)")
//                            for name in UIFont.fontNames(forFamilyName: family) {
//                                print("  Font: \(name)")
//                            }
//                        }
//                    }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
        .environmentObject(ToastManager())
}
