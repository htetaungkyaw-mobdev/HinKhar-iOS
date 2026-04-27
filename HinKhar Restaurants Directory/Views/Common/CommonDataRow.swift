//
//  CommonDataRow.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//
import SwiftUI

struct CommonDataRow: View {
    let generalData: GeneralData
    let currentLanguage: String
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(currentLanguage == "my" ? generalData.nameMM : generalData.name)
                        .font(.custom("Futura-Medium", size: 16.0))
                        .frame(alignment: .leading)
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            Divider()
        }
    }
}

#Preview {
    CommonDataRow(generalData: GeneralData(
        id: 0,
        name: "name",
        nameMM: "nameMM"
    ),
    currentLanguage: "my")
}
