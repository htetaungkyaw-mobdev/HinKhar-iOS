//
//  VerifyOTPCodeView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 05/12/2025.
//
import SwiftUI
import Combine

struct VerifyOTPCodeView: View {
    enum Language: String, CaseIterable, Identifiable {
        case mm = "MM"
        case en = "EN"
        var id: String { rawValue }
    }
    
    // Accept from caller
    let type: String
    let value: String
    let expiredTime: Int
    let comeFrom: String

    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    @State private var selectedLanguage: Language = .en
    @State private var otpCode: String = ""
    @State private var resetToken: String = ""
    
    // OTP countdown and resend
    @State private var otpDuration: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var isExpired: Bool = false
    @State private var isResending: Bool = false

    // Timer publisher for countdown
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var navigateToLogin = false
    @State private var enterOTPCode = false
    @State private var showAlert = false
    @State private var navigateToRegister = false
    @State private var navigateToResetPassword = false
    @State private var navigateToSetting = false
    
    @StateObject var register_vm = RegisterViewModel()
    @StateObject var vm = VerifyOtpCodeViewModel()
    @StateObject var change_vm = ChangePhoneOrEmailViewModel()
    
    @FocusState private var isOTPFocused: Bool
    
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
                                .font(.custom("Futura-Medium", size: 13.0))
                                .bold()
                                .foregroundStyle(.white)
                            
                            Text("otp.6digits.code")
                                .font(.custom("Futura-Medium", size: 13.0))
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
                        .padding(.horizontal, 12)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundStyle(.black)
                        .focused($isOTPFocused)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color("PrimaryColor"), lineWidth: 1)
                        )
                        .frame(width: 200)
                        .onChange(of: otpCode) { newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            enterOTPCode = trimmed.count == 6
                        }
                    
                    // Countdown & Resend (resend always visible)
                    VStack(spacing: 8) {
                        // Countdown text
                        Group {
                            if remainingSeconds > 0 {
                                HStack(spacing: 4) {
                                    Text("This code will be expired in ")
                                        .font(.custom("Futura-Medium", size: 13.0))
                                        .foregroundStyle(.black)
                                    Text(formattedTime(remainingSeconds))
                                        .font(.custom("Futura-Medium", size: 13.0))
                                        .foregroundStyle(remainingSeconds < 60 ? Color.red : .black)
                                        .opacity(remainingSeconds < 60 ? (remainingSeconds % 2 == 0 ? 1.0 : 0.2) : 1.0)
                                }
                            }
                        }

                        // Resend button (always visible)
                        HStack(spacing: 6) {
                            if isResending {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(LocalizedStringKey("otp.button.resend"))
                                .font(.custom("Futura-Medium", size: 15.0))
                                .foregroundStyle(Color("PrimaryColor"))
                                .underline()
                                .onTapGesture {
                                    Task {
                                        register_vm.phoneOrEmail = value
                                        await register_vm.resendOtp()
                                        
                                        if register_vm.apiSuccess {
                                            otpDuration = register_vm.expiredTime * 60
                                            await resendCode()
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, 16)
                    
                    // Verify button
                    Button {
                        let trimmed = otpCode.trimmingCharacters(in: .whitespacesAndNewlines)
                        enterOTPCode = trimmed.count == 6
                        if isExpired {
                            showAlert = true
                        } else if enterOTPCode {
//                            navigateToRegister = true
                            Task {
                                
                                if comeFrom == "setting" {
                                    
                                    change_vm.otpCode = otpCode
                                    
                                    if type == "phone" {
                                        change_vm.phone = value
                                        await change_vm.verifyOtpChangePhone()
                                    }
                                    else {
                                        change_vm.email = value
                                        await change_vm.verifyOtpChangeEmail()
                                    }
                                    
                                    if change_vm.apiSuccess {
                                        navigateToSetting = true
                                    }
                                }
                                else {
                                    
                                    vm.phoneOrEmail = value
                                    vm.otpCode = otpCode
                                    vm.typeOfVerify = comeFrom
                                    
                                    await vm.verifyOtp()
                                    
                                    if vm.apiSuccess {
                                        if comeFrom == "password_reset" {
                                            resetToken = vm.resetToken
                                            navigateToResetPassword = true
                                        }
                                        else {
                                            navigateToRegister = true
                                        }
                                    }
                                }
                                
                            }
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
                    .alert(isExpired ? "otp.alert.expired.title" : "otp.alert.invalid.title", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(isExpired ? LocalizedStringKey("otp.alert.expired.message") : LocalizedStringKey("otp.alert.invalid.message"))
                    }
                }
                
                Spacer()
                
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isOTPFocused = true
                    }
                
//                Task {
//                    register_vm.phoneOrEmail = value
//                    await register_vm.sendOtp()
//                    
//                    if register_vm.apiSuccess {
//                        otpDuration = register_vm.expiredTime * 60
//                        startCountdown()
//                    }
//                }
                
                otpDuration = expiredTime * 60
                startCountdown()
            }
            .onReceive(timer) { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                    if remainingSeconds == 0 { isExpired = true }
                }
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
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            )
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView(phoneOrEmail: value)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToResetPassword) {
                ResetPasswordView(identifier: value, resetToken: resetToken)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToSetting) {
                SettingView(isTabBarHidden: .constant(false))
                    .navigationBarBackButtonHidden(true)
            }
            
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
    
    // MARK: - Helpers
    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func startCountdown() {
        remainingSeconds = otpDuration
        isExpired = false
    }

    private func resetCountdown() {
        remainingSeconds = otpDuration
        isExpired = false
    }

    private func clearOTP() {
        otpCode = ""
        enterOTPCode = false
    }

    private func resendCode() async {
        guard !isResending else { return }
        isResending = true
        // TODO: Call your API to resend OTP using `type` and `value`
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        clearOTP()
        resetCountdown()
        isExpired = false
        isResending = false
    }
    
    private func hideKeyboard() {
        isOTPFocused = false
    }
}

#Preview {
    VerifyOTPCodeView(type: "phone", value: "09123456789", expiredTime: 10, comeFrom: "registration")
}
