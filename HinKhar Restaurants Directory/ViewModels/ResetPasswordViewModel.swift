//
//  ForgotPasswordViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 09/03/2026.
//
import Foundation
import Combine

@MainActor
class ResetPasswordViewModel: ObservableObject {
    @Published var identifier = "09123456789"
    @Published var newPassword = "password"
    @Published var confirmPassword = "password"
    @Published var otp = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var successMessage = ""

    func resetPassword() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/reset-password",
                method: "POST",
                body: ResetPasswordRequest(identifier: identifier, otp: otp, password: newPassword, password_confirmation: confirmPassword),
                responseType: ResetPasswordResponse.self
            )
            successMessage = response.message
            print("message = \(successMessage)")
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoading = false
    }
}
