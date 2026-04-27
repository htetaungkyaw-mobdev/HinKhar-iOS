//
//  RestaurantRow.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 16/12/2025.
//
import SwiftUI

struct RestaurantRowNearBy: View {
    let restaurant: RestaurantForMap

    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 12) {
                // Thumbnail
    //            if restaurant.imageUrl.isEmpty {
    //                Image("DefaultRestaurantImage")
    //                    .resizable()
    //                    .scaledToFill()
    //                    .frame(width: 72, height: 72)
    //                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    //            }
                ZStack {
                    RemoteFillImage(url: URL(string: restaurant.imageUrl), width: 130, height: 110, placeholderImageName: "DefaultRestaurantImage")
                    
                    VStack {
                        HStack {
                            let badgeIconName: String = {
                                switch restaurant.badge {
                                case "Silver":
                                    return "SilverBadge"
                                case "Gold":
                                    return "GoldBadge"
                                case "Platinum":
                                    return "PlatinumBadge"
                                default:
                                    return ""
                                }
                            }()
                            Image(badgeIconName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                            
                            HStack {
                                if restaurant.isHasPromotion! {
                                    Text(restaurant.promotionValue ?? "")
                                        .font(.custom("Futura-Medium", size: 8.0))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color("PrimaryColor"))
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        Spacer()
                        
                        HStack {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 12, height: 12)
                                    .padding(.leading, 4)
                                    .foregroundStyle(Color("SecondaryColor"))
                                
                                Text(String(format: "%.1f", restaurant.overallRating ?? 0))
                                    .font(.custom("Futura-Medium", size: 8.0))
                                    .padding(.trailing, 4)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(.white)
                            }
                            .frame(alignment: .leading)
                            .background(Color("PrimaryColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            
                            Spacer()
                            
                            Image(restaurant.isFavorited ?? false ? "FavoriteSelected" :"FavoriteSelected")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    // handle tap
                                }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
    //                    .padding(.top, 20)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
                .frame(width: 130, height: 110)

                // Text content
                VStack(alignment: .leading, spacing: 16) {
                    // Name
                    Text(restaurant.name)
                        .font(.custom("Futura-Medium", size: 16.0))
                        .foregroundStyle(Color("PrimaryColor"))
                        .lineLimit(1)

                    // Price range or any metadata row
                    Text(restaurant.priceRange)
                        .font(.custom("Futura-Medium", size: 12.0))
                        .foregroundStyle(Color("PrimaryColor").opacity(0.7))
                        .lineLimit(1)
                    
                    // Category
                    Text(restaurant.category)
                        .font(.custom("Futura-Medium", size: 13.0))
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
            if restaurant.isClosed ?? false {
                VStack {
                    HStack {
                        Image("ShopClosed")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 40)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 16)
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
