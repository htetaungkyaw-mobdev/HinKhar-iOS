//
//  CustomFiltersView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 19/02/2026.
//
import SwiftUI

struct TownshipTest: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct CustomFiltersView: View {
//    @State private var townships: [TownshipTest] = [
//        TownshipTest(id: UUID(), name: "Downtown"),
//        TownshipTest(id: UUID(), name: "Midtown"),
//        TownshipTest(id: UUID(), name: "Uptown"),
//        TownshipTest(id: UUID(), name: "Riverside"),
//        TownshipTest(id: UUID(), name: "Lakeside")
//    ]
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    @Binding var selectedTownshipID: Int?
    @Binding var selectedCuisineTypeID: Int?
    
    var onTownshipChange: (Int?) -> Void = { _ in }
    var onCuisineTypeChange: (Int?) -> Void = { _ in }
    
    @State private var minPriceText: String = ""
    @State private var maxPriceText: String = ""
    var onPriceChange: (_ min: String?, _ max: String?) -> Void = { _, _ in }
    @State private var debounceTask: Task<Void, Never>?
    
    @StateObject var vm = GeneralDataViewModel()
    
    private var displayTownships: [GeneralData] {
        // Map API townships to display model; handle optional safely
        let townships = vm.townships ?? []
        return townships.map { (t: ApiTownship) in
            GeneralData(
                id: t.id,
                name: t.name,
                nameMM: t.name_mm
            )
        }
    }
    
    private var displayCuisineTypes: [GeneralData] {
        // Map API townships to display model; handle optional safely
        let cuisineTypes = vm.cuisineTypes ?? []
        return cuisineTypes.map { (c: ApiCuisineType) in
            GeneralData(
                id: c.id,
                name: c.name,
                nameMM: c.name_mm
            )
        }
    }

    var body: some View {
        VStack (spacing: 8) {
            Text("filter.clearAll")
                .font(.custom("Futura-Medium", size: 16.0))
                .underline()
                .onTapGesture {
                    selectedTownshipID = nil
                    selectedCuisineTypeID = nil
                    minPriceText = ""
                    maxPriceText = ""
                    onTownshipChange(selectedTownshipID)
                    onCuisineTypeChange(selectedCuisineTypeID)
                    onPriceChange(minPriceText, maxPriceText)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
            
            Text("filter.byTownship")
                .font(.custom("Futura-Medium", size: 16.0))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(displayTownships) { township in
                        let isSelected = selectedTownshipID == township.id
                        Text(selectedLanguageCode == "my" ? township.nameMM : township.name)
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
                                    selectedTownshipID = nil
                                } else {
                                    selectedTownshipID = township.id
                                }
                                onTownshipChange(selectedTownshipID)
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            Text("filter.byCuisineType")
                .font(.custom("Futura-Medium", size: 16.0))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(displayCuisineTypes) { cuisineType in
                        let isSelected = selectedCuisineTypeID == cuisineType.id
                        Text(selectedLanguageCode == "my" ? cuisineType.nameMM : cuisineType.name)
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
            
            HStack {
                Text("filter.byPriceRange")
                    .font(.custom("Futura-Medium", size: 16.0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Text("500 - 100,000")
                    .foregroundColor(Color("PrimaryColor"))
                    .font(.custom("Futura-Medium", size: 14.0))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }
            HStack(spacing: 12) {
                TextField("Min", text: $minPriceText)
                    .font(.custom("FuturaCyrillicMedium", size: 14.0))
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color("PrimaryColor"), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white)
                            )
                    )
                    .textFieldStyle(.plain)
                    .onChange(of: minPriceText) { newValue in
                        debounceTask?.cancel()
                        debounceTask = Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
                            onPriceChange(newValue.isEmpty || newValue == "Min" ? nil : newValue,
                                          maxPriceText.isEmpty || maxPriceText == "Max" ? nil : maxPriceText)
                        }
                    }
                    .onSubmit {
                        onPriceChange(minPriceText.isEmpty || minPriceText == "Min" ? nil : minPriceText,
                                      maxPriceText.isEmpty || maxPriceText == "Max" ? nil : maxPriceText)
                    }
                    
                    
                
                Text("-")
                    
                TextField("Max", text: $maxPriceText)
                    .keyboardType(.numberPad)
                    .font(.custom("FuturaCyrillicMedium", size: 14.0))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color("PrimaryColor"), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white)
                            )
                    )
                    .textFieldStyle(.plain)
                    .onChange(of: maxPriceText) { newValue in
                        debounceTask?.cancel()
                        debounceTask = Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
                            onPriceChange(minPriceText == "Min" ? nil : minPriceText,
                                          newValue.isEmpty || newValue == "Max" ? nil : newValue)
                        }
                    }
                    .onSubmit {
                        onPriceChange(minPriceText == "Min" ? nil : minPriceText,
                                      maxPriceText.isEmpty || maxPriceText == "Max" ? nil : maxPriceText)
                    }
            }
            .padding(.horizontal)
        }
        .task {
            await vm.getTownshipsByRegionId(regionId: 10)
            await vm.getAllCuisineTypes()
        }
        .environment(\.locale, Locale(identifier: selectedLanguageCode))
        .id(selectedLanguageCode)
    }
}

#Preview {
    @Previewable @State var townshipId: Int? = nil
    @Previewable @State var cuisineTypeId: Int? = nil
    return CustomFiltersView(
        selectedTownshipID: $townshipId,
        selectedCuisineTypeID: $cuisineTypeId
    )
}
