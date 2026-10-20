//
//  ContactRow.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//
import SwiftUI

struct OpeningHourRow: View {
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    let openingHour: OpeningHour
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Text(openingHour.openingDay!)
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(maxWidth: 100, alignment: .leading)
                    
                
                Text(openingHour.openingTime!)
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(alignment: .leading)
                
                Text("-")
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(alignment: .leading)
                
                Text(openingHour.closingTime!)
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(alignment: .leading)
            }
            .padding(.leading, 8)
            .padding(.top, 4)
            .padding(.bottom, 4)
            
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
