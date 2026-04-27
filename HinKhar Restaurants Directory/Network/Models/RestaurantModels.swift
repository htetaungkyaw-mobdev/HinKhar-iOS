//
//  RestaurantModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 14/12/2025.
//

import Foundation

struct RestaurantListResponse: Codable {
    let data: [ApiRestaurant]
}

struct RestaurantDetailResponse: Codable {
    let data: ApiRestaurant
}

struct ApiRestaurant: Codable {
    let id: Int
    let name: String
    let nameMM: String?
    let contacts: [ApiContact]?
    let latitude: String?
    let longitude: String?
    let openingHours: [ApiOpeningHour]?
    let minimumPrice: String?
    let maximumPrice: String?
    let restaurantCategory: LocalizedName?
    let cuisineTypes: [LocalizedName]?
    let address: String?
    let overallRating: Double?
    let totalRatings: Int?
    let socialMediaLinks: [ApiSocialMediaLink]?
    let manualClosingDays: [ApiManualClosingDay]?
    let restaurantImageURL: String?
    let isFavorited: Bool?
    let badge: String?
    let promotionLists: [ApiPromotionList]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, contacts, latitude, longitude, address, badge
        case nameMM = "name_mm"
        case openingHours = "opening_hours"
        case minimumPrice = "minimum_price"
        case maximumPrice = "maximum_price"
        case restaurantCategory = "restaurant_category"
        case cuisineTypes = "cuisine_types"
        case overallRating = "overall_rating"
        case totalRatings = "total_ratings"
        case socialMediaLinks = "social_media_links"
        case manualClosingDays = "manual_closing_days"
        case restaurantImageURL = "restaurant_image_url"
        case isFavorited = "is_favorited"
        case promotionLists = "promotion_lists"
    }
}

struct ApiContact: Codable {
    let phone: String?
}

struct ApiOpeningHour: Codable {
    let openingDay: String?
    let closingTime: String?
    let openingTime: String?

    enum CodingKeys: String, CodingKey {
        case openingDay = "opening_day"
        case closingTime = "closing_time"
        case openingTime = "opening_time"
    }
}

struct ApiSocialMediaLink: Codable {
    let link: String?
    let channel: String?
}

struct ApiManualClosingDay: Codable {
    let closingDate: String?
    let closingInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case closingDate = "closing_date"
        case closingInfo = "closing_info"
    }
}

struct ApiPromotionList: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let discount_type: String?
    let discount_value: String?
    let coupon_code: String?
}

//struct ApiRestaurant: Codable {
//    let id: Int
//    let name: String
//    let nameMM: String?
//    let slug: String
//    let type: String
//    let parentId: Int?
//    let restaurantCategoryId: Int?
//    let townshipId: Int?
//    let address: String?
//    let contacts: [ApiContact]?
//    let socialMediaLinks: [ApiSocialMediaLink]?
//    let latitude: String?
//    let longitude: String?
//    let googleMapURL: String?
//    let manualClosingDays: [String]?
//    let openingHours: [ApiOpeningHour]?
//    let minimumPrice: String?
//    let maximumPrice: String?
//    let currencyId: Int?
//    let overallRating: Double?
//    let description: String?
//    let isActive: Bool?
//    let restaurantImageURL: String?
//    let restaurantImage: String?
//    let totalViews: Int?
//    let totalFavourites: Int?
//    let totalRatings: Int?
//    let activeSubscriptionPlan: String?
//    let badge: String?
//    let averageRating: Double?
//    let township: LocalizedName?
//    let district: LocalizedName?
//    let region: LocalizedName?
//    let restaurantCategory: LocalizedName?
//    let cuisineTypes: [LocalizedName]?
//    let currency: Currency?
//    let createdAt: String?
//    let updatedAt: String?
//    let isFavorited: Bool?
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, slug, type, address, contacts, latitude, longitude, description, badge, currency
//        case nameMM = "name_mm"
//        case parentId = "parent_id"
//        case restaurantCategoryId = "restaurant_category_id"
//        case townshipId = "township_id"
//        case socialMediaLinks = "social_media_links"
//        case googleMapURL = "google_map_url"
//        case manualClosingDays = "manual_closing_days"
//        case openingHours = "opening_hours"
//        case minimumPrice = "minimum_price"
//        case maximumPrice = "maximum_price"
//        case currencyId = "currency_id"
//        case overallRating = "overall_rating"
//        case isActive = "is_active"
//        case restaurantImageURL = "restaurant_image_url"
//        case restaurantImage = "restaurant_image"
//        case totalViews = "total_views"
//        case totalFavourites = "total_favourites"
//        case totalRatings = "total_ratings"
//        case activeSubscriptionPlan = "active_subscription_plan"
//        case averageRating = "average_rating"
//        case township, district, region
//        case restaurantCategory = "restaurant_category"
//        case cuisineTypes = "cuisine_types"
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case isFavorited = "is_favorited"
//    }
//}
//
//struct ApiContact: Codable {
//    let phone: String?
//}
//
//struct ApiSocialMediaLink: Codable {
//    let link: String?
//    let channel: String?
//}
//
//struct ApiOpeningHour: Codable {
//    let openingDay: String?
//    let closingTime: String?
//    let openingTime: String?
//
//    enum CodingKeys: String, CodingKey {
//        case openingDay = "opening_day"
//        case closingTime = "closing_time"
//        case openingTime = "opening_time"
//    }
//}
//
struct LocalizedName: Codable {
    let name: String?
    let nameMM: String?

    enum CodingKeys: String, CodingKey {
        case name
        case nameMM = "name_mm"
    }
}
//
//struct Currency: Codable {
//    let id: Int?
//    let code: String?
//    let name: String?
//    let symbol: String?
//    let isDefault: Bool?
//    let isActive: Bool?
//    let createdAt: String?
//    let updatedAt: String?
//    let deletedAt: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, code, name, symbol
//        case isDefault = "is_default"
//        case isActive = "is_active"
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case deletedAt = "deleted_at"
//    }
//}

/*
#if DEBUG
 Sample JSON mapping:

 {
   "data": [
     {
       "id": 1,
       "name": "Sample Restaurant",
       "name_mm": "နမူနာစားသောက်ဆိုင်",
       "slug": "sample-restaurant",
       "type": "dine-in",
       "parent_id": null,
       "restaurant_category_id": 3,
       "township_id": 5,
       "address": "123 Sample Street",
       "contacts": [
         {
           "phone": "+95123456789"
         }
       ],
       "social_media_links": [
         {
           "link": "https://facebook.com/sample",
           "channel": "facebook"
         }
       ],
       "latitude": "16.8661",
       "longitude": "96.1951",
       "google_map_url": "https://maps.google.com/?q=16.8661,96.1951",
       "manual_closing_days": ["Sunday"],
       "opening_hours": [
         {
           "opening_day": "Monday",
           "opening_time": "09:00",
           "closing_time": "21:00"
         }
       ],
       "minimum_price": "5.00",
       "maximum_price": "50.00",
       "currency_id": 1,
       "overall_rating": 4.5,
       "description": "A great place to eat.",
       "is_active": true,
       "restaurant_image_url": "https://example.com/image.jpg",
       "restaurant_image": "image.jpg",
       "total_views": 1234,
       "total_favourites": 150,
       "total_ratings": 300,
       "active_subscription_plan": "Premium",
       "badge": "Top Rated",
       "average_rating": 4.4,
       "township": {
         "name": "Downtown",
         "name_mm": "မြို့လယ်"
       },
       "district": {
         "name": "Central District",
         "name_mm": "အလယ်ပိုင်း"
       },
       "region": {
         "name": "Yangon Region",
         "name_mm": "ရန်ကုန်တိုင်း"
       },
       "restaurant_category": {
         "name": "Fast Food",
         "name_mm": "အမြန်စားဖွယ်"
       },
       "cuisine_types": [
         {
           "name": "Burgers",
           "name_mm": "ဟမ်ဘာဂါ"
         }
       ],
       "currency": {
         "id": 1,
         "code": "USD",
         "name": "US Dollar",
         "symbol": "$",
         "is_default": true,
         "is_active": true,
         "created_at": "2020-01-01T00:00:00Z",
         "updated_at": "2020-01-02T00:00:00Z",
         "deleted_at": null
       },
       "created_at": "2025-01-01T12:00:00Z",
       "updated_at": "2025-06-01T12:00:00Z",
       "is_favorited": true
     }
   ]
 }
#endif
*/
