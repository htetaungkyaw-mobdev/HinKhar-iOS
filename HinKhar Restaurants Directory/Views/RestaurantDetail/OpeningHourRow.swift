//
//  ContactRow.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//
import SwiftUI

struct OpeningHourRow: View {
    let openingHour: OpeningHour
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Text(openingHour.openingDay!)
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(maxWidth: 100, alignment: .leading)
                    .padding(.top, 4)
                
                Text(openingHour.openingTime!)
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(alignment: .leading)
                    .padding(.top, 4)
                
                Text("-")
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(alignment: .leading)
                    .padding(.top, 4)
                
                Text(openingHour.closingTime!)
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(alignment: .leading)
                    .padding(.top, 4)
            }
            .padding(.leading, 8)
            
            Spacer()
        }
    }
}

#Preview {
    OpeningHourRow(openingHour: OpeningHour(
        id: "",
        openingDay: "Wednesday",
        openingTime: "8:00 AM",
        closingTime: "6:00 PM"))
}
