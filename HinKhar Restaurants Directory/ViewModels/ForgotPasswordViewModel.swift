//
//  ForgotPasswordViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 09/03/2026.
//
import Foundation
import Combine

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var phoneOrEmail = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var successMessage = ""

    func forgotPassword() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/forgot-password",
                method: "POST",
                body: ForgotPasswordRequest(identifier: phoneOrEmail),
                responseType: ForgotPasswordResponse.self
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
