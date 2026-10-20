//
//  RestaurantGrid.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 19/03/2026.
//
import SwiftUI

struct RestaurantGrid: View {
    let restaurant: Restaurant
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 8) {
                ZStack {
                    RemoteFillImage(url: URL(string: restaurant.imageUrl), height: 90, placeholderImageName: "DefaultRestaurantImage")
                    
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
                                .padding(.leading, 8)
                            
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
                            .padding(.trailing, 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        
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
                            .padding(.leading, 8)
                            
                            Spacer()
                            
                            if restaurant.isFavorited ?? false {
                                Image("FavoriteSelected")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 20, height: 20)
                                    .onTapGesture {
                                        // handle tap
                                    }
                                    .padding(.trailing, 8)
                            } else {
                                Image("FavoriteUnselected")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 20, height: 20)
                                    .onTapGesture {
                                        // handle tap
                                    }
                                    .padding(.trailing, 8)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.bottom, 8)
//                        .padding(.top, 28)
                        
    //                    Spacer()
                    }
                    .frame(width: 160, height: 90)
                }
                .frame(width: 160)
    //            .background(Color("PrimaryColor").opacity(0.2))
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(restaurant.name)
                    .font(.custom("Futura-Medium", size: 16.0))
                    .foregroundStyle(Color("PrimaryColor"))
                    .lineLimit(1)
                    .padding(.leading, 8)
                    .padding(.trailing, 8)
                
                Text(restaurant.priceRange)
                    .font(.custom("Futura-Medium", size: 12.0))
                    .foregroundStyle(Color("PrimaryColor").opacity(0.7))
                    .lineLimit(1)
                
                Text(restaurant.category)
                    .font(.custom("Futura-Medium", size: 13.0))
                    .foregroundStyle(Color("PrimaryColor").opacity(0.7))
                    .lineLimit(1)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 8)
            }
            
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
                .frame(maxWidth: 160, maxHeight: .infinity, alignment: .topLeading)
                .background(.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

#Preview {
    RestaurantGrid(
        restaurant: Restaurant(id: 1, imageUrl: "", name: "Test", priceRange: "$ - $", category: "Test", isFavorited: false, badge: "Gold", overallRating: 5.0,
                              isHasPromotion: true, promotionValue: "20% OFF",
                               isClosed: true))
}

