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
    @Published var phoneOrEmail = "09123456789"
    @Published var password = "12345678"
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var loginSuccess = false

    func login() async {
        isLoading = true
        
        do {
            let response = try await LoginApiService.apiService.login(
                endpoint: "auth/login",
                method: "POST",
                body: LoginRequest(login: phoneOrEmail, password: password),
                responseType: LoginResponse.self
            )

            KeychainManager.shared.save(response.access_token, forKey: "userToken")
            KeychainManager.shared.save(String(response.user.id), forKey: "userId")
            KeychainManager.shared.save(response.user.name, forKey: "userName")
            KeychainManager.shared.save(response.user.phone ?? "", forKey: "userPhone")
            
            KeychainManager.shared.save("yes", forKey: "isLoggedIn")
            loginSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
}

