//
//  MenuGrid.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 19/03/2026.
//
import SwiftUI

struct MenuGrid: View {
    let menu: RestaurantMenu
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 8) {
                ZStack {
                    RemoteFillImage(url: URL(string: menu.imageUrl), height: 90, placeholderImageName: "DefaultRestaurantImage")
                    
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
                    .frame(width: 160, height: 90)
                }
                .frame(width: 160)
    //            .background(Color("PrimaryColor").opacity(0.2))
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(selectedLanguageCode == "my" ? menu.nameMM : menu.name)
                    .font(.custom("Futura-Medium", size: 16.0))
                    .foregroundStyle(Color("PrimaryColor"))
                    .lineLimit(1)
                    .padding(.leading, 8)
                    .padding(.trailing, 8)
                
                Text(menu.price)
                    .font(.custom("Futura-Medium", size: 12.0))
                    .foregroundStyle(Color("PrimaryColor").opacity(0.7))
                    .lineLimit(1)
                    .padding(.bottom, 8)
            }
            .frame(width: 160)
            
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
        .id(selectedLanguageCode)
    }
}

#Preview {
    MenuGrid(menu: RestaurantMenu(id: 0, imageUrl: "", name: "Test", nameMM: "TestMM", price: "0", isAvailable: 0, isSignature: 1))
}
