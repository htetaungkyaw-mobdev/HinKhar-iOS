//
//  RoundedCornerForChoosePhoneOrEmail.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 02/12/2025.
//

import SwiftUI

struct RoundedCornerForChoosePhoneOrEmail: Shape {
    var radius: CGFloat = 32
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
