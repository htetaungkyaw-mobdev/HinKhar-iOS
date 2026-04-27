//
//  SettingViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 30/12/2025.
//
import Foundation
import Combine

@MainActor
class SettingViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    @Published var settings: [ApiSetting] = []
    
    @Published var userId = 0
    @Published var suggestionText = ""
    @Published var isLoadingForSubmitSuggestion = false
    @Published var apiSuccessForSubmitSuggestion = false
    @Published var submitSuggestionData: SubmitSuggestionData? = nil
    
    func getAllSettings() async {
        isLoading = true
        
        do {
            let response = try await SettingApiService.apiService.shared(
                endpoint: "app-settings",
                method: "GET",
                responseType: SettingListResponse.self
            )
            
            print(response)
            
            self.settings = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }

    func submitSuggestion() async {
        isLoadingForSubmitSuggestion = true
        
        if let userIdString = KeychainManager.shared.get("userId"), let parsedId = Int(userIdString) {
            userId = parsedId
        } else {
            errorMessage = String(localized: "error.missingUserId")
            print("errorMessage = \(errorMessage)")
            showError = true
            isLoading = false
            return
        }
        
        print("userId = \(userId)")
        print("suggestionText = \(suggestionText)")
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "suggestions",
                method: "POST",
                body: SubmitSuggestionRequest(comment: suggestionText),
                requiresToken: true,
                responseType: SubmitSuggestionResponse.self
            )
            
            print(response)
            
            self.submitSuggestionData = response.data
            
            apiSuccessForSubmitSuggestion = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoadingForSubmitSuggestion = false
    }
    
    func deleteAccount() async {
//        isLoadingForSubmitSuggestion = true
        
        if let userIdString = KeychainManager.shared.get("userId"), let parsedId = Int(userIdString) {
            userId = parsedId
        } else {
            errorMessage = String(localized: "error.missingUserId")
            print("errorMessage = \(errorMessage)")
            showError = true
            isLoading = false
            return
        }
        
        print("userId = \(userId)")
        print("suggestionText = \(suggestionText)")
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "suggestions",
                method: "POST",
                body: SubmitSuggestionRequest(comment: suggestionText),
                requiresToken: true,
                responseType: SubmitSuggestionResponse.self
            )
            
            print(response)
            
            self.submitSuggestionData = response.data
            
            apiSuccessForSubmitSuggestion = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoadingForSubmitSuggestion = false
    }
}

