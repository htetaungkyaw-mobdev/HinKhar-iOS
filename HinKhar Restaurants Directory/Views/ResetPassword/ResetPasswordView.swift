//
//  ForgotPasswordView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 06/03/2026.
//
import SwiftUI

struct ResetPasswordView: View {
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @State private var navigateToLogin: Bool = false
    @State private var navigateToForgotPassword: Bool = false
//    @State private var phoneOrEmail: String = ""
    @State private var showAlert = false
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    
    @State private var newPassword: String = ""
    @State private var isNewPasswordVisible: Bool = false
    @State private var confirmPassword: String = ""
    @State private var isConfirmPasswordVisible: Bool = false
    
    @StateObject var vm = ResetPasswordViewModel()
    
    let identifier: String
    let resetToken: String
    
    init(
        identifier: String = "",
        resetToken: String = "",
        )
    {
        self.identifier = identifier
        self.resetToken = resetToken
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TitleBar(title: "reset.title") {
                    navigateToForgotPassword = true
                }
                
                VStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.tint)
                }
                
                // New Password field
                HStack {
                    VStack {
                        Image(systemName: "lock.fill")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("SecondaryColor"))
                    )

                    ZStack(alignment: .leading) {
                        if vm.newPassword.isEmpty {
                            Text("reset.placeholder.newPassword")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(Color("WhiteColor").opacity(0.6))
                        }
                        Group {
                            if isNewPasswordVisible {
                                TextField("", text: $vm.newPassword)
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .foregroundStyle(Color("WhiteColor"))
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("", text: $vm.newPassword)
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .foregroundStyle(Color("WhiteColor"))
                                    .textContentType(.password)
                            }
                        }
                        .padding(.vertical, 12)
                    }

                    Button(action: { isNewPasswordVisible.toggle() }) {
                        Image(systemName: isNewPasswordVisible ? "eye.slash" : "eye")
                            .foregroundStyle(.white)
                            .padding(8)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("PrimaryColor"))
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 10)
                .padding(.leading, 50)
                .padding(.trailing, 50)
                
                // Confirm Password field
                HStack {
                    VStack {
                        Image(systemName: "lock.fill")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("SecondaryColor"))
                    )

                    ZStack(alignment: .leading) {
                        if vm.confirmPassword.isEmpty {
                            Text("reset.placeholder.confirmNewPassword")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(Color("WhiteColor").opacity(0.6))
                        }
                        Group {
                            if isConfirmPasswordVisible {
                                TextField("", text: $vm.confirmPassword)
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .foregroundStyle(Color("WhiteColor"))
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("", text: $vm.confirmPassword)
                                    .font(.custom("Futura-Medium", size: 16.0))
                                    .foregroundStyle(Color("WhiteColor"))
                                    .textContentType(.password)
                            }
                        }
                        .padding(.vertical, 12)
                    }

                    Button(action: { isConfirmPasswordVisible.toggle() }) {
                        Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                            .foregroundStyle(.white)
                            .padding(8)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("PrimaryColor"))
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 10)
                .padding(.leading, 50)
                .padding(.trailing, 50)
                
                // Confirm button
                Button {
                    let newPwd = vm.newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
                    let confirmPwd = vm.confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

                    // Validate minimum length
                    guard newPwd.count >= 8 else {
                        validationMessage = "New password must be at least 8 characters."
                        showValidationAlert = true
                        return
                    }
                    guard confirmPwd.count >= 8 else {
                        validationMessage = "Confirm password must be at least 8 characters."
                        showValidationAlert = true
                        return
                    }

                    // Validate match
                    guard newPwd == confirmPwd else {
                        validationMessage = "Passwords do not match."
                        showValidationAlert = true
                        return
                    }

                    // All good: call reset password API
                    Task {
                        vm.identifier = identifier
                        vm.resetToken = resetToken
                        await vm.resetPassword()
                    }
                } label: {
                    Text("forgot.button.confirm")
                        .font(.custom("Futura-Medium", size: 18.0))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 160)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 30)
                .alert("Invalid Password", isPresented: $showValidationAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(validationMessage)
                }
                
                // Back to Login
                Button {
                    navigateToLogin = true
                } label: {
                    Text("reset.button.backToLogin")
                        .font(.custom("Futura-Medium", size: 18.0))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 160)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("SecondaryColor"))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 30)
                
                Spacer()
            }
            .navigationDestination(isPresented: $vm.apiSuccess) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToForgotPassword) {
                ForgotPasswordView()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                vm.identifier = identifier
            }
            
            if vm.isLoading {
                ProgressView("login.loading")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            if vm.showError {
                VStack {
                    Spacer()
                    ToastView(message: vm.errorMessage, onDismiss: {
                        vm.showError = false
                    })
                        .onTapGesture { vm.showError = false }
                }
                .animation(.easeInOut, value: vm.showError)
            }

        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

// MARK: - Subviews
private struct TitleBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(LocalizedStringKey(title))
                .font(.custom("Futura-Medium", size: 18.0))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)

            HStack {
                Image("BackArrow")
                    .renderingMode(.template)
                    .foregroundStyle(Color("PrimaryColor"))
                    .padding(.leading, 24)
                    .onTapGesture { onBack() }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

#Preview {
    ResetPasswordView(
        identifier: "",
        resetToken: ""
    )
}
