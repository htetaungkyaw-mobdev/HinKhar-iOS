//
//  ChangePhoneOrEmailViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/10/2026.
//
import Foundation
import Combine

@MainActor
class ChangePhoneOrEmailViewModel: ObservableObject {
    @Published var phone = ""
    @Published var email = ""
    @Published var otpCode = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var expiredTime = 0
    
    @Published var successMessage = ""
    
    func requestOtpChangePhone() async {
        isLoading = true
        
        print("phone = \(phone)")
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/change-phone/request-otp",
                method: "POST",
                body: ChangePhoneOtpRequest(phone: phone),
                requiresToken: true,
                responseType: ForgotPasswordResponse.self
            )
            successMessage = response.message ?? ""
            print("message = \(successMessage)")
            
            expiredTime = response.expires_in
            print("expiredTime = \(expiredTime)")

            
            apiSuccess = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoading = false
    }
    
    func requestOtpChangeEmail() async {
        isLoading = true
        
        print("email = \(email)")
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/change-email/request-otp",
                method: "POST",
                body: ChangeEmailOtpRequest(email: email),
                requiresToken: true,
                responseType: ForgotPasswordResponse.self
            )
            successMessage = response.message ?? ""
            print("message = \(successMessage)")
            
            expiredTime = response.expires_in
            print("expiredTime = \(expiredTime)")

            
            apiSuccess = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoading = false
    }

    
    func verifyOtpChangePhone() async {
        isLoading = true
        
        print("phone = \(phone)")
        print("otpCode = \(otpCode)")
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/change-phone/verify",
                method: "POST",
                body: ChangePhoneVerifyOtpRequest(phone: phone, otp: otpCode),
                requiresToken: true,
                responseType: ChangePhoneOrEmailVerifyOtpResponse.self
            )
            successMessage = response.message
            print("message = \(successMessage)")
            
            KeychainManager.shared.save(response.user.phone ?? "", forKey: KeychainKeys.userPhone)
            
            apiSuccess = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoading = false
    }
    
    func verifyOtpChangeEmail() async {
        isLoading = true
        
        print("email = \(email)")
        print("otpCode = \(otpCode)")
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/change-email/verify",
                method: "POST",
                body: ChangeEmailVerifyOtpRequest(email: email, otp: otpCode),
                requiresToken: true,
                responseType: ChangePhoneOrEmailVerifyOtpResponse.self
            )
            successMessage = response.message
            print("message = \(successMessage)")
            
            KeychainManager.shared.save(response.user.email ?? "", forKey: KeychainKeys.userEmail)
            
            apiSuccess = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoading = false
    }
    
}
