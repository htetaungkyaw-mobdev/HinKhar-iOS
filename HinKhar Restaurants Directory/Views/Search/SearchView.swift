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
    @State private var searchDebounceTask: Task<Void, Never>?
    @State private var selectedTownshipID: Int?
    @State private var selectedCuisineTypeID: Int?
    
    @State private var restaurantCount: Int = 0
    
    @State private var restaurantId: Int = 1
    
    @StateObject var vm = RestaurantViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @State private var hintIndex: Int = 0
    @State private var animatedHint: String = ""
    @State private var isDeleting: Bool = false
    @State private var hintAnimationTask: Task<Void, Never>?
    
    private var hints: [String] {
        [
            localizedString("search.placeholder1"),
            localizedString("search.placeholder2")
        ]
    }

    private let typingInterval: Duration = .milliseconds(70)
    private let deletingInterval: Duration = .milliseconds(40)
    private let pauseInterval: Duration = .milliseconds(900)
    
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
                promotionValue = r.promotionLists![0].discount_value ?? ""
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
                                    KeychainManager.shared.clearRestoredFilters()
                                    selectedTownshipID = 0
                                    selectedCuisineTypeID = 0
                                    vm.min_price = ""
                                    vm.max_price = ""
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
                    TextField(animatedHint, text: $searchValue)
                        .font(.custom("Futura-Medium", size: 13.0))
                        .keyboardType(.default)
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
                        .onChange(of: searchValue) { _, newValue in
                            searchDebounceTask?.cancel()
                            searchDebounceTask = Task {
                                try? await Task.sleep(for: .milliseconds(400))
                                guard !Task.isCancelled else { return }

//                                if newValue.isEmpty {
//                                    selectedTownshipID = 100000
//                                }
//                                else {
//                                    selectedTownshipID = 0
//                                }
//                                KeychainManager.shared.save(String(selectedTownshipID ?? 0), forKey: KeychainKeys.filterTownshipID)
                                vm.searchValue = newValue
                                KeychainManager.shared.save(newValue, forKey: KeychainKeys.filterSearchKeyword)
                                await fetchRestaurantsWithCurrentFilters()
                            }
                        }
                    
//                    Button {
//                        Task {
//                            await fetchRestaurantsWithCurrentFilters()
//                        }
//                    } label: {
//                        Text("search")
//                            .font(.custom("Futura-Medium", size: 14.0))
//                            .foregroundStyle(.white)
//                            .frame(maxWidth: 80)
//                            .padding(.vertical, 8)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(Color("PrimaryColor"))
//                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                            if selectedTownshipID == 100000 {
                                selectedTownshipID = 0
                            }
                            await fetchRestaurantsWithCurrentFilters()
                        }
                    },
                    onClearAll: {
                        searchValue = ""
                        vm.restaurants.removeAll()
                        restaurantCount = 0
                        vm.apiSuccess = false
                        print("searchValue_afterClearAll = \(searchValue)")
                    },
                    onPriceChange: { min, max in
                        Task {
                            if selectedTownshipID == 100000 {
                                selectedTownshipID = 0
                            }
                            // sanitize to integers or empty strings for your API
                            vm.min_price = sanitizedIntString(min)   // e.g., "1200" or ""
                            vm.max_price = sanitizedIntString(max)   // e.g., "100000" or ""
                            await fetchRestaurantsWithCurrentFilters()
                        }
                    }
                )
                
                if vm.apiSuccess && restaurantCount > 0 {
                    Text(selectedLanguageCode == "my" ? "\(restaurantCount) ဆိုင် ရှာတွေ့ပါသည်" : "\(restaurantCount) restaurants found")
                        .font(.custom("Futura-Medium", size: 12.0))
                        .foregroundStyle(Color("PrimaryColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                
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

            }
            .task {
                hintAnimationTask?.cancel()
                hintAnimationTask = Task {
                    await runHintAnimation()
                }
                
                guard vm.searchValue.isEmpty,
                      let searchKeyword = KeychainManager.shared.get(KeychainKeys.filterSearchKeyword) else {
                    return
                }
                searchValue = searchKeyword
                print("searchValue = \(searchValue)")
                
                restoreStoredFilters()
                if searchValue.isEmpty && (selectedTownshipID != 0 || selectedCuisineTypeID != 0 || !vm.min_price.isEmpty || !vm.min_price.isEmpty) {
                    await fetchRestaurantsWithCurrentFilters()
                }

            }
            .onDisappear {
                hintAnimationTask?.cancel()
                hintAnimationTask = nil
                searchDebounceTask?.cancel()
                searchDebounceTask = nil
            }
            .navigationDestination(isPresented: $navigateToHome) {
                CustomTabView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                RestaurantDetailView(restaurantId: restaurantId, comeFrom: "search")
                    .navigationBarBackButtonHidden(true)
            }
            .onChange(of: selectedLanguageCode) { _, _ in
                animatedHint = ""
                hintIndex = 0
                isDeleting = false
            }
//            .onChange(of: vm.apiSuccess) { _, _ in
//                restaurantCount = vm.restaurants.count
//                print("restaurantCount = \(restaurantCount)")
//            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
    
    @MainActor
    private func runHintAnimation() async {
        while true {
            if Task.isCancelled {
                return
            }

            if searchValue.isEmpty {
                let currentHint = hints[hintIndex]

                if isDeleting {
                    if !animatedHint.isEmpty {
                        animatedHint.removeLast()
                        try? await Task.sleep(for: deletingInterval)
                    } else {
                        isDeleting = false
                        hintIndex = (hintIndex + 1) % hints.count
                        try? await Task.sleep(for: .milliseconds(250))
                    }
                } else {
                    if animatedHint.count < currentHint.count {
                        let nextCharacterIndex = currentHint.index(
                            currentHint.startIndex,
                            offsetBy: animatedHint.count
                        )
                        animatedHint.append(currentHint[nextCharacterIndex])
                        try? await Task.sleep(for: typingInterval)
                    } else {
                        try? await Task.sleep(for: pauseInterval)
                        isDeleting = true
                    }
                }
            } else if !animatedHint.isEmpty {
                animatedHint = ""
                isDeleting = false
                try? await Task.sleep(for: .milliseconds(120))
            } else {
                try? await Task.sleep(for: .milliseconds(120))
            }
        }
    }
    
    private func fetchRestaurantsWithCurrentFilters(append: Bool = false) async {
        vm.apiSuccess = false
        
        restoreStoredFilters()

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
        
        await vm.getAllRestaurants(append: append)

        if vm.apiSuccess {
            restaurantCount = vm.restaurants.count
        }
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
    
    private var localizationBundle: Bundle {
        guard let path = Bundle.main.path(forResource: selectedLanguageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }

    private func localizedString(_ key: String) -> String {
        NSLocalizedString(key, bundle: localizationBundle, comment: "")
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
    
    private func restoreStoredFilters() {
        
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
    SearchView()
}
