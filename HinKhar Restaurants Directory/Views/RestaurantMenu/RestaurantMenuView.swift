//
//  RestaurantMenuView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 30/03/2026.
//
import SwiftUI

struct RestaurantMenuView: View {
    let restaurantId: Int
    let restaurantName: String
    let comeFrom: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToDetail: Bool = false
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @State private var searchValue: String = ""
    @State private var searchDebounceTask: Task<Void, Never>?
    @State private var selectedCuisineTypeID: Int?
    @State private var hasLoadedMenus = false
    
    var onCuisineTypeChange: (Int?) -> Void = { _ in }
    
    @StateObject var generalData_vm = GeneralDataViewModel()
    
    @StateObject var vm = RestaurantViewModel()
    
    @State private var isGrid: Bool = true
    
    private var displayMenus: [RestaurantMenu] {
        // If API data exists, map it to display model; otherwise return empty list
        guard !vm.menus.isEmpty else { return [] }

        return vm.menus.map { m in
            let name = m.name ?? ""
            let nameMM = m.name_mm ?? ""
            let imageUrl = m.image_url ?? ""
//            let priceText = m.price ?? ""
            
            let priceText: String = {
                let price = m.price?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return formatPriceString(price)
            }()
            
            let description = m.description ?? ""
            let isAvailable = m.is_available ?? 0
            let isSignature = m.is_signature ?? 0

            return RestaurantMenu(
                id: m.id,
                imageUrl: imageUrl,
                name: name,
                nameMM: nameMM,
                price: priceText,
                description: description,
                isAvailable: isAvailable,
                isSignature: isSignature
            )
        }
    }
    
    private var displayCuisineTypes: [GeneralData] {
        // Map API townships to display model; handle optional safely
        let cuisineTypes = generalData_vm.cuisineTypes
        return cuisineTypes.map { (c: ApiCuisineType) in
            GeneralData(
                id: c.id,
                name: c.name,
                nameMM: c.name_mm
            )
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TitleBar(title: restaurantName.isEmpty ? "" : "\(restaurantName)'s Menu") {
                    navigateToDetail = true
                }
                
                HStack (spacing: 8) {
                    TextField("menu.name.placeholder", text: $searchValue)
                        .font(.custom("Futura-Medium", size: 14.0))
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

                                vm.searchValue = newValue
                                await vm.getRestaurantMenu(restaurantId: restaurantId)
                            }
                        }
                    
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
                    
                    
                    Text("filter.clearAll")
                        .font(.custom("Futura-Medium", size: 14.0))
                        .underline()
                        .onTapGesture {
                            searchValue = ""
                            selectedCuisineTypeID = nil
                            onCuisineTypeChange(selectedCuisineTypeID)
                        }
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 8)
                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(displayCuisineTypes) { cuisineType in
//                            let isSelected = selectedCuisineTypeID == cuisineType.id
//                            Text(cuisineType.name)
//                                .font(.custom("Futura-Medium", size: 15.0))
//                                .foregroundColor(isSelected ? Color.white : Color("PrimaryColor"))
//                                .padding(.vertical, 10)
//                                .padding(.horizontal, 12)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                        .stroke(isSelected ? Color("PrimaryColor") : Color("SecondaryColor"), lineWidth: 1)
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                                .fill(isSelected ? Color("PrimaryColor") : Color.white)
//                                        )
//                                )
//                                .onTapGesture {
//                                    if isSelected {
//                                        selectedCuisineTypeID = nil
//                                    } else {
//                                        selectedCuisineTypeID = cuisineType.id
//                                    }
//                                    onCuisineTypeChange(selectedCuisineTypeID)
//                                }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
                
                // Grid/List View
                HStack {
                    HStack(spacing: 8) {
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
                
                if vm.isLoading {
                    CommonLoading()
                }
                else if !displayMenus.isEmpty {
                    // Data Grid / List
                    Group {
                        if isGrid {
                            let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(Array(displayMenus.enumerated()), id: \.offset) { _, menu in
                                        MenuGrid(menu: menu)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                            }
                        }
                        else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(Array(displayMenus.enumerated()), id: \.offset) { _, menu in
                                        MenuRow(menu: menu)
                                            .padding(.horizontal, 24)
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                            }
                        }
                    }
                }
                else if hasLoadedMenus {
                    
                    Spacer()
                    
                    VStack {
                        Image("NoMenu")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .opacity(0.5)
                        
                        Text("no.menu")
                            .font(.custom("Futura-Medium", size: 16.0))
                            .foregroundStyle(Color("PrimaryColor").opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                }
                else {
                    CommonLoading()
                }
                
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                RestaurantDetailView(restaurantId: restaurantId, comeFrom: comeFrom)
                    .navigationBarBackButtonHidden(true)
            }
            .task {
                hasLoadedMenus = false
                await vm.getRestaurantMenu(restaurantId: restaurantId)
                hasLoadedMenus = true
                print("RestaurantMenuView menu size: \(vm.menus.count)")
                print("RestaurantMenuView displayMenus size: \(displayMenus.count)")
                print("RestaurantMenuView menu IDs: \(vm.menus.map { $0.id })")
                await generalData_vm.getAllCuisineTypes()
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
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

// MARK: - Subviews

private struct TitleBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 0) {

            // Back button
            Button(action: onBack) {
                Image("BackArrow")
                    .renderingMode(.template)
                    .foregroundStyle(Color("PrimaryColor"))
                    .frame(width: 24, height: 24)
            }
            .frame(width: 60, alignment: .leading)
            .padding(.leading, 24)

            // Title
            Text(LocalizedStringKey(title))
                .font(.custom("Futura-Medium", size: 18.0))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // Balance the back button area
            Spacer()
                .frame(width: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview {
    RestaurantMenuView(
        restaurantId: 17,
        restaurantName: "Sample Restaurant",
        comeFrom: "home")
}
