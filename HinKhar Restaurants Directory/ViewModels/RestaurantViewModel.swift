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
    @Published var page = 1
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMoreData = true
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var totalCount = 0
    
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
    @Published var radius = "1" // 1km
    @Published var nearByRestaurants: [ApiRestaurant] = []
    
    @Published var menus: [ApiMenu] = []
    
    @Published var apiSuccessForStats = false
    @Published var restaurantStats: ApiRestaurantStatData? = nil

    func getAllRestaurants(append: Bool = false) async {
        if append {
            guard hasMoreData, !isLoading, !isLoadingMore else { return }
            isLoadingMore = true
        } else {
            isLoading = true
            page = 1
            hasMoreData = true
            restaurants.removeAll()
        }

        defer {
            if append {
                isLoadingMore = false
            } else {
                isLoading = false
            }
        }
        
        print("township_id = \(township_id)")
        print("cuisine_type_id = \(cuisine_type_id)")
        print("min_price = \(min_price)")
        print("max_price = \(max_price)")
        print("searchValue = \(searchValue)")

        let pageToRequest = page
        
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
                    "search": searchValue,
                    "page": String(pageToRequest)
                    ],
                requiresToken: true,
                responseType: RestaurantListResponse.self
            )

            if append {
                self.restaurants.append(contentsOf: response.data)
            } else {
                self.restaurants = response.data
            }

            if response.data.isEmpty {
                hasMoreData = false
            } else {
                page += 1
            }
            
//            self.totalCount = response.meta.total
            
            apiSuccess = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                return
            }

            errorMessage = error.localizedDescription
            print(errorMessage)
            showError = true
        }
    }

    func getRestaurantMenu(restaurantId: Int) async {
        isLoading = true
        
        do {
            let response = try await RestaurantApiService.apiService.shared(
                endpoint: "menus?restaurant_id=\(restaurantId)&search=\(searchValue)",
                method: "GET",
                responseType: RestaurantMenuListResponse.self
            )

            print(response.data)
            print(response.data.count)
            
            self.menus = response.data
            
            apiSuccess = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

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
                endpoint: "restaurants/nearby",
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
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

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
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

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
        print("token = \(KeychainManager.shared.get(KeychainKeys.userToken))")
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
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoadingForSubmitRating = false
                return
            }

            errorMessage = error.localizedDescription
            print("errorMessage = \(errorMessage)")
            showError = true
        }

        isLoadingForSubmitRating = false
    }
    
    func getRatingByUserId(reviewableId: Int) async {
//        isLoading = true
        
        if let userIdString = KeychainManager.shared.get(KeychainKeys.userId), let parsedId = Int(userIdString) {
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
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

            errorMessage = error.localizedDescription
            print(errorMessage)
            showError = true
        }

        isLoading = false
    }
    
    func getRestaurantStats() async {
        
        do {
            let response = try await RestaurantApiService.apiService.shared(
                endpoint: "restaurants/stats",
                method: "GET",
                requiresToken: true,
                responseType: ApiRestaurantStat.self
            )

            print(response)
            
            self.restaurantStats = response.data
            
            apiSuccessForStats = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

            errorMessage = error.localizedDescription
            print(errorMessage)
            showError = true
        }
    }
    
//    @MainActor
//    func fetchRestaurants() async {
//        // Call your RestaurantApiService.getAllRestaurants(...)
//        // Assign to self.restaurants
//        
//        await getAllRestaurants()
//    }
}
