//
//  GeneralDataViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 20/02/2026.
//
import Foundation
import Combine

@MainActor
class GeneralDataViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var regions: [ApiRegion] = []
    @Published var districts: [ApiDistrict] = []
    @Published var townships: [ApiTownship] = []
    @Published var cuisineTypes: [ApiCuisineType] = []
    
    func getRegions() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "regions",
                method: "GET",
                responseType: RegionListResponse.self
            )
            
            print(response)
            
            self.regions = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func getDistrictsByRegionId(regionId: Int) async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "districts?region_id=\(regionId)",
                method: "GET",
                responseType: DistrictListResponse.self
            )
            
            print(response)
            
            self.districts = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func getTownshipsByDistrictId(districtId: Int) async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "townships?district_id=\(districtId)",
                method: "GET",
                responseType: TownshipListResponse.self
            )
            
            print(response)
            
            self.townships = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func getTownshipsByRegionId(regionId: Int) async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "townships?region_id=\(regionId)",
                method: "GET",
                responseType: TownshipListResponse.self
            )
            
//            print(response)
            
            self.townships = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func getAllCuisineTypes() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "cuisine-types",
                method: "GET",
                responseType: CuisineTypeListResponse.self
            )
            
            print(response)
            
            self.cuisineTypes = response.data
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}
