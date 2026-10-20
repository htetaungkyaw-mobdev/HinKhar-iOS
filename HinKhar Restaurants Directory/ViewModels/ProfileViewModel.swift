//
//  ProfileViewModel.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 03/03/2026.
//

import Foundation
import Combine
import UIKit

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
    
    @Published var profileImageUrl = ""
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        $name
            .removeDuplicates()
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .sink { value in
                // Treat this as 'finished typing'
                KeychainManager.shared.save(value, forKey: KeychainKeys.userName)
                // Or call an API, validate, etc.
            }
            .store(in: &cancellables)
        
        $address
            .removeDuplicates()
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .sink { value in
                // Treat this as 'finished typing'
                KeychainManager.shared.save(value, forKey: KeychainKeys.userAddress)
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
            
            self.profileImageUrl = response.user.profile_image ?? ""
            
            KeychainManager.shared.save(self.name, forKey: KeychainKeys.userName)
            KeychainManager.shared.save(self.gender.capitalizedFirstLetter, forKey: KeychainKeys.userGender)
            KeychainManager.shared.save(self.dob, forKey: KeychainKeys.userDob)
            KeychainManager.shared.save(String(self.regionId), forKey: KeychainKeys.userRegionId)
            KeychainManager.shared.save(self.regionName, forKey: KeychainKeys.userRegionName)
            KeychainManager.shared.save(self.regionNameMM, forKey: KeychainKeys.userRegionNameMM)
            KeychainManager.shared.save(String(self.districtId), forKey: KeychainKeys.userDistrictId)
            KeychainManager.shared.save(self.districtName, forKey: KeychainKeys.userDistrictName)
            KeychainManager.shared.save(self.districtNameMM, forKey: KeychainKeys.userDistrictNameMM)
            KeychainManager.shared.save(String(self.townshipId), forKey: KeychainKeys.userTownshipId)
            KeychainManager.shared.save(self.townshipName, forKey: KeychainKeys.userTownshipName)
            KeychainManager.shared.save(self.townshipNameMM, forKey: KeychainKeys.userTownshipNameMM)
            KeychainManager.shared.save(self.address, forKey: KeychainKeys.userAddress)
            
            apiSuccess = true
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoading = false
                return
            }

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
                        date_of_birth: apiDateString(from: dob),
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
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoadingForUpdate = false
                return
            }

            errorMessage = error.localizedDescription
            showError = true
        }

        isLoadingForUpdate = false
    }
    
    func uploadImage(image: UIImage) async {
        isLoadingForUpdate = true
        
        do {
                // Compress image to 40% quality to save bandwidth
                guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
            
                let boundary = "Boundary-\(UUID().uuidString)"
                
                var body = Data()
                
                // Multipart body formatting
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"profile_image\"; filename=\"profile_selfie.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
                body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            let response = try await UploadImageApiService.apiService.shared(
                endpoint: "auth/profile",
                method: "POST",
                body: body,
                contentType: "multipart/form-data; boundary=\(boundary)",
                requiresToken: true,
                responseType: UpdateProfileResponse.self
                )
            print(response)
            updateSuccess = true
            
            await getUser()
            
        } catch {
            if NetworkRequestGuard.handleOfflineError(error) {
                isLoadingForUpdate = false
                return
            }

            errorMessage = error.localizedDescription
            showError = true
            print(errorMessage)
        }
        isLoadingForUpdate = false
    }
    
    private func apiDateString(from displayDate: String?) -> String? {
        guard let displayDate, !displayDate.isEmpty else {
            return nil
        }
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let date = inputFormatter.date(from: displayDate) else {
            return displayDate
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        outputFormatter.dateFormat = "yyyy-MM-dd"
        return outputFormatter.string(from: date)
    }
}
