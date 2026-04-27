//
//  SearchView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 24/03/2026.
//
import SwiftUI

struct SearchView: View {
    @State private var navigateToHome: Bool = false
    @State private var navigateToDetail: Bool = false
    
    @State private var searchValue: String = ""
    @State private var selectedTownshipID: Int?
    @State private var selectedCuisineTypeID: Int?
    
    @State private var restaurantCount: Int = 0
    
    @State private var restaurantId: Int = 1
    
    @StateObject var vm = RestaurantViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    private var displayRestaurants: [Restaurant] {
        // If API data exists, map it to display model; otherwise return empty list
        guard !vm.restaurants.isEmpty else { return [] }

        return vm.restaurants.map { r in
            // Build price text from min/max if available; adjust formatting as needed
            let priceText: String = {
                let minRaw = r.minimumPrice?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let maxRaw = r.maximumPrice?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let min = formatPriceString(minRaw)
                let max = formatPriceString(maxRaw)
                switch (min.isEmpty, max.isEmpty) {
                case (false, false): return "\(min) – \(max)"
                case (false, true):  return min
                case (true, false):  return max
                default:             return ""
                }
            }()

            let category = r.restaurantCategory?.name ?? ""
            
            let isFavorited = r.isFavorited ?? false

            let badgeName = r.badge ?? ""

            let overallRating = r.overallRating ?? 0.0

            var isHasPromotion = false
            var promotionValue = ""
            if !r.promotionLists!.isEmpty {
                isHasPromotion = true
                promotionValue = r.promotionLists![0].discount_value ?? ""
            }
            
            var isClosed = false

            return Restaurant(
                id: r.id,
                imageUrl: "",
                name: r.name,
                priceRange: priceText,
                category: category,
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
            VStack {
                HStack {
                    ZStack {
                        // Centered title
                        Text("search.title")
                            .font(.custom("Futura-Medium", size: 18.0))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Leading back button overlaid
                        HStack {
                            Image("BackArrow")
                                .renderingMode(.template) // optional if you set Template Image
                                .foregroundStyle(Color("PrimaryColor"))
                                .onTapGesture {
                                    dismiss()
                                }
                                .padding(.leading, 24)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                
                HStack {
                    TextField("search.placeholder", text: $searchValue)
                        .font(.custom("Futura-Medium", size: 13.0))
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color("PrimaryColor"), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.white)
                                )
                        )
                    
                    Button {
                        
                    } label: {
                        Text("search")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 80)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 8)
                
                CustomFiltersView(
                    selectedTownshipID: $selectedTownshipID,
                    selectedCuisineTypeID: $selectedCuisineTypeID,
                    onTownshipChange: { newValue in
                        Task {
                            await fetchRestaurantsWithCurrentFilters()
                        }
                    },
                    onCuisineTypeChange: { newValue in
                        Task {
                            await fetchRestaurantsWithCurrentFilters()
                        }
                    },
                    onPriceChange: { min, max in
                        Task {
                            // sanitize to integers or empty strings for your API
                            vm.min_price = sanitizedIntString(min)   // e.g., "1200" or ""
                            vm.max_price = sanitizedIntString(max)   // e.g., "100000" or ""
                            await fetchRestaurantsWithCurrentFilters()
                        }
                    }
                )
                
                Text("\(restaurantCount) restaurants found")
                    .font(.custom("Futura-Medium", size: 12.0))
                    .foregroundStyle(Color("PrimaryColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(displayRestaurants) { restaurant in
                            RestaurantGrid(restaurant: restaurant)
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
            .task {
                await fetchRestaurantsWithCurrentFilters()
                restaurantCount = vm.restaurants.count
            }
            .navigationDestination(isPresented: $navigateToHome) {
                CustomTabView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                RestaurantDetailView(restaurantId: restaurantId, comeFrom: "search")
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func fetchRestaurantsWithCurrentFilters() async {
        
        if let t_id = selectedTownshipID {
            if t_id == 0 {
                vm.township_id = ""
            } else {
                vm.township_id = String(t_id)
            }
        } else {
            // No selection: clear the filter
            vm.township_id = ""
        }
        
        if let c_id = selectedCuisineTypeID {
            if c_id == 0 {
                vm.cuisine_type_id = ""
            } else {
                vm.cuisine_type_id = String(c_id)
            }
        } else {
            // No selection: clear the filter
            vm.cuisine_type_id = ""
        }
        
        await vm.getAllRestaurants()
    }
    
    private func formatPriceString(_ raw: String) -> String {
        // Attempt to parse as Double first; fall back to Int if needed
        // Remove any non-digit and non-decimal characters except dot and comma, then parse
        let cleaned = raw.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return "" }
        let number: Double? = Double(cleaned) ?? Double(Int(cleaned) ?? 0)
        guard let number = number else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
    
    func sanitizedIntString(_ raw: String?) -> String {
        guard let raw = raw else { return "" }
        let cleaned = raw.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let intVal = Int(cleaned) else { return "" }
        return String(intVal)
    }
}

#Preview {
    SearchView()
}
