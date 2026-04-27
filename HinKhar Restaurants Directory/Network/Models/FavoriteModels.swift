//
//  FavoriteModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 18/03/2026.
//

struct FavoriteListResponse: Decodable {
    let data: [FavoriteData]
}

struct AddFavoriteRequest: Encodable {
    let favoritable_id: Int
    let favoritable_type: String
}

struct AddFavoriteResponse: Decodable {
    let data: FavoriteData
}

struct FavoriteData: Decodable {
    let id: Int
    let user_id: Int
    let favoritable_id: Int
    let favoritable_type: String
    let favoritable: ApiRestaurant
}

struct RemoveFavoriteResponse: Decodable {
    let message: String
}
