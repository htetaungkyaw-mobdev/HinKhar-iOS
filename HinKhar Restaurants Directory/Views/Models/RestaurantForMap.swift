//
//  Restaurant.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//

import MapKit

struct RestaurantForMap: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let imageUrl: String
    let priceRange: String
    let category: String
    let isFavorited: Bool?
    let badge: String?
    let overallRating: Double?
    let isHasPromotion: Bool?
    let promotionValue: String?
    let isClosed: Bool
    
    static func == (lhs: RestaurantForMap, rhs: RestaurantForMap) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
