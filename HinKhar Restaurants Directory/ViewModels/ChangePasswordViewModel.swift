//
//  ChangePasswordViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 09/03/2026.
//
import Foundation
import Combine

@MainActor
class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var successMessage = ""

    func changePassword() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/change-password",
                method: "POST",
                body: ChangePasswordRequest(
                    current_password: currentPassword,
                    new_password: newPassword,
                    new_password_confirmation: confirmPassword
                ),
                requiresToken: true,
                responseType: ChangePasswordResponse.self
            )
            successMessage = response.message
            print("message = \(successMessage)")
            
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
