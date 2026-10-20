//
//  LoginViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//
import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
//    @Published var phoneOrEmail = "09123456789"
//    @Published var password = "12345678"
    @Published var phoneOrEmail = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var loginSuccess = false

    var displayErrorMessage: String {
        switch errorMessage {
        case "The provided credentials are incorrect.":
            return "login.error.credentialsIncorrect"
        case "Account is deactivated. Please contact admin.":
            return "login.error.accountDeactivated"
        default:
            return errorMessage
        }
    }

    func login() async {
        isLoading = true
        showError = false
        loginSuccess = false
        errorMessage = ""
        
        do {
            let response = try await LoginApiService.apiService.login(
                endpoint: "auth/login",
                method: "POST",
                body: LoginRequest(login: phoneOrEmail, password: password),
                responseType: LoginResponse.self
            )

            KeychainManager.shared.save(response.access_token, forKey: KeychainKeys.userToken)
            KeychainManager.shared.save(String(response.user.id), forKey: KeychainKeys.userId)
            KeychainManager.shared.save(response.user.name, forKey: KeychainKeys.userName)
            KeychainManager.shared.save(response.user.phone ?? "", forKey: KeychainKeys.userPhone)
            KeychainManager.shared.save(response.user.email ?? "", forKey: KeychainKeys.userEmail)
            
            KeychainManager.shared.save("yes", forKey: KeychainKeys.isLoggedIn)
            loginSuccess = true
        } catch let apiError as LoginApiError {
            errorMessage = apiError.localizedDescription
            showError = true
            print("login_error1 = \(errorMessage)")
        }
        catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

            errorMessage = error.localizedDescription
            showError = true
            print("login_error2 = \(errorMessage)")
        }

        isLoading = false
    }
}
