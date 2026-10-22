//
//  LoginViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//

import Foundation
import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var phoneOrEmail = ""
    @Published var name = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var registerSuccess = false

    @Published var apiSuccess = false
    @Published var successMessage = ""
    @Published var expiredTime = 0

    var displayErrorMessage: String {
        switch errorMessage {
        case "Phone number already registered":
            return "register.error.duplicatePhone"
        case "The password field must be at least 8 characters.":
            return "register.error.password.min8"
        case "The password field confirmation does not match.":
            return "register.error.password.notMatch"
        default:
            return errorMessage
        }
    }

    func sendOtp() async {
        isLoading = true

        print("phoneOrEmail = \(phoneOrEmail)")

        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/send-otp",
                method: "POST",
                body: ForgotPasswordRequest(identifier: phoneOrEmail),
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

    func resendOtp() async {
        isLoading = true

        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/resend-otp",
                method: "POST",
                body: ForgotPasswordRequest(identifier: phoneOrEmail),
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

    func register(phoneOrEmail: String) async {
        isLoading = true

        do {
            let response = try await RegisterApiService.apiService.register(
                endpoint: "auth/register",
                method: "POST",
                body: RegisterRequest(identifier: phoneOrEmail, name: name, password: password, password_confirmation: confirmPassword),
                responseType: RegisterResponse.self
            )

            KeychainManager.shared.save(response.access_token, forKey: KeychainKeys.userToken)
            KeychainManager.shared.save(String(response.user.id), forKey: KeychainKeys.userId)
            KeychainManager.shared.save(response.user.name, forKey: KeychainKeys.userName)
            KeychainManager.shared.save(response.user.phone ?? "", forKey: KeychainKeys.userPhone)
            KeychainManager.shared.save(response.user.email ?? "", forKey: KeychainKeys.userEmail)
            KeychainManager.shared.save("yes", forKey: KeychainKeys.isLoggedIn)

            await DeviceTokenRegistrationService.shared.registerStoredToken(isSignedIn: true)
            registerSuccess = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

            errorMessage = error.localizedDescription
            showError = true
        }

        print("register_error = \(errorMessage)")
        isLoading = false
    }
}
