//
//  VerifyOtpCodeViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 09/03/2026.
//
import Foundation
import Combine

@MainActor
class VerifyOtpCodeViewModel: ObservableObject {
    @Published var phoneOrEmail = ""
    @Published var otpCode = ""
    @Published var typeOfVerify = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var successMessage = ""
    @Published var resetToken = ""

    
    func verifyOtp() async {
        isLoading = true
        
        print("phoneOrEmail = \(phoneOrEmail)")
        print("otpCode = \(otpCode)")
        print("typeOfVerify = \(typeOfVerify)")
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/verify-otp",
                method: "POST",
                body: VerifyOtpRequest(identifier: phoneOrEmail, otp: otpCode, type: typeOfVerify),
                responseType: VerifyOtpResponse.self
            )
            successMessage = response.message
            print("message = \(successMessage)")
            
            resetToken = response.reset_token ?? ""
            print("resetToken = \(resetToken)")
            
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
