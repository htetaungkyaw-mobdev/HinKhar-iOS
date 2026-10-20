//
//  PromotionUtils.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 29/04/2026.
//
enum DiscountType: String {
    case percentage = "1"
    case fixedAmount = "2"
    case custom3 = "3"
    case custom4 = "4"
    case custom5 = "5"
}

final class PromotionUtils {
    
    static func definePromotionTextToShow(discountType: String, discountValue: String) -> String {
        guard let type = DiscountType(rawValue: discountType) else {
            return ""
        }
        
        switch type {
        case .percentage:
            return "\(discountValue)% OFF"
        case .fixedAmount:
            return "MMK \(discountValue) OFF"
        case .custom3, .custom4, .custom5:
            return discountValue
        }
    }
}
