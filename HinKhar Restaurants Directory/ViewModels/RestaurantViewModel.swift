//
//  RestaurantViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 14/12/2025.
//
import Foundation
import Combine

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var subscribed_list = ""
    @Published var has_promotion_today = ""
    @Published var is_active = true
    @Published var township_id = ""
    @Published var min_price = ""
    @Published var max_price = ""
    @Published var cuisine_type_id = ""
    @Published var searchValue = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var restaurants: [ApiRestaurant] = []
    @Published var restaurantDetail: ApiRestaurant? = nil
    
    @Published var isLoadingForSubmitRating = false
    @Published var reviewableId = 0
    @Published var reviewableType = ""
    @Published var rating = 0
    @Published var comment = ""
    @Published var review: ApiReview? = nil
    @Published var apiSuccessForSubmitRating = false
    
    @Published var userId = 0
    
    @Published var ratingFromApi: Int = 0
    
    @Published var latitude = "0.0"
    @Published var longitude = "0.0"
    @Published var radius = "0.1"
    @Published var nearByRestaurants: [ApiRestaurant] = []
    
    @Published var menus: [ApiMenu] = []

    func getAllRestaurants() async {
        isLoading = true
        
        print("township_id = \(township_id)")
        print("min_price = \(min_price)")
        print("max_price = \(max_price)")
        
        do {
            let response = try await RestaurantApiService.apiService.shared(
                endpoint: "restaurants",
                method: "GET",
                query: [
                    "subscribed_list": subscribed_list,
                    "has_promotion_today": has_promotion_today,
                    "is_active": "true",
                    "sort_by": "overall_rating",
                    "sort_dir": "desc",
                    "include": "activePromotionLists",
                    "township_id": township_id,
                    "cuisine_type_id": cuisine_type_id,
                    "min_price": min_price,
                    "max_price": max_price,
                    "search": searchValue
                    ],
                requiresToken: true,
                responseType: RestaurantListResponse.self
            )

            print(response)
            
            self.restaurants = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
            showError = true
        }

        isLoading = false
    }

    func getRestaurantMenu(restaurantId: Int) async {
        isLoading = true
        
        do {
            let response = try await RestaurantApiService.apiService.shared(
                endpoint: "restaurants/\(restaurantId)/menus",
                method: "GET",
                responseType: RestaurantMenuListResponse.self
            )

            print(response)
            
            if response.data.count > 0 {
                self.menus = response.data[0].menus
            }
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
            showError = true
        }

        isLoading = false
    }
    
    func getNearByRestaurants() async {
        isLoading = true
        
        print("latitude = \(latitude)")
        print("longitude = \(longitude)")
        
        do {
            let response = try await RestaurantApiService.apiService.shared(
                endpoint: "restaurants",
                method: "GET",
                query: [
                    "latitude": latitude,
                    "longitude": longitude,
                    "radius": radius,
                    "is_active": "true",
                    "sort_by": "overall_rating",
                    "sort_dir": "desc",
                    "include": "activePromotionLists"
                    ],
                requiresToken: true,
                responseType: RestaurantListResponse.self
            )

            print("nearByRestaurants = \(response)")
            
            self.nearByRestaurants = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
            showError = true
        }

        isLoading = false
    }
    
    func getRestaurantById(id: Int) async {
        isLoading = true
        
        do {
            let response = try await RestaurantApiService.apiService.shared(
                endpoint: "restaurants/\(id)",
                method: "GET",
                query: [
                    "include": "activePromotionLists"
                    ],
                responseType: RestaurantDetailResponse.self
            )

            print(response)
            
            self.restaurantDetail = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
    
    func submitRating() async {
        isLoadingForSubmitRating = true
        print("reviewableId = \(reviewableId)")
        print("reviewableType = \(reviewableType)")
        print("rating = \(rating)")
        print("comment = \(comment)")
        print("token = \(KeychainManager.shared.get("userToken"))")
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "reviews",
                method: "POST",
                body: ReviewRequest(reviewable_id: reviewableId, reviewable_type: reviewableType, rating: rating, comment: comment),
                requiresToken: true,
                responseType: ReviewResponse.self
            )
            
            print("review = \(response.data)")
            
            review = response.data
            
            apiSuccessForSubmitRating = true
        } catch {
            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoadingForSubmitRating = false
    }
    
    func getRatingByUserId(reviewableId: Int) async {
//        isLoading = true
        
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
        print("reviewableId = \(reviewableId)")
        
        do {
            let response = try await RestaurantApiService.apiService.shared(
                endpoint: "reviews",
                method: "GET",
                query: [
                    "user_id": String(userId),
                    "reviewable_id": String(reviewableId)
                ],
                requiresToken: true,
                responseType: ReviewListResponse.self
            )

            print("review = \(response.data)")
            
            if !response.data.isEmpty {
                self.review = response.data[0]
                self.ratingFromApi = review?.rating ?? 0
            }
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
            showError = true
        }

        isLoading = false
    }
    
//    @MainActor
//    func fetchRestaurants() async {
//        // Call your RestaurantApiService.getAllRestaurants(...)
//        // Assign to self.restaurants
//        
//        await getAllRestaurants()
//    }
}
