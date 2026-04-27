//
//  TabItem.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 01/12/2025.
//

enum TabItem: String, CaseIterable {
    case home, promotion, restaurant, profile

        var titleKey: String {
            switch self {
            case .home: return "tab.home"
            case .promotion: return "tab.promotions"
            case .restaurant: return "tab.restaurants"
            case .profile: return "tab.profile"
            }
        }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .promotion: return "tag.fill"
        case .restaurant: return "fork.knife"
        case .profile: return "person.fill"
        }
    }
}
