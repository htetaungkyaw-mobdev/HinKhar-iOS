//
//  ForgotPasswordView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 06/03/2026.
//
import SwiftUI

struct ForgotPasswordView: View {
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToLogin: Bool = false
    @State private var navigateToVerifyOtp: Bool = false
//    @State private var phoneOrEmail: String = ""
    @State private var showAlert = false
    
    @StateObject var vm = ForgotPasswordViewModel()
    
    @State private var expiredTime = 0
    
    private var isEmail: Bool {
        // Simple heuristic: contains one '@' and a dot after it
        let trimmed = vm.phoneOrEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let atRange = trimmed.range(of: "@") else { return false }
        let domainPart = trimmed[atRange.upperBound...]
        return domainPart.contains(".")
    }

    private var isPhone: Bool {
        // Heuristic: at least 6 digits when non-digits are removed
        let digits = vm.phoneOrEmail.filter { $0.isNumber }
        return digits.count >= 6
    }

    private var leadingIconName: String {
        if isEmail { return "envelope.fill" }
        if isPhone { return "phone.fill" }
        return "phone.fill" // default
    }

    private var adaptiveKeyboard: UIKeyboardType {
        isEmail ? .emailAddress : .phonePad
    }
    
    private var enterPhoneOrEmail: Bool {
        !vm.phoneOrEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TitleBar(title: "login.forgotPassword") {
                    navigateToLogin = true
                }
                
                VStack(spacing: 12) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.tint)
                }
                
                Text("forgot.message")
                    .font(.custom("FuturaCyrillicMedium", size: 14.0))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10)
                
                // Phone number field
                HStack {
                    VStack {
                        Image(systemName: leadingIconName)
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("SecondaryColor"))
                    )
                    
                    ZStack(alignment: .leading) {
                        if vm.phoneOrEmail.isEmpty {
                            Text("forgot.placeholder")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(Color("WhiteColor").opacity(0.6))
                        }
                        TextField("", text: $vm.phoneOrEmail)
                            .font(.custom("Futura-Medium", size: 16.0))
                            .padding(.vertical, 12)
//                            .keyboardType(adaptiveKeyboard)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .foregroundStyle(Color("WhiteColor"))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("PrimaryColor"))
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("PrimaryColor"))
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 10)
                .padding(.leading, 50)
                .padding(.trailing, 50)
                
                // Confirm button
                Button {
                    if enterPhoneOrEmail {
                        Task {
                            await vm.forgotPassword()
                            
                            if vm.apiSuccess {
                                expiredTime = vm.expiredTime
                                navigateToVerifyOtp = true
                            }
                        }
                    } else {
                        showAlert = true
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
                .alert("forgot.alert.title", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                } message: {
                    Text("forgot.alert.message")
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToVerifyOtp) {
                VerifyOTPCodeView(type: isPhone ? "phone" : "email", value: vm.phoneOrEmail,
                                  expiredTime: expiredTime, comeFrom: "password_reset")
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
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
    ForgotPasswordView()
}
