//
//  FavoritesView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 30/03/2026.
//
import SwiftUI

struct FavoritesView: View {
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToDetail: Bool = false
    
    @State private var restaurantId: Int = 1
    
    @StateObject var vm = FavoriteViewModel()
    
    private var displayRestaurants: [Restaurant] {
        // If API data exists, map it to display model; otherwise return empty list
        guard !vm.favorites.isEmpty else { return [] }

        return vm.favorites.map { r in
            // Build price text from min/max if available; adjust formatting as needed
            let priceText: String = {
                let min = r.favoritable.minimumPrice?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
                let max = r.favoritable.maximumPrice?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
                switch (min.isEmpty, max.isEmpty) {
                case (false, false): return "\(min) – \(max)"
                case (false, true):  return min
                case (true, false):  return max
                default:             return ""
                }
            }()

            let category = r.favoritable.restaurantCategory?.name ?? ""
            let categoryMM = r.favoritable.restaurantCategory?.nameMM ?? ""

            let isFavorited = r.favoritable.isFavorited ?? false
            
            let badgeName = r.favoritable.badge ?? ""
            
            let overallRating = r.favoritable.overallRating ?? 0.0
            
            var isHasPromotion = false
            var promotionValue = ""
            if !(r.favoritable.promotionLists!.isEmpty) {
                isHasPromotion = true
                promotionValue = r.favoritable.promotionLists![0].discount_value ?? ""
            }
            
            let isClosed = RestaurantStatusUtils.isRestaurantClosed(
                openingHours: r.favoritable.openingHours,
                manualClosingDays: r.favoritable.manualClosingDays
            )

            return Restaurant(
                id: r.favoritable.id,
                imageUrl: r.favoritable.restaurantImageURL ?? "",
                name: (selectedLanguageCode == "my" ? r.favoritable.nameMM : r.favoritable.name) ?? "",
                priceRange: priceText,
                category: selectedLanguageCode == "my" ? categoryMM : category,
                isFavorited: isFavorited,
                badge: badgeName,
                overallRating: overallRating,
                isHasPromotion: isHasPromotion,
                promotionValue: promotionValue,
                isClosed: isClosed
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TitleBar(title: "profile.button.favorite") {
                        dismiss()
                    }
                    
                    if displayRestaurants.isEmpty {
                        Spacer()
                        
                        VStack {
                            Image("NoRestaurant")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .opacity(0.5)
                            
                            Text("no.restaurant")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(Color("PrimaryColor").opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                    }
                    else {
                        Group {
                            let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(displayRestaurants) { restaurant in
                                        
                                        RestaurantGrid(restaurant: restaurant)
                                        //                                        .onAppear { print("Restaurant \(restaurant.id) isFavorited =", restaurant.isFavorited) }
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                                            .onTapGesture {
                                                restaurantId = restaurant.id
                                                navigateToDetail = true
                                            }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                            }
                        }
                    }
                }
                
                if vm.isLoading {
                    CommonLoading()
                }
            }
            .task {
                await vm.getAllFavorites()
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                RestaurantDetailView(restaurantId: restaurantId, comeFrom: "favorite")
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// MARK: - Subviews

private struct TitleBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(LocalizedStringKey(title))
                .font(.custom("Futura-Medium", size: 18.0))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)

            HStack {
                Image("BackArrow")
                    .renderingMode(.template)
                    .foregroundStyle(Color("PrimaryColor"))
                    .padding(.leading, 24)
                    .onTapGesture { onBack() }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

#Preview {
    FavoritesView()
}
