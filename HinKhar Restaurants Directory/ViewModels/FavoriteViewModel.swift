//
//  ForgotPasswordViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 09/03/2026.
//
import Foundation
import Combine

@MainActor
class FavoriteViewModel: ObservableObject {
    @Published var favoriteableId = 0
    @Published var favoriteableType = "App\\Models\\Restaurant"
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccessForAdd = false
    @Published var apiSuccess = false
    
    @Published var favorites: [FavoriteData] = []
    @Published var favoriable: ApiRestaurant? = nil
    
    @Published var isFavorite: Bool = false
    
    @Published var messageForRemove = ""

    func updateFavoriteStatus(currentRestaurantId: Int) {
        isFavorite = favorites.contains { $0.favoritable.id == currentRestaurantId }
    }
    
    func getAllFavorites() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "favorites",
                method: "GET",
                requiresToken: true,
                responseType: FavoriteListResponse.self
            )

            print(response)
            
            self.favorites = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
            showError = true
        }

        isLoading = false
    }

    func addFavorite() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "favorites",
                method: "POST",
                body: AddFavoriteRequest(favoritable_id: favoriteableId, favoritable_type: favoriteableType),
                requiresToken: true,
                responseType: AddFavoriteResponse.self
            )
            
            print("favoriable = \(response.data.favoritable)")
            
            favoriable = response.data.favoritable
            
            apiSuccessForAdd = true
        } catch {
            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoading = false
    }
    
    func removeFavorite() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "favorites/\(favoriteableId)",
                method: "DELETE",
                requiresToken: true,
                responseType: RemoveFavoriteResponse.self
            )
            
            print("messageForRemove = \(response.message)")
            
            messageForRemove = response.message
            
            apiSuccessForAdd = true
        } catch {
            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoading = false
    }
}
