//
//  HomeView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 07/12/2025.
//
import SwiftUI

struct HomeView: View {
    
    @Binding var isTabBarHidden: Bool
    
    @State private var navigateToNearBy: Bool = false
    @State private var navigateToSearch: Bool = false
    @State private var navigateToSetting: Bool = false
    @State private var navigateToNotifications: Bool = false
    @State private var navigateToDetail: Bool = false
    @State private var navigateToLogin: Bool = false
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @State private var isFilter: Bool = false
    @State private var filterCount: Int = 0

    @State private var isGrid: Bool = true
    
    @State private var restaurantId: Int = 1
    
    @State private var selectedTownshipID: Int?
    @State private var selectedCuisineTypeID: Int?
    
    @StateObject var vm = RestaurantViewModel()
    
    @State private var hasLoadedRestaurants = false
    
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
            let categoryMM = r.restaurantCategory?.nameMM ?? ""
            
            let isFavorited = r.isFavorited ?? false

            let badgeName = r.badge ?? ""

            let overallRating = r.overallRating ?? 0.0

            var isHasPromotion = false
            var promotionValue = ""
            if !r.promotionLists!.isEmpty {
                isHasPromotion = true
                let value = PromotionUtils.definePromotionTextToShow(
                    discountType: r.promotionLists![0].discount_type ?? "",
                    discountValue: r.promotionLists![0].discount_value ?? ""
                )
                promotionValue = value
            }

            let isClosed = RestaurantStatusUtils.isRestaurantClosed(
                openingHours: r.openingHours,
                manualClosingDays: r.manualClosingDays
            )
            
            return Restaurant(
                id: r.id,
                imageUrl: r.restaurantImageURL ?? "",
                name: (selectedLanguageCode == "my" ? r.nameMM : r.name) ?? "",
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
                VStack(alignment: .leading) {
                    // Location, Search and Setting
                    HStack {
                        HStack(spacing: 8) {
                            Image("Location")
                                .renderingMode(.template)
                                .foregroundStyle(Color("PrimaryColor"))
                                .onTapGesture {
                                    KeychainManager.shared.clearRestoredFilters()
                                    selectedTownshipID = 0
                                    selectedCuisineTypeID = 0
                                    vm.min_price = ""
                                    vm.max_price = ""
                                    if KeychainManager.shared.get(KeychainKeys.userId) != "" {
                                        navigateToNearBy = true
                                    }
                                    else {
                                        navigateToLogin = true
                                    }
                                    isTabBarHidden = true
                                }
                            Text("home.nearByMe")
                                .font(.custom("Futura-Medium", size: 16.0))
                                .foregroundStyle(.black)
                                .onTapGesture {
                                    KeychainManager.shared.clearRestoredFilters()
                                    selectedTownshipID = 0
                                    selectedCuisineTypeID = 0
                                    vm.min_price = ""
                                    vm.max_price = ""
                                    if KeychainManager.shared.get(KeychainKeys.userId) != "" {
                                        navigateToNearBy = true
                                    }
                                    else {
                                        navigateToLogin = true
                                    }
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
                                    KeychainManager.shared.clearRestoredFilters()
                                    selectedTownshipID = 0
                                    selectedCuisineTypeID = 0
                                    vm.min_price = ""
                                    vm.max_price = ""
                                    updateFilterCount()
                                    navigateToSearch = true
                                    isTabBarHidden = true
                                }
                            Button {
                                if KeychainManager.shared.get(KeychainKeys.userId) != "" {
                                    navigateToNotifications = true
                                } else {
                                    navigateToLogin = true
                                }
                                isTabBarHidden = true
                            } label: {
                                Image(systemName: "bell")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(Color("PrimaryColor"))
                                    .frame(width: 28, height: 28)
                            }
                            .accessibilityLabel("Notifications")
                            Image("Setting")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(Color("PrimaryColor"))
                                .onTapGesture {
                                    if KeychainManager.shared.get(KeychainKeys.userId) != "" {
                                        navigateToSetting = true
                                    }
                                    else {
                                        navigateToLogin = true
                                    }
                                    isTabBarHidden = true
                                }
                        }
//                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 24)
                    }
                    
                    // Grid/List View
                    HStack {
                        Text("home.title")
                            .font(.custom("Futura-Medium", size: 18.0))
                            .foregroundStyle(.black)
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
                                Task {
                                    await fetchRestaurantsWithCurrentFilters()
                                }
                            },
                            onCuisineTypeChange: { newValue in
                                // Update selection
                                selectedCuisineTypeID = newValue
                                Task {
                                    await fetchRestaurantsWithCurrentFilters()
                                }
                            },
                            onClearAll: {
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
                                Task {
                                    await fetchRestaurantsWithCurrentFilters()
                                }
                            }
                        )
                            .padding(.leading, 24)
                    }
                    
                    if vm.apiSuccess {
                        Text(selectedLanguageCode == "my" ? "စုစုပေါင်း \(vm.restaurantStats?.subscribed_restaurants ?? 0) ဆိုင်ထဲမှ \(displayRestaurants.count) ဆိုင်ကို ပြသထားသည်" : "Showing \(displayRestaurants.count) of \(vm.restaurantStats?.subscribed_restaurants ?? 0) restaurants")
                            .font(.custom("Futura-Medium", size: 14.0))
                            .foregroundStyle(Color("PrimaryColor"))
                            .padding(.leading, 24)
                    }

                    // Centered loading overlay
                    if vm.isLoading {
                        CommonLoading()
                    }
                    else if !displayRestaurants.isEmpty {
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
                                                .onAppear {
                                                    loadMoreRestaurantsIfNeeded(currentRestaurant: restaurant)
                                                }
                                                .onTapGesture {
                                                    restaurantId = restaurant.id
                                                    isTabBarHidden = true
                                                    navigateToDetail = true
                                                }
                                        }
                                        if vm.isLoadingMore {
                                            footerSpinner
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
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
                                                .onAppear {
                                                    loadMoreRestaurantsIfNeeded(currentRestaurant: restaurant)
                                                }
                                                .onTapGesture {
                                                    restaurantId = restaurant.id
                                                    isTabBarHidden = true
                                                    navigateToDetail = true
                                                }
                                        }
                                        if vm.isLoadingMore {
                                            footerSpinner
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                        }
                                    }
                                    .padding(.top, 8)
                                    .padding(.bottom, 24)
                                }
                            }
                        }
                    }
                    else if hasLoadedRestaurants {
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
                        CommonLoading()
                    }
                    
                    Divider()
                        .background(Color.red)
                        .padding(.bottom, 90)
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
                SettingView(isTabBarHidden: $isTabBarHidden)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToNotifications) {
                NotificationsView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                RestaurantDetailView(restaurantId: restaurantId, comeFrom: "home")
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                print("HomeView")
                isTabBarHidden = false
                hasLoadedRestaurants = false
                Task { await vm.getRestaurantStats() }
                Task { await fetchRestaurantsWithCurrentFilters() }
                hasLoadedRestaurants = true
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
    
    private func fetchRestaurantsWithCurrentFilters(append: Bool = false) async {
        print("fetchRestaurantsWithCurrentFilters")
        restoreStoredFilters()
        
        vm.subscribed_list = "true"
        
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
        
        updateFilterCount()
        
        await vm.getAllRestaurants(append: append)
    }

    private func loadMoreRestaurantsIfNeeded(currentRestaurant: Restaurant) {
        guard let lastRestaurant = displayRestaurants.last,
              lastRestaurant.id == currentRestaurant.id else {
            return
        }

        guard !vm.isLoading,
              !vm.isLoadingMore,
              vm.hasMoreData else {
            return
        }

        Task {
            await fetchRestaurantsWithCurrentFilters(append: true)
        }
    }

    private var footerSpinner: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(Color("PrimaryColor"))
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
    
    func updateFilterCount() {
        print("updateFilterCount")
        // Update filter count: count township if it's a non-zero selection
        // Start from zero and recompute based on active filters to avoid double counting
        var count = 0
        if let t = selectedTownshipID, t != 0 { count += 1 }
        if let c = selectedCuisineTypeID, c != 0 { count += 1 }
        let hasPrice = !vm.min_price.isEmpty || !vm.max_price.isEmpty
        if hasPrice { count += 1 }
        filterCount = count
        print("filterCount = \(filterCount)")
        // Ensure filter UI is visible when a filter is applied
        if count > 0 { isFilter = true } else { isFilter = false }
    }

    private func restoreStoredFilters() {
        print("restoreStoredFilters")
        print("testTownship = \(KeychainManager.shared.get(KeychainKeys.filterTownshipID))")
        print("testCT = \(KeychainManager.shared.get(KeychainKeys.filterCuisineTypeID))")
        guard selectedTownshipID == nil,
              let storedTownshipID = KeychainManager.shared.get(KeychainKeys.filterTownshipID),
              let townshipID = Int(storedTownshipID) else {
            return
        }
        selectedTownshipID = townshipID
        print("selectedTownshipID = \(selectedTownshipID.map(String.init) ?? "nil")")
        
        guard selectedCuisineTypeID == nil,
              let storedCuisineTypeID = KeychainManager.shared.get(KeychainKeys.filterCuisineTypeID),
              let cuisineTypeID = Int(storedCuisineTypeID) else {
            return
        }
        selectedCuisineTypeID = cuisineTypeID
        print("selectedCuisineTypeID = \(selectedCuisineTypeID.map(String.init) ?? "nil")")
        
        guard vm.min_price.isEmpty,
              let storedMinPrice = KeychainManager.shared.get(KeychainKeys.filterMinPrice) else {
            return
        }
        vm.min_price = storedMinPrice
        print("vm.min_price = \(vm.min_price)")
        
        guard vm.max_price.isEmpty,
              let storedMaxPrice = KeychainManager.shared.get(KeychainKeys.filterMaxPrice) else {
            return
        }
        vm.max_price = storedMaxPrice
        print("vm.max_price = \(vm.max_price)")
        
        
    }
    
}

#Preview {
    HomeView(isTabBarHidden: .constant(false))
}
