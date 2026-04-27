//
//  ProfileViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 03/03/2026.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var gender = ""
    @Published var dob = ""
    @Published var regionId = 0
    @Published var regionName = ""
    @Published var regionNameMM = ""
    @Published var districtId = 0
    @Published var districtName = ""
    @Published var districtNameMM = ""
    @Published var townshipId = 0
    @Published var townshipName = ""
    @Published var townshipNameMM = ""
    @Published var address = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var apiSuccess = false
    
    @Published var updateSuccess = false
    @Published var isLoadingForUpdate = false
    
    @Published var user: User?
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        $name
            .removeDuplicates()
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .sink { value in
                // Treat this as 'finished typing'
                KeychainManager.shared.save(value, forKey: "userName")
                // Or call an API, validate, etc.
            }
            .store(in: &cancellables)
        
        $address
            .removeDuplicates()
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .sink { value in
                // Treat this as 'finished typing'
                KeychainManager.shared.save(value, forKey: "userAddress")
                // Or call an API, validate, etc.
            }
            .store(in: &cancellables)
    }
    
    func getUser() async {
        isLoading = true
        
        do {
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/me",
                method: "GET",
                requiresToken: true,
                responseType: ProfileResponse.self
            )
            
            print(response)
            
            self.user = response.user
            
            self.name = response.user.name
            self.gender = response.user.gender ?? ""
            self.dob = response.user.date_of_birth ?? ""
            self.regionId = response.user.region?.id ?? 0
            self.regionName = response.user.region?.name ?? ""
            self.regionNameMM = response.user.region?.name_mm ?? ""
            self.districtId = response.user.district?.id ?? 0
            self.districtName = response.user.district?.name ?? ""
            self.districtNameMM = response.user.district?.name_mm ?? ""
            self.townshipId = response.user.township?.id ?? 0
            self.townshipName = response.user.township?.name ?? ""
            self.townshipNameMM = response.user.township?.name_mm ?? ""
            self.address = response.user.address ?? ""
            
            KeychainManager.shared.save(self.name, forKey: "userName")
            KeychainManager.shared.save(self.gender.capitalizedFirstLetter, forKey: "userGender")
            KeychainManager.shared.save(self.dob, forKey: "userDob")
            KeychainManager.shared.save(String(self.regionId), forKey: "userRegionId")
            KeychainManager.shared.save(self.regionName, forKey: "userRegionName")
            KeychainManager.shared.save(self.regionNameMM, forKey: "userRegionNameMM")
            KeychainManager.shared.save(String(self.districtId), forKey: "userDistrictId")
            KeychainManager.shared.save(self.districtName, forKey: "userDistrictName")
            KeychainManager.shared.save(self.districtNameMM, forKey: "userDistrictNameMM")
            KeychainManager.shared.save(String(self.townshipId), forKey: "userTownshipId")
            KeychainManager.shared.save(self.townshipName, forKey: "userTownshipName")
            KeychainManager.shared.save(self.townshipNameMM, forKey: "userTownshipNameMM")
            KeychainManager.shared.save(self.address, forKey: "userAddress")
            
            apiSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }

    func updateUser(
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        gender: String? = nil,
        dob: String? = nil,
        townshipId: Int? = nil,
        address: String? = nil
    ) async {
        isLoadingForUpdate = true
        
        do {
            let request = UpdateProfileRequest(
                        name: name?.isEmpty == true ? nil : name,
                        email: email?.isEmpty == true ? nil : email,
                        phone: phone?.isEmpty == true ? nil : phone,
                        gender: gender?.isEmpty == true ? nil : gender,
                        date_of_birth: dob?.isEmpty == true ? nil : dob,
                        township_id: townshipId == 0 ? nil : townshipId,
                        address: address?.isEmpty == true ? nil : address
                    )
            
            let response = try await ApiService.apiService.shared(
                endpoint: "auth/profile",
                method: "PUT",
                body: request,
                requiresToken: true,
                responseType: UpdateProfileResponse.self
            )

            print(response)
            updateSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoadingForUpdate = false
    }
}

