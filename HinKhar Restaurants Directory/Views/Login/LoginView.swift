//
//  LoginView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//

import SwiftUI

private extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var appVersionDisplay: String {
        "\(appVersion) (\(buildNumber))"
    }
}

struct LoginView: View {
    private enum Field {
        case phoneOrEmail
        case password
    }

    @EnvironmentObject var auth: AuthViewModel
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"

    @State private var isPasswordVisible: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var navigateToChoosePhoneOrEmail = false
    @State private var navigateToForgotPassword = false

    @StateObject var vm = LoginViewModel()
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.tint)
                }
                .padding(.top, 22)

                VStack(alignment: .center, spacing: 16) {
                    Text("login.title")
                        .font(.custom("Futura-Medium", size: 22.0))
                        .foregroundStyle(Color("PrimaryColor"))

                    VStack(spacing: 12) {
                        phoneOrEmailField
                        passwordField

                        Button {
                            attemptLogin()
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
                        .padding(.top, 12)
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
                        .foregroundStyle(Color("PrimaryColor"))
                        .onTapGesture {
                            navigateToChoosePhoneOrEmail = true
                        }

                    Image("RegisterRightArrow")
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .onTapGesture {
                            navigateToChoosePhoneOrEmail = true
                        }
                }
                .padding(.leading, 30)
                .padding(.trailing, 30)

                Button {
                    auth.isAuthenticated = false
                    KeychainManager.shared.save("no", forKey: KeychainKeys.isLoggedIn)
                    KeychainManager.shared.save("", forKey: KeychainKeys.userId)
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

                    Image("FlagMM")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding(.top, 12)
                .padding(.trailing, 16)
            }
            .overlay(alignment: .bottom) {
                Text(String(format: String(localized: "app.version"), Bundle.main.appVersionDisplay))
                    .font(.custom("Futura-Medium", size: 12.0))
                    .foregroundStyle(.white)
                    .padding(.bottom, 12)
            }
            .overlay(alignment: .bottom) {
                if vm.showError {
                    ToastView(message: vm.displayErrorMessage)
                        .padding(.bottom, 48)
                        .onDisappear { vm.showError = false }
                }
                
                if vm.loginSuccess {
                    ToastView(message: "login.success", isSuccess: true)
                        .padding(.bottom, 48)
                        .onDisappear { navigateToHome = true }
                }
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
            .navigationDestination(isPresented: $navigateToHome) {
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

            if vm.isLoading {
                ProgressView("login.loading")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
//        .id(selectedLanguageCode)
        .onChange(of: vm.loginSuccess) { _, newValue in
            if newValue {
                auth.isAuthenticated = true
            }
        }
        .onAppear {
            print("Login View")
        }
    }

    private var phoneOrEmailField: some View {
        HStack {
            inputIcon(name: "person.fill")

            TextField(
                "",
                text: $vm.phoneOrEmail,
                prompt: Text("login.placeholder.phoneOrEmail")
                    .foregroundStyle(Color("WhiteColor").opacity(0.6))
            )
            .padding(.vertical, 12)
            .keyboardType(.default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focusedField, equals: .phoneOrEmail)
            .onSubmit {
                focusedField = .password
            }
            .foregroundStyle(Color("WhiteColor"))
        }
        .background(inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var passwordField: some View {
        HStack {
            inputIcon(name: "lock.fill")

            Group {
                if isPasswordVisible {
                    TextField(
                        "",
                        text: $vm.password,
                        prompt: Text("login.placeholder.password")
                            .foregroundStyle(Color("WhiteColor").opacity(0.6))
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                } else {
                    SecureField(
                        "",
                        text: $vm.password,
                        prompt: Text("login.placeholder.password")
                            .foregroundStyle(Color("WhiteColor").opacity(0.6))
                    )
                }
            }
            .foregroundStyle(Color("WhiteColor"))
            .textContentType(.password)
            .padding(.vertical, 12)
            .submitLabel(.done)
            .focused($focusedField, equals: .password)
            .onSubmit {
                attemptLogin()
            }

            Button(action: { isPasswordVisible.toggle() }) {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.white)
                    .padding(8)
            }
        }
        .background(inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func attemptLogin() {
        focusedField = nil

        let phoneOrEmail = vm.phoneOrEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = vm.password.trimmingCharacters(in: .whitespacesAndNewlines)

        if phoneOrEmail.isEmpty {
            vm.errorMessage = "login.error.phoneOrEmailRequired"
            vm.showError = true
            return
        }

        if password.isEmpty {
            vm.errorMessage = "login.error.passwordRequired"
            vm.showError = true
            return
        }

        Task { await vm.login() }
    }

    private func inputIcon(name: String) -> some View {
        VStack {
            Image(systemName: name)
                .frame(width: 30, height: 30)
                .foregroundStyle(.white)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("SecondaryColor"))
        )
    }

    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color("PrimaryColor"))
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
