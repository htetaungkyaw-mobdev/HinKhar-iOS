//
//  RestaurantsView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 19/02/2026.
//
import SwiftUI

struct RestaurantsView: View {
    
    @Binding var isTabBarHidden: Bool
    
    @State private var navigateToNearBy: Bool = false
    @State private var navigateToSearch: Bool = false
    @State private var navigateToSetting: Bool = false
    @State private var navigateToDetail: Bool = false
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"

//    private let dummyRestaurants: [Restaurant] = [
//        .init(id: 1, imageUrl: "restaurant1", name: "Sunset Dine", priceRange: "$$", category: "Western"),
//        .init(id: 2, imageUrl: "restaurant2", name: "Sushi World", priceRange: "$$$", category: "Japanese"),
//        .init(id: 3, imageUrl: "restaurant3", name: "Spice Route", priceRange: "$", category: "Indian"),
//        .init(id: 4, imageUrl: "restaurant4", name: "Green Bowl", priceRange: "$$", category: "Vegan"),
//        .init(id: 5, imageUrl: "restaurant5", name: "Pasta Casa", priceRange: "$$", category: "Italian"),
//        .init(id: 6, imageUrl: "restaurant6", name: "Burger Hub", priceRange: "$", category: "Fast Food")
//    ]
    
    @State private var isFilter: Bool = false
    @State private var filterCount: Int = 0

    @State private var isGrid: Bool = true
    
    @State private var restaurantId: Int = 1
    
    @State private var selectedTownshipID: Int?
    @State private var selectedCuisineTypeID: Int?
    
    @StateObject var vm = RestaurantViewModel()
    
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
            ZStack {
                VStack(alignment: .leading) {
                    // Location, Search and Setting
                    HStack {
                        HStack(spacing: 8) {
                            Image("Location")
                                .renderingMode(.template)
                                .foregroundStyle(Color("SecondaryColor"))
                                .onTapGesture {
                                    navigateToNearBy = true
                                    isTabBarHidden = true
                                }
                            Text("home.nearByMe")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(Color("PrimaryColor"))
                                .onTapGesture {
                                    navigateToNearBy = true
                                    isTabBarHidden = true
                                }
                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image("Search")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(Color("SecondaryColor"))
                                .onTapGesture {
                                    navigateToSearch = true
                                    isTabBarHidden = true
                                }
                            Image("Setting")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(Color("PrimaryColor"))
                                .onTapGesture {
                                    navigateToSetting = true
                                    isTabBarHidden = true
                                }
                        }
//                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 24)
                    }
                    
                    // Grid/List View
                    HStack {
                        Text("restaurants.title")
                            .font(.custom("Futura-Medium", size: 18.0))
                            .foregroundStyle(Color("PrimaryColor"))
                            .frame(width: 200, alignment: .leading)
                            .padding(.leading, 24)
                        
                        HStack(spacing: 8) {
                            if isFilter {
                                ZStack {
                                    Image("FilterOn")
                                        .symbolRenderingMode(.monochrome)
                                        .foregroundStyle(Color("SecondaryColor"))
                                        .onTapGesture {
                                            isFilter = false
                                        }
                                    ZStack {
                                        Circle()
                                            .fill(Color("PrimaryColor"))
                                        Text(String(filterCount))
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.white)
                                            .onTapGesture {
                                                isFilter = false
                                            }
                                    }
                                    .frame(width: 16, height: 16)
//                                    .offset(x: -2, y: -2)
                                }
                            }
                            else {
                                Image("FilterOff")
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundStyle(Color("SecondaryColor"))
                                    .onTapGesture {
                                        isFilter = true
                                    }
                            }
                            
                            HStack(spacing: 0) {
                                // GRID BUTTON
                                Button {
                                    withAnimation(.easeInOut) {
                                        isGrid = true
                                    }
                                } label: {
                                    ZStack {
                                        if isGrid {
                                            Color("PrimaryColor")
                                        } else {
                                            Color.white
                                        }
                                        
                                        Image(isGrid ? "GridViewSelected" : "GridView")
                                            .foregroundColor(isGrid ? .white : .black.opacity(0.5))
                                    }
                                }
                                .frame(width: 40, height: 40)
                                
                                // LIST BUTTON
                                Button {
                                    withAnimation(.easeInOut) {
                                        isGrid = false
                                    }
                                } label: {
                                    ZStack {
                                        if isGrid {
                                            Color.white
                                        } else {
                                            Color("PrimaryColor")
                                        }
                                        
                                        Image(isGrid ? "ListView": "ListViewSelected")
                                            .foregroundColor(isGrid ? .black.opacity(0.5) : .white)
                                    }
                                }
                                .frame(width: 40, height: 40)
                            }
                            .frame(height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 24)
                    }
                    
                    if isFilter {
                        CustomFiltersView(
                            selectedTownshipID: $selectedTownshipID,
                            selectedCuisineTypeID: $selectedCuisineTypeID,
                            onTownshipChange: { newValue in
                                // Update selection
                                selectedTownshipID = newValue
                                // Update filter count: count township if it's a non-zero selection
                                // Start from zero and recompute based on active filters to avoid double counting
                                var count = 0
                                if let t = selectedTownshipID, t != 0 { count += 1 }
                                if let c = selectedCuisineTypeID, c != 0 { count += 1 }
                                let hasPrice = !(vm.min_price ?? "").isEmpty || !(vm.max_price ?? "").isEmpty
                                if hasPrice { count += 1 }
                                filterCount = count
                                // Ensure filter UI is visible when a filter is applied
                                if count > 0 { isFilter = true }
                                Task {
                                    await fetchRestaurantsWithCurrentFilters()
                                }
                            },
                            onCuisineTypeChange: { newValue in
                                // Update selection
                                selectedCuisineTypeID = newValue
                                // Recompute filter count with price counted once
                                var count = 0
                                if let t = selectedTownshipID, t != 0 { count += 1 }
                                if let c = selectedCuisineTypeID, c != 0 { count += 1 }
                                let hasPrice = !(vm.min_price ?? "").isEmpty || !(vm.max_price ?? "").isEmpty
                                if hasPrice { count += 1 }
                                filterCount = count
                                if count > 0 { isFilter = true }
                                Task {
                                    await fetchRestaurantsWithCurrentFilters()
                                }
                            },
                            onPriceChange: { min, max in
                                // sanitize to integers or empty strings for your API
                                let sanitizedMin = sanitizedIntString(min)
                                let sanitizedMax = sanitizedIntString(max)
                                vm.min_price = sanitizedMin
                                vm.max_price = sanitizedMax

                                // Recompute filter count based on active filters
                                var count = 0
                                if let t = selectedTownshipID, t != 0 { count += 1 }
                                if let c = selectedCuisineTypeID, c != 0 { count += 1 }
                                let hasPrice = !sanitizedMin.isEmpty || !sanitizedMax.isEmpty
                                if hasPrice { count += 1 }
                                filterCount = count

                                // Ensure filter UI is visible when a filter is applied
                                if count > 0 { isFilter = true }

                                Task {
                                    await fetchRestaurantsWithCurrentFilters()
                                }
                            }
                        )
                            .padding(.leading, 24)
                    }
                    
                    // Data Grid / List
                    Group {
                        if isGrid {
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
                                            isTabBarHidden = true
                                            navigateToDetail = true
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                            }
                        } else {
                            //Custom ListView
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(displayRestaurants) { restaurant in
                                        RestaurantRow(restaurant: restaurant)
                                            .padding(.horizontal, 24)
                                            .onTapGesture {
                                                restaurantId = restaurant.id
                                                isTabBarHidden = true
                                                navigateToDetail = true
                                            }
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color.red)
                        .padding(.bottom, 90)
                }
                .task {
                    await fetchRestaurantsWithCurrentFilters()
                }

                // Centered loading overlay
                if vm.isLoading {
                    CommonLoading()
                }
            }
            .overlay(alignment: .bottom) {
                if let message = vm.errorMessage != "" ? vm.errorMessage : nil {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text(message)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Button("Dismiss") { vm.errorMessage = "" }
                            .font(.footnote)
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .allowsHitTesting(true)
                }
            }
            .navigationDestination(isPresented: $navigateToNearBy) {
                NearByRestaurantsView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToSearch) {
                SearchView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToSetting) {
                SettingView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                RestaurantDetailView(restaurantId: restaurantId, comeFrom: "restaurant")
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear { isTabBarHidden = false }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
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
    RestaurantsView(isTabBarHidden: .constant(false))
}

