//
//  NearByRestaurantsView.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 14/02/2026.
//

import SwiftUI
import MapKit
import CoreLocation

struct NearbyRestaurant: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?

    init(id: UUID = UUID(), name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, address: String? = nil) {
        self.id = id
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.name = name
        self.address = address
    }
    
    static func == (lhs: NearbyRestaurant, rhs: NearbyRestaurant) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NearbyRestaurant {
    static let samples: [NearbyRestaurant] = [
        .init(name: "Shan Noodle House", latitude: 16.8465, longitude: 96.1301, address: "Lanmadaw Rd, Yangon"),
        .init(name: "Tea Garden", latitude: 16.8097, longitude: 96.1573, address: "Bahan, Yangon"),
        .init(name: "Yangon BBQ", latitude: 16.8289, longitude: 96.1731, address: "Downtown, Yangon"),
        .init(name: "Royal Curry", latitude: 16.8552, longitude: 96.1809, address: "Kyauktada, Yangon"),
        .init(name: "Lake View Diner", latitude: 16.8186, longitude: 96.1524, address: "Kandawgyi Lake, Yangon")
    ]
}

struct NearByRestaurantsView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 21.8953020, longitude: 96.0962370),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var selected: RestaurantForMap?
    @State private var restaurants: [NearbyRestaurant] = NearbyRestaurant.samples
    @Environment(\.dismiss) private var dismiss
    
    @State private var isGrid: Bool = true
    
    @StateObject var vm = RestaurantViewModel()
    
    @State private var restaurantId: Int = 1
    
    @State private var navigateToHome: Bool = false
    @State private var navigateToDetail: Bool = false
    
    @State private var restaurantCount: Int = 0
    
    @StateObject private var locationManager = LocationManager()
    
    private var currentCoordinate: CLLocationCoordinate2D? {
        locationManager.lastLocation?.coordinate
    }
    
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    private var nearByRestaurants: [RestaurantForMap] {
        // If API data exists, map it to display model; otherwise return empty list
        guard !vm.nearByRestaurants.isEmpty else { return [] }

        return vm.nearByRestaurants.map { r in
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

            return RestaurantForMap(
                id: r.id,
                name: (selectedLanguageCode == "my" ? r.nameMM : r.name) ?? "",
                coordinate: CLLocationCoordinate2D(latitude: Double(r.latitude ?? "0") ?? 0, longitude: Double(r.longitude ?? "0") ?? 0),
                imageUrl: r.restaurantImageURL ?? "",
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
            ZStack (alignment: .top) {
                VStack (alignment: .leading) {
                    HStack {
                        ZStack {
                            Text("home.nearByMe")
                                .font(.custom("Futura-Medium", size: 18.0))
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            HStack {
                                Image("BackArrow")
                                    .renderingMode(.template)
                                    .foregroundStyle(Color("PrimaryColor"))
                                    .onTapGesture {
//                                        dismiss()
                                        navigateToHome = true
                                    }
                                    .padding(.leading, 24)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                    
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
                                
                                HStack {
                                    Image(isGrid ? "Location" : "Location")
                                        .foregroundColor(isGrid ? .white : .black.opacity(0.5))
                                    Text("Map View")
                                        .font(.custom("Futura-Medium", size: 14.0))
                                        .foregroundStyle(isGrid ? .white : .black.opacity(0.5))
                                }
                            }
                        }
                        .frame(width: .infinity, height: 40)
                        
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
                                
                                HStack {
                                    Image(isGrid ? "ListView": "ListViewSelected")
                                        .foregroundColor(isGrid ? .black.opacity(0.5) : .white)
                                    Text("List View")
                                        .font(.custom("Futura-Medium", size: 14.0))
                                        .foregroundStyle(isGrid ? .black.opacity(0.5) : .white)
                                }
                            }
                        }
                        .frame(width: .infinity, height: 40)
                    }
                    .frame(width: .infinity, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 20)
                    
                    if isGrid {
//                        if let coord = currentCoordinate {
//                            Text("Lat: \(coord.latitude), Lon: \(coord.longitude)")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                                .padding(.horizontal, 20)
//                        }
                        Map(position: $position, selection: $selected) {
                            ForEach(nearByRestaurants) { restaurant in
                                Annotation(restaurant.name, coordinate: restaurant.coordinate) {
//                                    ZStack {
//                                        Circle()
//                                            .fill(Color.red)
//                                            .frame(width: 22, height: 22)
//                                        Circle()
//                                            .fill(Color.white)
//                                            .frame(width: 8, height: 8)
//                                    }
                                    Image("CustomMarker")
                                        .accessibilityLabel(Text(restaurant.name))
                                }
                                .tag(restaurant)
                            }
                        }
                        
//                        Text(String(restaurantCount))
                    }
                    else {
                        
                        if nearByRestaurants.isEmpty {
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
                            //Custom ListView
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(nearByRestaurants) { restaurant in
                                        RestaurantRowNearBy(restaurant: restaurant)
                                            .padding(.horizontal, 24)
                                            .onTapGesture {
                                                restaurantId = restaurant.id
                                                navigateToDetail = true
                                            }
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                            }
                        }
                    }
                    //                .ignoresSafeArea(.container, edges: .bottom)
                }
            }
            .navigationBarHidden(true)
            .task {
                
//                vm.latitude = "21.8953020"
//                vm.longitude = "96.0962370"
//                await vm.getNearByRestaurants()
//                restaurantCount = vm.nearByRestaurants.count
                
//                 Request permission; location updates will arrive via delegate
//                locationManager.requestWhenInUseAuthorization()
//                
//                 If we already have a location (e.g., returning to the screen), use it immediately
                if let coord = locationManager.lastLocation?.coordinate {
                                        vm.latitude = String(coord.latitude)
                                        vm.longitude = String(coord.longitude)
//                                        vm.latitude = "21.8953020"
//                                        vm.longitude = "96.0962370"
                    await vm.getNearByRestaurants()
                    restaurantCount = vm.nearByRestaurants.count
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                CustomTabView(selectedTab: .home)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                RestaurantDetailView(restaurantId: restaurantId, comeFrom: "nearBy")
                    .navigationBarBackButtonHidden(true)
            }
            .onChange(of: locationManager.lastLocation) { newLocation in
                guard let coord = newLocation?.coordinate else { return }
                withAnimation(.easeInOut) {
                    position = .region(
                        MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    )
                }
                Task {
                    vm.latitude = String(coord.latitude)
                    vm.longitude = String(coord.longitude)
//                    vm.latitude = "21.9543390"
//                    vm.longitude = "96.1097060"
                    await vm.getNearByRestaurants()
                    restaurantCount = vm.nearByRestaurants.count
                }
            }
            .onAppear {
                            locationManager.requestWhenInUseAuthorization()
                        }
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
}

#Preview {
    NearByRestaurantsView()
}
