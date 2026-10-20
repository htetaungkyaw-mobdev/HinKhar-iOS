//
//  MenuRow.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//
import SwiftUI

struct MenuRow: View {
    let menu: RestaurantMenu
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"

    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RemoteFillImage(url: URL(string: menu.imageUrl), width: 130, height: 110, placeholderImageName: "DefaultMenuImage")
                    
                    VStack {
                        HStack {
                            HStack {
                                if menu.isSignature == 1 {
                                    Text("menu.signature")
                                        .font(.custom("Futura-Medium", size: 6.0))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color("PrimaryColor"))
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        
                        Spacer()
                        
                    }
                }
                .frame(width: 130, height: 110)

                // Text content
                VStack(alignment: .leading, spacing: 16) {
                    // Name
                    Text(selectedLanguageCode == "my" ? menu.nameMM : menu.name)
                        .font(.custom("Futura-Medium", size: 16.0))
                        .foregroundStyle(Color("PrimaryColor"))
//                        .lineLimit(1)

                    // Price range or any metadata row
                    Text(menu.price)
                        .font(.custom("Futura-Medium", size: 12.0))
                        .foregroundStyle(Color("PrimaryColor").opacity(0.7))
                        .lineLimit(1)
                }
                .frame(height: 110)

                Spacer()
            }
    //        .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)

            
            // open / close status
            if menu.isAvailable == 0 {
                VStack {
                    Text("menu.notAvailable")
                        .font(.custom("Futura-Medium", size: 10.0))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .foregroundStyle(Color("PrimaryColor"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
    }
}

#Preview {
    MenuRow(menu: RestaurantMenu(id: 0, imageUrl: "", name: "Test", nameMM: "TestMM", price: "0", description: "", isAvailable: 0, isSignature: 1))
}
