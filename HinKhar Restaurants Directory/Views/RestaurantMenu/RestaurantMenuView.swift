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
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @State private var searchValue: String = ""
    @State private var selectedCuisineTypeID: Int?
    
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
            let priceText = m.price ?? ""
            let isAvailable = m.is_available ?? 0
            let isSignature = m.is_signature ?? 0

            return RestaurantMenu(
                id: m.id,
                imageUrl: "",
                name: name,
                nameMM: nameMM,
                price: priceText,
                isAvailable: isAvailable,
                isSignature: isSignature
            )
        }
    }
    
    private var displayCuisineTypes: [GeneralData] {
        // Map API townships to display model; handle optional safely
        let cuisineTypes = generalData_vm.cuisineTypes ?? []
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
                    dismiss()
                }
                
                HStack (spacing: 8) {
                    TextField("menu.name.placeholder", text: $searchValue)
                        .font(.custom("Futura-Medium", size: 14.0))
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
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(displayCuisineTypes) { cuisineType in
                            let isSelected = selectedCuisineTypeID == cuisineType.id
                            Text(cuisineType.name)
                                .font(.custom("Futura-Medium", size: 15.0))
                                .foregroundColor(isSelected ? Color.white : Color("PrimaryColor"))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(isSelected ? Color("PrimaryColor") : Color("SecondaryColor"), lineWidth: 1)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(isSelected ? Color("PrimaryColor") : Color.white)
                                        )
                                )
                                .onTapGesture {
                                    if isSelected {
                                        selectedCuisineTypeID = nil
                                    } else {
                                        selectedCuisineTypeID = cuisineType.id
                                    }
                                    onCuisineTypeChange(selectedCuisineTypeID)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
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
                
                // Data Grid / List
                Group {
                    if isGrid {
                        let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(displayMenus) { menu in
                                    
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
                }
            }
            .task {
                await vm.getRestaurantMenu(restaurantId: restaurantId)
                await generalData_vm.getAllCuisineTypes()
            }
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
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
    RestaurantMenuView(
        restaurantId: 28,
        restaurantName: "Sample Restaurant")
}
