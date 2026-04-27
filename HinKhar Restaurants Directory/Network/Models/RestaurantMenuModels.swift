//
//  RestaurantMenuModels.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 30/03/2026.
//
import Foundation

struct RestaurantMenuListResponse: Codable {
    let data: [MenuCategory]
}

struct MenuCategory: Codable {
    let id: Int
    let menus: [ApiMenu]
}

struct ApiMenu: Codable {
    let id: Int
    let image_url: String?
    let name: String?
    let name_mm: String?
    let price: String?
    let is_available: Int?
    let is_signature: Int?
}
