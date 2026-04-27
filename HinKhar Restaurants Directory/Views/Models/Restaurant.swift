//
//  Restaurant.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//
struct Restaurant: Identifiable {
    let id: Int
    let imageUrl: String
    let name: String
    let priceRange: String
    let category: String
    let isFavorited: Bool?
    let badge: String?
    let overallRating: Double?
    let isHasPromotion: Bool?
    let promotionValue: String?
    let isClosed: Bool?
}
