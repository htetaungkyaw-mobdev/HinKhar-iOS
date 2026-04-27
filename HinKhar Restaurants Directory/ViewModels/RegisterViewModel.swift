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
    @Published var identifier = ""
    @Published var name = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var registerSuccess = false

    func register() async {
        isLoading = true
        
        do {
            let response = try await RegisterApiService.apiService.register(
                endpoint: "auth/register",
                method: "POST",
                body: RegisterRequest(identifier: identifier, name: name, password: password, password_confirmation: password),
                responseType: RegisterResponse.self
            )

            KeychainManager.shared.save(response.access_token, forKey: "userToken")
            KeychainManager.shared.save(String(response.user.id), forKey: "userId")
            KeychainManager.shared.save(response.user.name, forKey: "userName")
            registerSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
}

