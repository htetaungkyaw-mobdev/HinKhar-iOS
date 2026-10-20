//
//  ChangePhoneOrEmailView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 02/01/2026.
//
import SwiftUI

struct ChangePhoneOrEmailView: View {
    enum Language: String, CaseIterable, Identifiable {
        case mm = "MM"
        case en = "EN"
        var id: String { rawValue }
    }
    
    let initialType: String
    let initialValue: String

    @State private var selectedLanguage: Language = .en
    @State private var type: String
    @State private var value: String
    
    @State private var enterPhone = false
    @State private var showAlert = false
    
    @State private var navigateToSetting = false
    @State private var navigateToVerifyOTP = false
    
    @State private var expiredTime = 0
    
    @StateObject var vm = ChangePhoneOrEmailViewModel()
    @StateObject var register_vm = RegisterViewModel()
    
    init(type: String, value: String) {
        self.initialType = type
        self.initialValue = value
        
        _type = State(initialValue: type)
        _value = State(initialValue: value)
    }
    
    var body: some View {
        NavigationStack {
            
            HStack {
                ZStack {
                    // Centered title
                    Text(
                        initialValue.isEmpty
                        ? (initialType == "phone" ? "setting.setPhone" : "setting.setEmail")
                        : (initialType == "phone" ? "setting.changePhone" : "setting.changeEmail")
                    )
                    .font(.custom("Futura-Medium", size: 18.0))
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Leading back button overlaid
                    HStack {
                        Image("BackArrow")
                            .renderingMode(.template)
                            .foregroundStyle(Color("PrimaryColor"))
                            .onTapGesture {
                                navigateToSetting = true
                            }
                            .padding(.leading, 24)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
            
            VStack {
//                if !initialValue.isEmpty {
                    Image("ChangePhoneOrEmail")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
//                }
                
                VStack(alignment: .center, spacing: 16) {

                    VStack(spacing: 12) {
                        // Phone number field
                        HStack {
                            VStack {
                                Image(initialType == "phone" ? "RegisterPhone" : "Email")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color("SecondaryColor"))
                            )
                            
                            ZStack(alignment: .leading) {
//                                if initialValue.isEmpty {
//                                    Text(initialType == "phone" ? "Enter your phone number" : "Enter your email address")
//                                        .foregroundStyle(Color("WhiteColor").opacity(0.6))
//                                }
//                                let hintText = initialValue.isEmpty
//                                    ? (initialType == "phone" ? "Enter your phone number" : "Enter your email address")
//                                    : ""
                                let hintText = initialType == "phone"
                                    ? "register.placeholder.phone"
                                    : "register.placeholder.email"
//                                Text(hintText)
                                TextField("", text: $value,
                                          prompt: Text(LocalizedStringKey(hintText)).foregroundColor(.white.opacity(0.5)))
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
                            if type == "phone" {
                                if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Task {
                                        vm.phone = value
                                        await vm.requestOtpChangePhone()
                                        
                                        if vm.apiSuccess {
                                            expiredTime = vm.expiredTime
                                            navigateToVerifyOTP = true
                                        }
                                    }
                                }
                                else {
                                    showAlert = true
                                }
                            }
                            else {
                                let trimmedEmail = value.trimmingCharacters(in: .whitespacesAndNewlines)
                                if trimmedEmail.isEmpty {
                                    showAlert = true
                                } else if isValidEmail(trimmedEmail) {
                                    Task {
                                        vm.email = value
                                        await vm.requestOtpChangeEmail()
                                        
                                        if vm.apiSuccess {
                                            expiredTime = vm.expiredTime
                                            navigateToVerifyOTP = true
                                        }
                                    }
                                } else {
                                    showAlert = true
                                }
                            }
                        } label: {
                            Text(initialValue.isEmpty ? "set" : "change")
                                .font(.custom("Futura-Medium", size: 18.0))
                                .foregroundStyle(.white)
                                .frame(maxWidth: 160)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("PrimaryColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color("SecondaryColor"), lineWidth: 1)
                        )
                        .padding(.top, 30)
                        .alert(initialType == "phone" ? "register.placeholder.phone" : "register.placeholder.email", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(initialType == "phone" ? "Please enter your phone number to continue." : "Please enter your email address to continue.")
                    }
                    }
                }
                .padding(.horizontal, 60)
                
                Spacer()
                
            }
            .navigationDestination(isPresented: $navigateToSetting) {
                SettingView(isTabBarHidden: .constant(true))
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToVerifyOTP) {
                VerifyOTPCodeView(type: type, value: value, expiredTime: expiredTime, comeFrom: "setting")
                    .navigationBarBackButtonHidden(true)
//                RegisterView(phoneOrEmail: phone).navigationBarBackButtonHidden(true)
            }
//            .onChange(of: vm.apiSuccess) { _, newValue in
//                if newValue {
//                    if type == "phone" {
//                        KeychainManager.shared.save(value, forKey: KeychainKeys.userPhone)
//                    }
//                    else {
//                        KeychainManager.shared.save(value, forKey: KeychainKeys.userEmail)
//                    }
//                    navigateToSetting = true
//                }
//            }
        }
    }
    
    private func isValidEmail(_ input: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: input)
    }
}

#Preview {
    ChangePhoneOrEmailView(type: "phone", value: "")
}

